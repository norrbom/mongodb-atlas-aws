output "atlas_project" {
  value       = mongodbatlas_project.this
  description = "Atlas Project ID"
}
output "atlas_project_name" {
  value       = mongodbatlas_project.this.name
  description = "Atlas Project Name"
}
output "atlas_project_id" {
  value       = mongodbatlas_project.this.id
  description = "Atlas Project ID"
}