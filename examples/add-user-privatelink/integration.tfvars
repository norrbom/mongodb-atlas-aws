## Atlas global settings
atlas_cloud_region   = "EU_NORTH_1"
atlas_cloud_provider = "AWS"

## Atlas Project settings
atlas_project_enabled = false
atlas_org_id          = "6299ad37ac40fa3c6b424acc"
atlas_owner           = "test-team"
atlas_project_name    = "RTD-DEVELOPMENT"
# linking existing teams to the project, teams are create on organisation level
atlas_teams = []
atlas_auditing_enabled = false

## Atlas IAM users settings
# system users with access to any database i the cluster
atlas_irsa_anydb_users = {
  "federation-test-client" = {
    namespace       = "test"
    service_account = "test-client"
    eks_oidc_id     = "oidc.eks.eu-central-1.amazonaws.com/id/CC2B549BEB4FD64213BBF97AC1A82FA6"
    role_name       = "readAnyDatabase"
    scopes = [
      {
        name = "test"
        type = "CLUSTER"
      }
    ]
  }
}

## Atlas Private Links settings
atlas_private_links = {
  "EU_CENTRAL_1" = {
    atlas_private_link_id = null # There is NOT an existing link, created outside this codebase that can be reused
    private_link_region   = "EU_CENTRAL_1"
    link_endpoints = {
      "dev-test" = {
        aws_vpc_id             = "vpc-0c6f01929dadbb7f0"
        aws_subnet_ids         = ["subnet-06e1b6c49ff32bddd","subnet-0b737f897cc689616","subnet-082e6e16a32d1008b"]
        aws_security_group_ids = ["sg-079eebd7629e8c7e7"]
      }
    }
  }
}
## Atlas Cluster settings
atlas_clusters = {}