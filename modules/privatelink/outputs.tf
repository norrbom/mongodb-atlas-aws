output "private_links" {
  value       = local.private_link
  sensitive   = false
  description = "Private link service name / ID"
}