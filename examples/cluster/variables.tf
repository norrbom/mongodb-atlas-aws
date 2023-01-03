## Atlas global variables
variable "atlas_cloud_provider" {
  type = string
}
variable "atlas_cloud_region" {
  type        = string
  description = "AWS region where clusters will be deployed and where the customer-managed KMS key usde for encrypting Atlas at rest will be stored"
}
## Atlas Project variables
variable "atlas_project_enabled" {
  type        = bool
  description = "Enables creation of an Atlas project"
  default     = true
}
variable "atlas_auditing_enabled" {
  type        = bool
  description = "Enables defualt auditing, Atlas charges a 10% extra. If advanced audit filter is needed, set this flag to false and configure the mongodbatlas_auditing resource separately"
  default     = true
}
variable "atlas_owner" {
  type        = string
  description = "Atlas resource owner"
}
variable "atlas_org_id" {
  type        = string
  description = "Atlas Organization ID"
}
variable "atlas_project_name" {
  type        = string
  description = "Atlas project name"
}
variable "atlas_teams" {
  type = set(object({
    team_id    = string
    role_names = list(string)
    }
  ))
  description = "Linking existing teams to the project"
}
## Atlas IAM users variables
variable "eks_oidc_id" {
  type        = string
  description = "OIDC ID of the EKS Cluster to create Assume Role Policy"
}
variable "atlas_irsa_anydb_users" {
  type = map(object({
    namespace       = string # Kubernetes Service Account namespace
    service_account = string # Kubernetes Serice Account name
    role_name       = string # Privileges assigned to the database user, admin database accepts: atlasAdmin, readWriteAnyDatabase, readAnyDatabase, clusterMonitor, backup, dbAdminAnyDatabase
    scopes = set(object({    # Scopes the access to cluster and data lakes
      name = string
      type = string
    }))
  }))
  default     = {}
  description = "Creates IAM roles and systems user with with access to any database. Pods in a EKS cluster can assume the role via a sevice account, that has to be created separately"
}
## Atlas Private Links variables
variable "atlas_private_links" {
  type = map(object({
    atlas_private_link_id = string          # Unique identifier of the AWS PrivateLink connection, indicating the link for the region has been created already
    link_endpoints = map(object({           # Atlas AWS region name 
      aws_vpc_id             = string       # AWS VPC Id
      aws_subnet_ids         = list(string) # List of subnet Ids
      aws_security_group_ids = list(string) # List of security group Ids to associate with the VPC Endpoint network interface
    }))
  }))
  description = "List of settings for creating private links"
}
## Atlas Cluster variables
variable "atlas_clusters" {
  type = map(object({
    atlas_cluster_paused               = bool
    atlas_cluster_name                 = string
    atlas_mongo_db_major_version       = string
    atlas_backup_enabled               = bool
    atlas_pit_enabled                  = bool
    atlas_bi_connector_enabled         = bool
    atlas_minimum_enabled_tls_protocol = string
    atlas_instance_size                = string
    atlas_node_count                   = number
    atlas_compute_max_instance_size    = string
  }))
}