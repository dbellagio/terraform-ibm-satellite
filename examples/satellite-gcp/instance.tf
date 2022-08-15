##########################################################
# GCP network, subnetwork and its firewall rules
##########################################################

# Deleted sections to create VPC, subnets, router, NAT

##########################################################
# GCP Compute Template and Instances
##########################################################
resource "tls_private_key" "rsa_key" {
  count     = (var.ssh_public_key == null ? 1 : 0)
  algorithm = "RSA"
  rsa_bits  = 4096
}
module "gcp_host-template" {
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
    startup-script = module.satellite-location.host_script
    serial-port-enable = true
  }
  # startup_script=module.satellite-location.host_script
  machine_type         = each.value.instance_type
  can_ip_forward       = false
  source_image_project = "rhel-cloud"
  source_image_family  = "rhel-7"
  disk_size_gb         = 100
  disk_type            = "pd-ssd"
  disk_labels = {
    ibm-satellite = var.gcp_resource_prefix
  }
  auto_delete     = true
  service_account = { email = "", scopes = [] }
#  depends_on      = [module.satellite-location, module.gcp_firewall-rules]
  depends_on      = [module.satellite-location]

}
module "gcp_hosts" {
  for_each           = local.hosts
  source             = "terraform-google-modules/vm/google//modules/compute_instance"
  region             = var.gcp_region
  network            = var.gcp_shared_network
  subnetwork         = var.gcp_subnet
  num_instances      = each.value.count
  hostname           = "${var.gcp_resource_prefix}-host-${each.key}"
  instance_template  = module.gcp_host-template[each.key].self_link
}