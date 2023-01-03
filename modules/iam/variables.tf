variable "eks_oidc_id" {
  type        = string
  description = "OIDC ID of the EKS Cluster to create Assume Role Policy"
}
variable "irsa_anydb_users" {
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

variable "project_name" {
  type        = string
  description = "Atlas project name"
}
variable "project_id" {
  type        = string
  description = "Atlas project ID"
}