resource "mongodbatlas_database_user" "readonly" {
  for_each           = var.irsa_users_readonly
  username           = aws_iam_role.irsa_users_readonly[each.key].arn
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name     = "readAnyDatabase"
    database_name = "admin"
  }
  scopes {
    name = each.value.scopes.name
    type = each.value.scopes.type
  }
}

resource "mongodbatlas_database_user" "readwrite" {
  for_each           = var.irsa_users_readwrite
  username           = aws_iam_role.irsa_users_readwrite[each.key].arn
  project_id         = mongodbatlas_project.this.id
  auth_database_name = "$external"
  aws_iam_type       = "ROLE"

  roles {
    role_name     = "readWriteAnyDatabase"
    database_name = "admin"
  }
  scopes {
    name = each.value.scopes.name
    type = each.value.scopes.type
  }
}