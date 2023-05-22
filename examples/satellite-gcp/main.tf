resource "ibm_resource_group" "sat_location_group" {
  name = var.ibm_resource_group
  tags = var.host_labels
}

resource "ibm_resource_instance" "location_cos_instance" {
  name              = "${var.gcp_resource_prefix}-cos-instance"
  resource_group_id = ibm_resource_group.sat_location_group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = var.host_labels
}

resource "ibm_cos_bucket" "location_cos_bucket_region" {
  for_each             = var.ibm_satellite_regions

  bucket_name          = each.value.location_bucket
  resource_instance_id = ibm_resource_instance.location_cos_instance.id
  region_location      = each.value.cos_bucket_region
  storage_class        = "standard"
}


module "satellite-location-region" {
  depends_on                = [ibm_cos_bucket.location_cos_bucket_region]
  source                    = "./modules/location"
  for_each                  = var.ibm_satellite_regions

  is_location_exist         = each.value.is_location_exist
  coreos_enabled            = each.value.satellite_core_os_enabled
  location                  = each.value.location
  managed_from              = each.key
  location_zones            = each.value.location_zones
  host_labels               = var.host_labels
  control_plane_host_labels = var.control_plane_host_labels
  storage_host_labels       = var.storage_host_labels
  worker_host_labels        = var.worker_host_labels 
  debug_host_labels         = var.debug_host_labels 
  resource_group            = ibm_resource_group.sat_location_group.name
  host_provider             = "google"
  location_bucket           = each.value.location_bucket
  ibm_region                = each.value.cos_bucket_region
}
