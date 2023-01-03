resource "mongodbatlas_project" "this" {
  name   = var.project_name
  org_id = var.org_id

  is_collect_database_specifics_statistics_enabled = true
  is_data_explorer_enabled                         = true
  is_performance_advisor_enabled                   = true
  is_realtime_performance_panel_enabled            = true
  is_schema_advisor_enabled                        = true

  dynamic "teams" {
    for_each = var.teams
    content {
      team_id    = teams.value.team_id
      role_names = teams.value.role_names
    }
  }
}

resource "mongodbatlas_auditing" "default" {
  project_id                  = mongodbatlas_project.this.id
  audit_filter                = var.audit_filter
  audit_authorization_success = false
  enabled                     = var.auditing_enabled
}

resource "aws_kms_key" "atlas_key" {
  description              = "ATLAS_ENCRYPTION_KEY"
  customer_master_key_spec = "SYMMETRIC_DEFAULT"
  enable_key_rotation      = true
}
resource "aws_kms_alias" "atlas_key" {
  name          = "alias/atlas-master-encryption-key-${mongodbatlas_project.this.name}"
  target_key_id = aws_kms_key.atlas_key.key_id
}

data "aws_iam_policy_document" "atlas_assume_role_policy" {
  statement {
    effect = "Allow"
    principals {
      type        = "AWS"
      identifiers = [mongodbatlas_cloud_provider_access_setup.setup.aws.atlas_aws_account_arn]
    }
    actions = ["sts:AssumeRole"]
    condition {
      test     = "StringEquals"
      variable = "sts:ExternalId"
      values   = [mongodbatlas_cloud_provider_access_setup.setup.aws.atlas_assumed_role_external_id]
    }
  }
}
resource "aws_iam_role" "atlas_role" {
  name = "MongoDBAtlasServiceRole-${mongodbatlas_project.this.name}"
  tags = {
    Name     = "MongoDBAtlasServiceRole-${mongodbatlas_project.this.name}",
    owned-by = var.owner
  }
  assume_role_policy = data.aws_iam_policy_document.atlas_assume_role_policy.json
}

data "aws_iam_policy_document" "atlas_role_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "kms:Decrypt",
      "kms:Encrypt",
      "kms:DescribeKey"
    ]
    resources = [
      aws_kms_key.atlas_key.arn
    ]
  }
}

resource "aws_iam_role_policy" "atlas_role_policy" {
  name   = "MongoDBAtlasKMSPolicy-${mongodbatlas_project.this.name}"
  role   = aws_iam_role.atlas_role.id
  policy = data.aws_iam_policy_document.atlas_role_policy_document.json
}

# Role that allows IAM roles registration in Atlas
resource "mongodbatlas_cloud_provider_access_setup" "setup" {
  project_id    = mongodbatlas_project.this.id
  provider_name = local.cloud_provider
}

# Authorize an AWS IAM roles in Atlas.
resource "mongodbatlas_cloud_provider_access_authorization" "auth_role" {
  project_id = mongodbatlas_cloud_provider_access_setup.setup.project_id
  role_id    = mongodbatlas_cloud_provider_access_setup.setup.role_id
  aws {
    iam_assumed_role_arn = aws_iam_role.atlas_role.arn
  }
}

# Hack to handle changes IAM credentials, since changes are not immediately reflected to the API
resource "time_sleep" "wait_for_iam_credentials" {
  create_duration = "10s"
  depends_on      = [mongodbatlas_cloud_provider_access_authorization.auth_role]
}

resource "mongodbatlas_encryption_at_rest" "mongo_encryption" {
  project_id = mongodbatlas_project.this.id
  aws_kms_config {
    enabled                = true
    role_id                = mongodbatlas_cloud_provider_access_authorization.auth_role.role_id
    customer_master_key_id = aws_kms_key.atlas_key.arn
    region                 = var.kms_key_region
  }
  depends_on = [time_sleep.wait_for_iam_credentials, mongodbatlas_cloud_provider_access_setup.setup]
}