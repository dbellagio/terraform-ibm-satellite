resource "ibm_satellite_host" "assign_host" {
  count = var.host_count

  location      = var.location
  host_id       = element(split(".", var.host_vms[count.index]), 0)
  labels        = var.host_labels != null ? var.host_labels : null
  zone          = var.location_zone
  host_provider = var.host_provider
}
