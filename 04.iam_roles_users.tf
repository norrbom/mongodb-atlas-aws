data "aws_iam_policy_document" "irsa_anydb_users-assume-role-policy" {
  for_each = var.irsa_anydb_users
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = ["arn:aws:iam::${data.aws_caller_identity.current.account_id}:oidc-provider/${each.value.eks_oidc_id}"]
    }
    condition {
      test     = "StringEquals"
      variable = "${each.value.eks_oidc_id}:aud"
      values   = ["sts.amazonaws.com"]
    }
    condition {
      test     = "StringEquals"
      variable = "${each.value.eks_oidc_id}:sub"
      values   = ["system:serviceaccount:${each.value.namespace}:${each.value.service_account}"]
    }
  }
}

resource "aws_iam_role" "irsa_anydb_users" {
  for_each           = var.irsa_anydb_users
  name               = "MongoDBAtlas-irsa_anydb_users-${mongodbatlas_project.this.name}-${each.value.namespace}"
  assume_role_policy = data.aws_iam_policy_document.irsa_anydb_users-assume-role-policy[each.key].json
  tags               = merge({ "Name" = "MongoDBAtlas-irsa_anydb_usersServiceRole-${mongodbatlas_project.this.name}" }, var.tags)
}
