resource "mongodbatlas_database_user" "anydb_user" {
  for_each           = var.irsa_anydb_users
  username           = aws_iam_role.irsa_anydb_users[each.key].arn
  project_id         = var.project_id
  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name     = each.value.role_name
    database_name = "admin"
  }
  dynamic "scopes" {
    for_each = each.value.scopes
    content {
      name = scopes.value.name
      type = scopes.value.type
    }
  }
}