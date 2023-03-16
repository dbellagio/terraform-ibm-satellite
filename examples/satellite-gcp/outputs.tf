output "location_id" {
  value = module.satellite-location.location_id
}
output "gcp_control_plane_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_control_plane_hosts : host.self_link]
}
output "gcp_storage_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_storage_hosts : host.self_link]
}
output "gcp_worker_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_worker_hosts : host.self_link]
}
output "gcp_control_plane_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_control_plane_hosts : host.instance_id])
}
output "gcp_storqge_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_storage_hosts : host.instance_id])
}
output "gcp_worker_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_worker_hosts : host.instance_id])
}
output "gcp_control_plane_host_ids" {
  value = flatten([for host in google_compute_instance_from_template.gcp_control_plane_hosts : host.id])
}
output "gcp_storqge_host_ids" {
  value = flatten([for host in google_compute_instance_from_template.gcp_storage_hosts : host.id])
}
output "gcp_worker_host_ids" {
  value = flatten([for host in google_compute_instance_from_template.gcp_worker_hosts : host.id])
}
 