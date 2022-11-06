resource "mongodbatlas_privatelink_endpoint" "privatelink" {
  count         = var.enable_private_link ? 1 : 0
  project_id    = mongodbatlas_project.this.id
  provider_name = var.private_link_provider
  region        = var.private_link_region
}

resource "aws_vpc_endpoint" "atlas" {
  count              = var.enable_private_link ? 1 : 0
  vpc_id             = var.aws_vpc_id
  service_name       = mongodbatlas_privatelink_endpoint.privatelink[0].endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = var.aws_subnet_ids
  security_group_ids = var.aws_security_group_ids
  tags = {
    Name     = "MongoDBAtlas-${mongodbatlas_project.this.name}",
    owned-by = var.owner
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "mongodb_atlas_service" {
  count               = var.enable_private_link ? 1 : 0
  project_id          = mongodbatlas_privatelink_endpoint.privatelink[0].project_id
  endpoint_service_id = aws_vpc_endpoint.atlas[0].id
  private_link_id     = mongodbatlas_privatelink_endpoint.privatelink[0].id
  provider_name       = mongodbatlas_privatelink_endpoint.privatelink[0].provider_name
}