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
variable "irsa_users_readonly" {
  type = map(object({
    namespace       = string # Kubernetes Service Account namespace
    service_account = string # Kubernetes Serice Account name
    eks_oidc_id     = string # OIDC ID of the EKS Cluster to create Assume Role Policy
    scopes = object({        # Scope the access to a cluster or data lake
      name = string
      type = string
    })
  }))
  default     = {}
  description = "Creates read only users and EKS service accounts, limited to a scope, i.e. LAKE or CLUSTER in the Atlas project. Pods in a EKS cluster can assume the role via the sevice account."
}
variable "irsa_users_readwrite" {
  type = map(object({
    namespace       = string # Kubernetes Service Account namespace
    service_account = string # Kubernetes Serice Account name
    eks_oidc_id     = string # OIDC ID of the EKS Cluster to create Assume Role Policy
    scopes = object({        # Scope the access to a cluster or data lake
      name = string
      type = string
    })
  }))
  default     = {}
  description = "Creates users with read and write access and EKS service accounts, limited to a scope, i.e. LAKE or CLUSTER in the Atlas project. Pods in a EKS cluster can assume the role via the sevice account."
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
