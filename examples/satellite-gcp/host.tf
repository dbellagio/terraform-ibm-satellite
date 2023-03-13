/*

We do not need this file anymore if using resources

module "satellite-host" {
  for_each = local.hosts

  depends_on     = [module.gcp_hosts]
  source         = "../../modules/host"
  host_count     = each.value.for_control_plane ? each.value.count : 0
  location       = module.satellite-location.location_id
  host_vms       = [for instance in module.gcp_hosts[each.key].instances_details : instance.name]
  location_zone  = each.value.zone
#  location_zones = var.location_zones
  host_labels    = (each.value.additional_labels != null ? concat(var.host_labels, each.value.additional_labels) : var.host_labels)
  host_provider  = "google"
}
*/
