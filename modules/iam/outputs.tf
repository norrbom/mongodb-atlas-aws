output "irsa_anydb_user_names" {
  value       = [for user in mongodbatlas_database_user.anydb_user : user.username]
  sensitive   = false
  description = "List of Atlas database user"
}