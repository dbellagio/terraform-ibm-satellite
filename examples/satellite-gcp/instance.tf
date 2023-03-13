###############################################################################
# GCP network, subnetwork and its firewall rules have been removed in this fork
###############################################################################

# Deleted sections to create VPC, subnets, router, NAT

##########################################################
# GCP Compute Template and Instances
##########################################################
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}

#--------------------------------------------------------------------------------
# Here are the attach_host scripts for each type of host
#--------------------------------------------------------------------------------
data "ibm_satellite_attach_host_script" "attach_script_control_plane" {
  location      = module.satellite-location.location_id
  labels        = (var.control_plane_host_labels != null ? concat(var.host_labels, var.control_plane_host_labels) : var.host_labels)

 # host_provider = var.host_provider
  custom_script = <<EOF
  set +e
  date=`date`
  #-------------------------------------------------------------------------------------------------------------------------
  # The custom script has been removed from this example, but should be put here to enable user login or address repo issues
  #-------------------------------------------------------------------------------------------------------------------------
  set -e
EOF
}

data "ibm_satellite_attach_host_script" "attach_script_storage" {
  location      = module.satellite-location.location_id
  labels        = (var.storage_host_labels != null ? concat(var.host_labels, var.storage_host_labels) : var.host_labels)

 # host_provider = var.host_provider
  custom_script = <<EOF
  set +e
  date=`date`
  #-------------------------------------------------------------------------------------------------------------------------
  # The custom script has been removed from this example, but should be put here to enable user login or address repo issues
  #-------------------------------------------------------------------------------------------------------------------------
  set -e
EOF
}

data "ibm_satellite_attach_host_script" "attach_script_worker" {
  location      = module.satellite-location.location_id
  labels        = (var.worker_host_labels != null ? concat(var.host_labels, var.worker_host_labels) : var.host_labels)

 # host_provider = var.host_provider
  custom_script = <<EOF
  set +e
  date=`date`
  #-------------------------------------------------------------------------------------------------------------------------
  # The custom script has been removed from this example, but should be put here to enable user login or address repo issues
  #-------------------------------------------------------------------------------------------------------------------------
  set -e
EOF
}

/*
module "gcp_host-template" {
  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  for_each   = local.hosts
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.5.0"
  project_id = var.gcp_project
  network     = var.gcp_shared_network
  subnetwork         = var.gcp_subnet
  name_prefix        = "${var.gcp_resource_prefix}-template"
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
#   startup-script = module.satellite-location.host_script
    startup-script = file(each.value.attach_script)
    serial-port-enable = true
  }
  # startup_script=module.satellite-location.host_script
  machine_type         = each.value.instance_type
  can_ip_forward       = false
  source_image_project = var.worker_image_project
  source_image_family  = var.worker_image_family
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  auto_delete     = true
  service_account = { email = "", scopes = [] }
  additional_disks     = each.value.additional_disks
  depends_on      = [module.satellite-location]

}
*/

resource "google_compute_instance_template" "gcp_control_plane_host_template" {
  for_each   = var.control_plane_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  project      = var.gcp_project

  network_interface {
    network     = var.gcp_shared_network
    subnetwork         = var.gcp_subnet
  }
  
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = data.ibm_satellite_attach_host_script.attach_script_control_plane
#    startup-script = file(each.value.attach_script)
    serial-port-enable = true
  }

  machine_type         = each.value.instance_type
  can_ip_forward       = false

  disk {
    # source_image_project = var.worker_image_project
    # source_image_family  = var.worker_image_family
    source_image = "projects/${each.value.image_project}/global/images/${each.value.source_image}"
    disk_size_gb         = 100
    disk_type            = "pd-ssd"
    labels = {
      ibm-satellite = var.gcp_resource_prefix
    }
    auto_delete     = true
    boot = true
  }
  
  service_account { 
    email = each.value.service_account
    scopes = [] 
  }

  depends_on      = [module.satellite-location]

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      metadata.startup_script,
    ]
  }

}

resource "google_compute_instance_template" "gcp_worker_host_template" {
  for_each   = var.worker_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  project      = var.gcp_project

  network_interface {
    network     = var.gcp_shared_network
    subnetwork         = var.gcp_subnet
  }
  
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = data.ibm_satellite_attach_host_script.attach_script_worker
#    startup-script = file(each.value.attach_script)
    serial-port-enable = true
  }

  machine_type         = each.value.instance_type
  can_ip_forward       = false

  disk {
    # source_image_project = var.worker_image_project
    # source_image_family  = var.worker_image_family
    source_image = "projects/${each.value.image_project}/global/images/${each.value.source_image}"
    disk_size_gb         = 100
    disk_type            = "pd-ssd"
    labels = {
      ibm-satellite = var.gcp_resource_prefix
    }
    auto_delete     = true
    boot = true
  }
  
  disk {
    mode = "READ_WRITE"
    disk_type = "pd-balanced"
    disk_size_gb = 100
    type = "PERSISTENT"
    boot = false
    auto_delete = true
    # these device names need to be unique for GCP project in each zone
    device_name = "${var.gcp_resource_prefix}-roks-${each.key}"
    disk_name = "${var.gcp_resource_prefix}-roks-${each.key}"

    labels = {
      type = "forroks"
    }
    
  }

  service_account { 
    email = each.value.service_account
    scopes = [] 
  }

  depends_on      = [module.satellite-location]

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      metadata.startup_script,
    ]
  }

}

