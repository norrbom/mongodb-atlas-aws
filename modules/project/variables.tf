variable "auditing_enabled" {
  type        = bool
  description = "Enables defualt auditing, Atlas charges a 10% extra. If advanced audit filter is needed, set this flag to false and configure the mongodbatlas_auditing resource separately"
  default     = true
}
variable "audit_filter" {
  type        = string
  default     = "{'$or':[{'users':[]},{'$and':[{'$or':[{'users':{'$elemMatch':{'$or':[{'db':'admin'},{'db':'$external'}]}}},{'roles':{'$elemMatch':{'$or':[{'db':'admin'}]}}}]},{'$or':[{'atype':'authCheck','param.command':{'$in':['aggregate','count','distinct','group','mapReduce','geoNear','geoSearch','eval','find','getLastError','getMore','getPrevError','parallelCollectionScan','delete','findAndModify','insert','update','resetError']}},{'atype':{'$in':['authenticate','createCollection','createDatabase','createIndex','renameCollection','dropCollection','dropDatabase','dropIndex','createUser','dropUser','dropAllUsersFromDatabase','updateUser','grantRolesToUser','revokeRolesFromUser','createRole','updateRole','dropRole','dropAllRolesFromDatabase','grantRolesToRole','revokeRolesFromRole','grantPrivilegesToRole','revokePrivilegesFromRole','enableSharding','shardCollection','addShard','removeShard','shutdown','applicationMessage']}}]}]}]}"
  description = "Auditing filter enableling auditing of all resources, roles and users except successful authentications"
}
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
variable "teams" {
  type = set(object({
    team_id    = string
    role_names = list(string)
    }
  ))
  description = "Linking existing teams to the project"
}
variable "kms_key_region" {
  type        = string
  description = "AWS region where the customer-managed KMS key usde for encrypting Atlas at rest will be stored"
}
variable "tags" {
  type        = map(string)
  description = "Specify Tags that will be added to role"
  default     = {}
}