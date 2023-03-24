
output "location_id" {
  value = data.ibm_satellite_location.location.id
}

output "control_plane_script" {
  value = data.ibm_satellite_attach_host_script.control_plane_script.host_script
}

output "worker_script" {
  value = data.ibm_satellite_attach_host_script.worker_script.host_script
}

output "storage_script" {
  value = data.ibm_satellite_attach_host_script.storage_script.host_script
}

output "debug_script" {
  value = data.ibm_satellite_attach_host_script.debug_script.host_script
}