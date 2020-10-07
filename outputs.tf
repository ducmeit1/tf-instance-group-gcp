output "gcp_project" {
  value = var.gcp_project
}

output "gcp_region" {
  value = var.gcp_region
}

output "name" {
  value = var.name
}

output "tags" {
  value = var.tags
}

output "instance_group_url" {
  value = google_compute_region_instance_group_manager.default.self_link
}

output "instance_group_name" {
  value = google_compute_region_instance_group_manager.default.name
}

output "instance_template_url" {
  value = google_compute_instance_template.default.self_link
}

output "instance_template_name" {
  value = google_compute_instance_template.default.name
}

output "instance_template_metadata_fingerprint" {
  value = google_compute_instance_template.default.metadata_fingerprint
}

output "service_account" {
    value = google_service_account.default.email
}