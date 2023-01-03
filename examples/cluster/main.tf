data "aws_secretsmanager_secret" "api-keys" {
  name = "ATLAS-PROJ-CREATE-API-KEYS"
}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.api-keys.id
}
provider "mongodbatlas" {
  public_key  = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["public_key"]
  private_key = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["private_key"]
}

# terraform state mv module.atlas 'module.atlas[0]'
module "atlas" {
  count            = var.atlas_project_enabled ? 1 : 0
  source           = "../../modules/project"
  org_id           = var.atlas_org_id
  owner            = var.atlas_owner
  project_name     = var.atlas_project_name
  kms_key_region   = var.atlas_cloud_region
  auditing_enabled = var.atlas_auditing_enabled
  teams            = var.atlas_teams
}
data "mongodbatlas_project" "this" {
  name = var.atlas_project_name
  depends_on      = [module.atlas]
}
# Hack to handle changes to mongodbatlas_privatelink_endpoint, since changes are not immediately reflected to the API
resource "time_sleep" "wait_for_mongodbatlas_encryption_at_rest" {
  create_duration = "10s"
  depends_on      = [module.atlas]
}

# terraform state mv module.privatelink_eu_north_1 'module.privatelink["EU_NORTH_1"]'
module "privatelink" {
  for_each            = var.atlas_private_links
  source              = "../../modules/privatelink"
  project_name        = var.atlas_project_name
  project_id          = var.atlas_project_enabled ? module.atlas[0].atlas_project_id : data.mongodbatlas_project.this.id
  private_link_id     = each.value.atlas_private_link_id
  private_link_region = each.key
  link_endpoints      = {
      "dev-test" = {
        aws_vpc_id             = "vpc-04da503f697fce140"
        aws_subnet_ids         = ["subnet-088655945263249c9","subnet-092f79012ff651995","subnet-0af546c1580a672a4"]
        aws_security_group_ids = ["sg-026bf4e12fc49229d"]
      }
    }
  depends_on          = [module.atlas, data.mongodbatlas_project.this]
}

module "iam" {
  source           = "../../modules/iam"
  project_name     = var.atlas_project_name
  project_id       = var.atlas_project_enabled ? module.atlas[0].atlas_project_id : data.mongodbatlas_project.this.id
  eks_oidc_id      = var.eks_oidc_id
  irsa_anydb_users = var.atlas_irsa_anydb_users
  depends_on       = [module.atlas, data.mongodbatlas_project.this]
}

# terraform state mv mongodbatlas_advanced_cluster.cluster 'mongodbatlas_advanced_cluster.cluster["rtd-dev"]'
resource "mongodbatlas_advanced_cluster" "cluster" {
  for_each = var.atlas_clusters
  # prevents destruction of the cluster
  # lifecycle {
  #   prevent_destroy = true
  # }
  termination_protection_enabled = true
  paused                         = each.value.atlas_cluster_paused
  project_id                     = var.atlas_project_enabled ? module.atlas[0].atlas_project_id : data.mongodbatlas_project.this.id
  name                           = each.value.atlas_cluster_name
  mongo_db_major_version         = each.value.atlas_mongo_db_major_version
  cluster_type                   = "REPLICASET"
  replication_specs {
    num_shards = 1
    region_configs {
      electable_specs {
        instance_size = each.value.atlas_instance_size
        node_count    = each.value.atlas_node_count
      }
      auto_scaling {
        disk_gb_enabled           = true
        compute_enabled           = true
        compute_max_instance_size = each.value.atlas_compute_max_instance_size
      }
      provider_name = var.atlas_cloud_provider
      priority      = 7
      region_name   = var.atlas_cloud_region
    }
  }
  backup_enabled              = each.value.atlas_backup_enabled
  pit_enabled                 = each.value.atlas_pit_enabled
  encryption_at_rest_provider = var.atlas_cloud_provider
  bi_connector {
    enabled = each.value.atlas_bi_connector_enabled
    # read_preference = there are sensible defaults for this in the atlas module
  }
  advanced_configuration {
    #javascript_enabled                   = false
    minimum_enabled_tls_protocol = each.value.atlas_minimum_enabled_tls_protocol
  }
  # hack, encryptipon API takes some time until its enabled
  depends_on = [time_sleep.wait_for_mongodbatlas_encryption_at_rest, data.mongodbatlas_project.this]
}

output "connection_strings" {
  value       = {for k, inst in mongodbatlas_advanced_cluster.cluster: k => inst.connection_strings}
  sensitive   = false
  description = "Connection strings to Atlas cluster"
}
output "irsa_anydb_user_names" {
  sensitive   = false
  value       = module.iam.irsa_anydb_user_names
  description = "List of Atlas database user names"
}

output "atlas_project_id" {
  value = var.atlas_project_enabled ? module.atlas[0].atlas_project_id : data.mongodbatlas_project.this.id
}
output "private_links" {
  value = [for link in module.privatelink : link]
}


resource "mongodbatlas_cloud_backup_schedule" "atlas_test_policies" {
  for_each = var.atlas_clusters
  project_id   = var.atlas_project_enabled ? module.atlas[0].atlas_project_id : data.mongodbatlas_project.this.id
  cluster_name = each.value.atlas_cluster_name

  reference_hour_of_day    = 2  // UTC Hour of day between 0 and 23, inclusive, representing which hour of the day that Atlas takes snapshots for backup policy items.
  reference_minute_of_hour = 10 // UTC Minutes after reference_hour_of_day that Atlas takes snapshots for backup policy items. Must be between 0 and 59, inclusive.
  restore_window_days      = 1 /* Number of days back in time you can restore to with point-in-time accuracy.
                                   Records the full oplog for a configured window, permitting a restore to any point in time within that window. 
                                   Must be a positive, non-zero integer.*/

  // This will now add the desired policy items to the existing mongodbatlas_cloud_backup_schedule resource
  policy_item_hourly {
    frequency_interval = 1      //  Desired frequency of the new backup policy item specified by frequency_type
    retention_unit     = "days" //  Scope of the backup policy item: days, weeks, or months.
    retention_value    = 2      //  Value to associate with retention_unit
  }
  policy_item_daily {
    frequency_interval = 1
    retention_unit     = "days"
    retention_value    = 7
  }
  policy_item_weekly {
    frequency_interval = 4
    retention_unit     = "weeks"
    retention_value    = 4
  }
  policy_item_monthly {
    frequency_interval = 5
    retention_unit     = "months"
    retention_value    = 12
  }
  depends_on = [mongodbatlas_advanced_cluster.cluster]
}