variable "link_endpoints" {
  type = map(object({
    aws_vpc_id             = string       # AWS VPC Id
    aws_subnet_ids         = list(string) # List of subnet Ids
    aws_security_group_ids = list(string) # List of security group Ids to associate with the VPC Endpoint network interface
  }))
  description = "List of settings for creating private links"
}
variable "private_link_region" {
  type        = string
  description = "The cloud provider region in which you want to create the private endpoint connection"
}
variable "project_name" {
  type        = string
  description = "Atlas project name"
}
variable "project_id" {
  type        = string
  description = "Atlas project ID"
}
variable "private_link_id" {
  type = string
  description = "Unique identifier of the AWS PrivateLink connection, indicating the link for the region has been created already"
  default = null
}