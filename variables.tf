# feature flags
variable "enable_private_link" {
  type        = bool
  description = "Provision a private link"
  default     = true
}
variable "auditing_enabled" {
  type        = bool
  description = "Enables defualt auditing, Atlas charges a 10% extra. If advanced audit filter is needed, set this flag to false and configure the mongodbatlas_auditing resource separately"
  default     = true
}
variable "audit_filter" {
  type        = string
  default     = "{'$or':[{'users':[]},{'$and':[{'$or':[{'users':{'$elemMatch':{'$or':[{'db':'admin'},{'db':'$external'}]}}},{'roles':{'$elemMatch':{'$or':[{'db':'admin'}]}}}]},{'$or':[{'atype':'authCheck','param.command':{'$in':['aggregate','count','distinct','group','mapReduce','geoNear','geoSearch','eval','find','getLastError','getMore','getPrevError','parallelCollectionScan','delete','findAndModify','insert','update','resetError']}},{'atype':{'$in':['authenticate','createCollection','createDatabase','createIndex','renameCollection','dropCollection','dropDatabase','dropIndex','createUser','dropUser','dropAllUsersFromDatabase','updateUser','grantRolesToUser','revokeRolesFromUser','createRole','updateRole','dropRole','dropAllRolesFromDatabase','grantRolesToRole','revokeRolesFromRole','grantPrivilegesToRole','revokePrivilegesFromRole','enableSharding','shardCollection','addShard','removeShard','shutdown','applicationMessage']}}]}]}]}"
  description = "Auditing filter enableling auditin of all resources, roles and users except successful authentications"
}
# parameters
variable "owner" {
  type        = string
  description = "Atlas resource owner"
}
variable "org_id" {
  type        = string
  description = "Atlas Organization ID"
}
variable "project_name" {
  type        = string
  description = "Atlas project name"
}
variable "private_link_provider" {
  type        = string
  description = "The cloud provider for which you want to create the private endpoint service"
}
variable "private_link_region" {
  type        = string
  description = "The cloud provider region in which you want to create the private endpoint connection"
}
variable "teams" {
  type = set(object({
    team_id    = string
    role_names = list(string)
    }
  ))
  description = "Linking existing teams to the project"
}
variable "irsa_anydb_users" {
  type = map(object({
    namespace       = string # Kubernetes Service Account namespace
    service_account = string # Kubernetes Serice Account name
    eks_oidc_id     = string # OIDC ID of the EKS Cluster to create Assume Role Policy
    role_name       = string # Privileges assigned to the database user, admin database accepts: atlasAdmin, readWriteAnyDatabase, readAnyDatabase, clusterMonitor, backup, dbAdminAnyDatabase
    scopes = set(object({    # Scopes the access to cluster and data lakes
      name = string
      type = string
    }))
  }))
  default     = {}
  description = "Creates IAM roles and systems user with with access to any database. Pods in a EKS cluster can assume the role via a sevice account, that has to be created separately"
}
variable "aws_vpc_id" {
  type        = string
  description = "AWS VPC Id"
}
variable "aws_subnet_ids" {
  type        = list(string)
  description = "List of subnet Ids"
}
variable "aws_security_group_ids" {
  type        = list(string)
  description = "List of security group Ids to associate with the VPC Endpoint network interface"
}
variable "tags" {
  type        = map(string)
  description = "Specify Tags that will be added to role"
  default     = {}
}
