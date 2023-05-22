# # ##################################################
# # # IBMCLOUD Variables
# # ##################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  # default     = "<fill out with your api key>"
}

variable "ibm_resource_group" {
  description = "Resource group name of the IBM Cloud account."
  type        = string
}

# # ##################################################
# # # Google Cloud Variables
# # ##################################################

variable "gcp_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format."
  type        = string
}

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_resource_prefix" {
  description = "Name to be used on all gcp resource as prefix"
  type        = string

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,25}$", var.gcp_resource_prefix))
    error_message = "Sorry, gcp_resource_prefix must be between 1 and 25 characters, contain uppercase or lowercase characters, numbers, or hyphens."
  }
}


# # ##################################################
# # # IBMCLOUD Satellite Location Variables
# # ##################################################

variable "ibm_satellite_regions" {
  description = "A map of IBM Cloud satellite regions" 
  type = map(
    object(
      {
        location                  = string
        is_location_exist         = bool
        location_zones            = list(string)
        location_bucket           = string
        cos_bucket_region         = string
        satellite_core_os_enabled = bool
      }
    )
  )
  default = {}

  validation {
    condition     = can([for instance in var.ibm_satellite_regions : instance.location])
    error_message = "Each IBM Cloud Satellite region should have a location."
  }
  validation {
    condition     = can([for instance in var.ibm_satellite_regions : instance.location_bucket])
    error_message = "Each IBM Cloud Satellite region should have a location_bucket."
  }
  validation {
    condition     = can([for instance in var.ibm_satellite_regions : instance.cos_bucket_region])
    error_message = "Each IBM Cloud Satellite region should have a cos_bucket_region."
  }
}

# # ##################################################
# # # Labels
# # ##################################################
variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "control_plane_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.control_plane_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "storage_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.storage_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "worker_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.worker_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "debug_host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.debug_host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

#------------------------------------------------------------------------------------------
# There is a bug with Google zones if zone is left null and count was more than 3  
# We now define each host in a variables file with zone specified 
#------------------------------------------------------------------------------------------
variable "control_plane_hosts" {
  description = "A map of GCP host objects used to create the location control plane, including instance_type, zone and a unique host id"
  type = map(
    object(
      {
        managed_from        = string
        instance_type       = string
        zone                = string
        gcp_shared_network  = string
        gcp_subnet          = string
        sa_email            = string
        image_project       = string
        image_family        = string
        source_image        = string
        serial_port_enabled = bool 
      }
    )
  )
  default = {}

  validation {
    condition     = length(var.control_plane_hosts) % 3 == 0
    error_message = "Control plane hosts should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.managed_from])
    error_message = "Each object should have a managed_from."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts: host.gcp_shared_network])
    error_message = "Each host should have a gcp_shared_network."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.gcp_subnet])
    error_message = "Each host should have a subnet."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.sa_email])
    error_message = "Each host should have service account email. This is the service account email owner attached to the vm template / vm server."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.image_project])
    error_message = "Each host should have a image_project."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.image_family])
    error_message = "Each host should have a image_family."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.source_image])
    error_message = "Each host should have a source_image. If you want the latest, set source_image=\"\" in your vars file and set the image_family variable."
  }
  validation {
    condition     = can([for host in var.control_plane_hosts : host.serial_port_enabled])
    error_message = "Each host should have a serial_port_enabled true or false value."
  }
}