resource "google_compute_instance_template" "gcp_storage_host_template" {
  for_each   = var.storage_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  project      = var.gcp_project

  network_interface {
    network     = var.gcp_shared_network
    subnetwork         = var.gcp_subnet
  }
  
  tags               = ["ibm-satellite", var.gcp_resource_prefix]
  labels = {
    ibm-satellite = var.gcp_resource_prefix
  }

  metadata = {
    ssh-keys       = var.ssh_public_key != null ? "${var.gcp_ssh_user}:${var.ssh_public_key}" : tls_private_key.rsa_key.0.public_key_openssh
    startup-script = data.ibm_satellite_attach_host_script.attach_script_storage
#    startup-script = file(each.value.attach_script)
    serial-port-enable = true
  }

  machine_type         = each.value.instance_type
  can_ip_forward       = false

  disk {
    # source_image_project = var.worker_image_project
    # source_image_family  = var.worker_image_family
    source_image = "projects/${each.value.image_project}/global/images/${each.value.source_image}"
    disk_size_gb         = 100
    disk_type            = "pd-ssd"
    labels = {
      ibm-satellite = var.gcp_resource_prefix
    }
    auto_delete     = true
    boot = true
  }

  disk {
    mode = "READ_WRITE"
    disk_type = "pd-balanced"
    disk_size_gb = 100
    type = "PERSISTENT"
    boot = false
    auto_delete = true
    # these device names need to be unique for GCP project in each zone
    device_name = "${var.gcp_resource_prefix}-roks-${each.key}"
    disk_name = "${var.gcp_resource_prefix}-roks-${each.key}"

    labels = {
      type = "forroks"
    }

  }

  disk {
    mode = "READ_WRITE"
    disk_type = "pd-balanced"
    disk_size_gb = var.worker_odf_disk_size
    type = "PERSISTENT"
    boot = false
    auto_delete = true
    # these device names need to be unique for GCP project in each zone
    device_name = "${var.gcp_resource_prefix}-osd-${each.key}"
    disk_name = "${var.gcp_resource_prefix}-osd-${each.key}"
    labels = {
      type = "osd"
    }
  }

  service_account { 
    email = each.value.service_account
    scopes = [] 
  }

  depends_on      = [module.satellite-location]

  lifecycle {
    ignore_changes = [
      # Ignore changes to tags, e.g. because a management agent
      # updates these based on some ruleset managed elsewhere.
      metadata.startup_script,
    ]
  }

}

/*
module "gcp_hosts" {
  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  for_each           = local.hosts
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  version            = "7.9.0"
  region             = var.gcp_region
  network            = var.gcp_shared_network
  subnetwork         = var.gcp_subnet
  #--------------------------------------
  # this is set to 1 in locals.tf
  #--------------------------------------
  num_instances      = each.value.count
  hostname           = "${var.gcp_resource_prefix}-${each.key}"
  instance_template  = module.gcp_host-template[each.key].self_link
  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone
  #---------------------------------
  # Suppress GCP suffix on hostnames
  #---------------------------------
  add_hostname_suffix = false
}
*/

resource "google_compute_instance_from_template" "gcp_control_plane_hosts" {

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  for_each           = var.control_plane_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  #--------------------------------------
  # this is set to 1 in locals.tf
  #--------------------------------------
  source_instance_template  = google_compute_instance_template.gcp_control_plane_host_template[each.key].id

  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}

resource "google_compute_instance_from_template" "gcp_storage_hosts" {

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  for_each           = var.storage_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  #--------------------------------------
  # this is set to 1 in locals.tf
  #--------------------------------------
  source_instance_template  = google_compute_instance_template.gcp_storage_host_template[each.key].id
  
  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}

resource "google_compute_instance_from_template" "gcp_worker_hosts" {

  #----------------------------------------------------------------------
  # the hosts map is constructed in locals.tf and is used in many places
  #----------------------------------------------------------------------
  for_each           = var.worker_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  #--------------------------------------
  # this is set to 1 in locals.tf
  #--------------------------------------
  source_instance_template  = google_compute_instance_template.gcp_worker_host_template[each.key].id
  
  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}


# Assign the control plane hosts to the location

module "satellite-host" {
  for_each = var.control_plane_hosts

  depends_on     = [google_compute_instance_from_template.gcp_control_plane_hosts]
  source         = "../../modules/host"
  host_count     = 1
  location       = module.satellite-location.location_id
  host_vms       = [for instance in google_compute_instance_from_template.gcp_control_plane_hosts[each.key].instances_details : instance.name]
  location_zone  = each.value.zone
  host_labels    = (each.value.additional_labels != null ? concat(var.host_labels, each.value.additional_labels) : var.host_labels)
  host_provider  = "google"
}

/*
resource "ibm_satellite_host" "assign_host" {
  depends_on     = [google_compute_instance_from_template.gcp_control_plane_hosts]
  for_each       = var.control_plane_hosts

  location      = var.location
  host_id       = "${var.gcp_resource_prefix}-${each.key}"
  labels        = (each.value.additional_labels != null ? concat(var.host_labels, each.value.additional_labels) : var.host_labels)
  zone          = each.value.zone
  host_provider = "google"
}
*/
