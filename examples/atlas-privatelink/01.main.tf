data "aws_secretsmanager_secret" "api-keys" {
  name = "ATLAS-ORGANISATION-API-KEYS"
}
data "aws_secretsmanager_secret_version" "current" {
  secret_id = data.aws_secretsmanager_secret.api-keys.id
}

locals {
  public_key  = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["public_key"]
  private_key = jsondecode(data.aws_secretsmanager_secret_version.current.secret_string)["private_key"]
}

provider "mongodbatlas" {
  public_key  = local.public_key
  private_key = local.private_key
}

module "atlas" {
  source                = "../../"
  org_id                = local.org_id
  owner                 = local.owner
  project_name          = local.project_name
  enable_private_link   = true
  private_link_provider = local.cloud_provider
  private_link_region   = local.cloud_region
  auditing_enabled      = true

  aws_vpc_id             = local.aws_vpc_id
  aws_subnet_ids         = local.aws_subnet_ids
  aws_security_group_ids = local.aws_security_group_ids

  # linking existing teams to the project, teams are create on organisation level
  teams = []

  # create a system user with read write access to any database i the cluster
  irsa_anydb_users = {
    "strimzi-atlas-connect" = {
      namespace       = "rtd"
      service_account = "strimzi-atlas-connect"
      eks_oidc_id     = local.eks_oidc_id
      role_name       = "readWriteAnyDatabase"
      scopes = [
        {
          name = local.cluster_name
          type = "CLUSTER"
        }
      ]
    }
  }
}

resource "time_sleep" "wait_for_mongodbatlas_encryption_at_rest" {
  create_duration = "10s"
  depends_on      = [module.atlas]
}

resource "mongodbatlas_advanced_cluster" "cluster" {
  # prevents destruction of the cluster
  lifecycle {
    prevent_destroy = true
  }
  paused                 = true
  project_id             = module.atlas.atlas_project_id
  name                   = local.cluster_name
  mongo_db_major_version = "6.0"
  cluster_type           = "REPLICASET"
  replication_specs {
    num_shards = 1
    region_configs {
      electable_specs {
        instance_size = "M10"
        node_count    = 3
      }
      auto_scaling {
        disk_gb_enabled           = true
        compute_enabled           = true
        compute_max_instance_size = "M30"
      }
      provider_name = local.cloud_provider
      priority      = 7
      region_name   = local.cloud_region
    }
  }
  backup_enabled              = true
  pit_enabled                 = true
  encryption_at_rest_provider = "AWS"
  bi_connector {
    enabled = false
    # read_preference = there are sensible defaults for this in the atlas module
  }
  advanced_configuration {
    #javascript_enabled                   = false
    minimum_enabled_tls_protocol = "TLS1_2"
  }
  # hack, encryptipon API takes some time until its enabled
  depends_on = [time_sleep.wait_for_mongodbatlas_encryption_at_rest]
}

data "mongodbatlas_database_users" "users" {
  project_id = module.atlas.atlas_project_id
}

output "cluster_srv_address" {
  value       = mongodbatlas_advanced_cluster.cluster.connection_strings[0].standard_srv
  description = "Connection string to Atlas cluster"
}
output "mongodbatlas_database_users" {
  value       = data.mongodbatlas_database_users.users.results.*
  description = "List of Atlas database user"
}