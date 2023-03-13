output "location_id" {
  value = module.satellite-location.location_id
}
output "gcp_control_plane_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_control_plane_hosts : host.instances_self_links]
}
output "gcp_storage_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_storage_hosts : host.instances_self_links]
}
output "gcp_worker_host_links" {
  value = [for host in google_compute_instance_from_template.gcp_worker_hosts : host.instances_self_links]
}
output "gcp_control_plane_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_control_plane_hosts : [for instance in host.instances_details : instance.name]])
}
output "gcp_storqge_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_storage_hosts : [for instance in host.instances_details : instance.name]])
}
output "gcp_worker_host_names" {
  value = flatten([for host in google_compute_instance_from_template.gcp_worker_hosts : [for instance in host.instances_details : instance.name]])
}