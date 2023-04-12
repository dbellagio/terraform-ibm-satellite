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

resource "google_compute_instance_template" "gcp_control_plane_host_template" {
  for_each   = var.control_plane_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

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
    startup-script = module.satellite-location.control_plane_script
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
       metadata["startup-script"],
     ]
  }

}

resource "google_compute_instance_template" "gcp_worker_host_template" {
  for_each   = var.worker_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

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
    startup-script = module.satellite-location.worker_script
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
       metadata["startup-script"],
     ]
   }

}

resource "google_compute_instance_template" "gcp_storage_host_template" {
  for_each   = var.storage_hosts
  name = "${var.gcp_resource_prefix}-${each.key}-template"
  # name_prefix        = "${var.gcp_resource_prefix}-template"
  description = "Each template is used to create a host, we could change this later to have a template for worker, storage, control plane"
  instance_description = "The GCP host: either be a worker, storage, or control plane"

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
    startup-script = module.satellite-location.storage_script
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
       metadata["startup-script"],
     ]
   }

}

resource "google_compute_instance_from_template" "gcp_control_plane_hosts" {

  #----------------------------------------------------------------------
  # Control Plan Hosts
  #----------------------------------------------------------------------
  for_each           = var.control_plane_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  source_instance_template  = google_compute_instance_template.gcp_control_plane_host_template[each.key].id

  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}

resource "google_compute_instance_from_template" "gcp_storage_hosts" {

  #----------------------------------------------------------------------
  # Storage Hosts
  #----------------------------------------------------------------------
  for_each           = var.storage_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  source_instance_template  = google_compute_instance_template.gcp_storage_host_template[each.key].id
  
  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}

resource "google_compute_instance_from_template" "gcp_worker_hosts" {

  #----------------------------------------------------------------------
  # Worker Hosts
  #----------------------------------------------------------------------
  for_each           = var.worker_hosts
  name = "${var.gcp_resource_prefix}-${each.key}"
 
  source_instance_template  = google_compute_instance_template.gcp_worker_host_template[each.key].id
  
  #------------------------------------
  # sepcify each zone sepcifically
  #------------------------------------
  zone               = each.value.zone

}

resource "ibm_satellite_host" "assign_host" {

  #--------------------------------------------------------------------------------------
  # Only assign the control plane hosts, other hosts get assigned during cluster creation
  #--------------------------------------------------------------------------------------

  depends_on     = [google_compute_instance_from_template.gcp_control_plane_hosts]
  for_each       = var.control_plane_hosts

  location      = var.location
  host_id       = "${var.gcp_resource_prefix}-${each.key}"
  labels        = (var.control_plane_host_labels != null ? concat(var.host_labels, var.control_plane_host_labels) : var.host_labels)
  zone          = each.value.zone
  host_provider = "google"
}
