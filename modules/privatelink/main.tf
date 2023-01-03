# Hack to handle changes to mongodbatlas_privatelink_endpoint, since changes are not immediately reflected to the API
resource "time_sleep" "wait_for_mongodbatlas_privatelink_endpoint" {
  create_duration = "10s"
}
resource "mongodbatlas_privatelink_endpoint" "privatelink" {
  count = var.private_link_id == null ? 1 : 0
  project_id    = var.project_id
  provider_name = local.cloud_provider
  region        = var.private_link_region
  depends_on      = [time_sleep.wait_for_mongodbatlas_privatelink_endpoint]
}

data "mongodbatlas_privatelink_endpoint" "privatelink" {
  count = var.private_link_id == null ? 0 : 1
  project_id      = var.project_id
  private_link_id = var.private_link_id
  provider_name = local.cloud_provider
  depends_on      = [mongodbatlas_privatelink_endpoint.privatelink]
}

resource "aws_vpc_endpoint" "atlas" {
  for_each           = var.link_endpoints
  vpc_id             = each.value.aws_vpc_id
  service_name       = local.private_link.endpoint_service_name
  vpc_endpoint_type  = "Interface"
  subnet_ids         = each.value.aws_subnet_ids
  security_group_ids = each.value.aws_security_group_ids
  tags = {
    Name     = "MongoDBAtlas-${var.project_name}-${each.key}",
  }
}

resource "mongodbatlas_privatelink_endpoint_service" "mongodb_atlas_service" {
  for_each            = var.link_endpoints
  project_id          = var.project_id
  endpoint_service_id = aws_vpc_endpoint.atlas[each.key].id
  private_link_id     = local.private_link.private_link_id
  provider_name       = local.cloud_provider
}