#------------------------------------------------------------------------------------------
# Same strategy as above but these hosts will have 2 disks added to them
# one for OpenShift data, the otehr for ODF
#------------------------------------------------------------------------------------------
variable "storage_hosts" {
  description = "A map of GCP host objects used to create storage hosts and attach to location"
  type = map(
    object(
      {
        managed_from        = string
        instance_type       = string
        zone                = string
        gcp_shared_network  = string
        gcp_subnet          = string
        sa_email            = string
        image_project       = string
        image_family        = string
        source_image        = string
        serial_port_enabled = bool 
      }
    )
  )
  default = {}

  validation {
    condition     = length(var.storage_hosts) >= 3
    error_message = "Storage hosts should have at least 3 hosts, one in each zone"
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.managed_from])
    error_message = "Each object should have a managed_from."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.gcp_shared_network])
    error_message = "Each host should have a gcp_shared_network."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.gcp_subnet])
    error_message = "Each host should have a subnet."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.sa_email])
    error_message = "Each host should have service account email. This is the service account email owner attached to the vm template / vm server."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.image_project])
    error_message = "Each host should have a image_project."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.image_family])
    error_message = "Each host should have a image_family."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.source_image])
    error_message = "Each host should have a source_image. If you want the latest, set source_image=\"\" in your vars file and set the image_family variable."
  }
  validation {
    condition     = can([for host in var.storage_hosts : host.serial_port_enabled])
    error_message = "Each host should have a serial_port_enabled true or false value."
  }
}

#------------------------------------------------------------------------------------------
# Same strategy as above but these hosts will have 1 disk added to them
# for OpenShift data
#------------------------------------------------------------------------------------------
variable "worker_odf_disk_size" {
  description = "Size of ODF data disk to attach"
  type        = number
}

variable "worker_hosts" {
  description = "A map of GCP host objects used for provisioning services on your location after setup, including instance_type and count."
  type = map(
    object(
      {
        managed_from        = string
        instance_type       = string
        zone                = string
        gcp_shared_network  = string
        gcp_subnet          = string
        sa_email            = string
        image_project       = string
        image_family        = string
        source_image        = string
        serial_port_enabled = bool 
      }
    )
  )
  default = {}

  validation {
    condition     = length(var.worker_hosts) >= 3
    error_message = "Additional hosts should have at least 3 hosts, one in each zone"
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.managed_from])
    error_message = "Each object should have a managed_from."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.gcp_shared_network])
    error_message = "Each host should have a gcp_shared_network."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.gcp_subnet])
    error_message = "Each host should have a subnet."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.sa_email])
    error_message = "Each host should have service account email. This is the service account email owner attached to the vm template / vm server."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.image_project])
    error_message = "Each host should have a image_project."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.image_family])
    error_message = "Each host should have a image_family."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.source_image])
    error_message = "Each host should have a source_image. If you want the latest, set source_image=\"\" in your vars file and set the image_family variable."
  }
  validation {
    condition     = can([for host in var.worker_hosts : host.serial_port_enabled])
    error_message = "Each host should have a serial_port_enabled true or false value."
  }
}

variable "debug_hosts" {
  description = "A map of GCP host objects used for provisioning services on your location after setup, including instance_type and count."
  type = map(
    object(
      {
        managed_from        = string
        instance_type       = string
        zone                = string
        gcp_shared_network  = string
        gcp_subnet          = string
        sa_email            = string
        image_project       = string
        image_family        = string
        source_image        = string
        serial_port_enabled = bool 
      }
    )
  )
  default = {}

  validation {
    condition     = can([for host in var.debug_hosts : host.managed_from])
    error_message = "Each object should have a managed_from."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.gcp_shared_network])
    error_message = "Each host should have a gcp_shared_network."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.gcp_subnet])
    error_message = "Each host should have a subnet."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.sa_email])
    error_message = "Each host should have service account email. This is the service account email owner attached to the vm template / vm server."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.image_project])
    error_message = "Each host should have a image_project."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.image_family])
    error_message = "Each host should have a image_family."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.source_image])
    error_message = "Each host should have a source_image. If you want the latest, set source_image=\"\" in your vars file and set the image_family variable."
  }
  validation {
    condition     = can([for host in var.debug_hosts : host.serial_port_enabled])
    error_message = "Each host should have a serial_port_enabled true or false value."
  }
}

variable "ssh_public_key" {
  description = "SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type        = string
  default     = null
}

variable "gcp_ssh_user" {
  description = "SSH User of above provided ssh_public_key"
  type        = string
  default     = null
}

variable "TF_VERSION" {
  description = "Terraform version"
  type        = string
  default     = "0.13"
}
