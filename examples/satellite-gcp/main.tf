resource "ibm_resource_group" "sat_location_group" {
  name = "var.ibm_resource_group"
  tags = var.host_labels
}

resource "ibm_resource_instance" "location_cos_instance" {
  name              = "${var.gcp_resource_prefix}-location-cos-instance"
  resource_group_id = ibm_resource_group.sat_location_group.id
  service           = "cloud-object-storage"
  plan              = "standard"
  location          = "global"
  tags              = var.host_labels
}

resource "ibm_cos_bucket" "location_cos_bucket" {
  bucket_name          = var.location_bucket
  resource_instance_id = ibm_resource_instance.location_cos_instance.id
  region_location      = var.ibm_region
  storage_class        = "standard"
}


module "satellite-location" {
  source = "../../modules/location"

  is_location_exist = var.is_location_exist
  location          = var.location
  managed_from      = var.managed_from
  location_zones    = var.location_zones
  host_labels       = var.host_labels
  resource_group    = ibm_resource_group.sat_location_group.name
  host_provider     = "google"
  location_bucket   = ibm_cos_bucket.location_cos_bucket.bucket_name
  ibm_region        = ibm_cos_bucket.location_cos_bucket.region_location
}
