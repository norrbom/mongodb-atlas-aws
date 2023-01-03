locals {
  cloud_provider = "AWS"
  private_link = var.private_link_id == null ? mongodbatlas_privatelink_endpoint.privatelink[0] : data.mongodbatlas_privatelink_endpoint.privatelink[0]
}
