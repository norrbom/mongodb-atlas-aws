locals {
  org_id                 = "6299ad37ac40fa3c6b424acc"
  owner                  = "test-team"
  project_name           = "TEST"
  cloud_provider         = "AWS"
  cloud_region           = "EU_NORTH_1"
  cluster_name           = "test"
  eks_oidc_id            = "oidc.eks.eu-north-1.amazonaws.com/id/7FFBD06A8020A2BD657AB9D955CBDB70"
  aws_vpc_id             = "vpc-024c10bda7ddbd3c3"
  aws_subnet_ids         = ["subnet-0ece451828a80a331","subnet-07dab9ae9b95df7dd","subnet-040bb2fc624501de4"] # list of subnets Ids
  aws_security_group_ids = ["sg-06a3624cf01a50b67"]     # list of security group Ids
}
