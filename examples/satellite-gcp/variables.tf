# # ##################################################
# # # GCP and IBM Authentication Variables
# # ##################################################

variable "gcp_project" {
  description = "GCP Project ID"
  type        = string
}

variable "gcp_shared_network" {
  description = "GCP Shared VPC Network (rather than creating your own VPC)"
  type        = string
  # default   = "projects/<GCP Project ID>/global/networks/<GCP Shared Network Name>"
}

variable "gcp_subnet" {
  description = "GCP selflink to the subnet"
  type        = string
  # default     = "projects/<GCP Project ID>/regions/<GCP Region>/subnetworks/<GCP Subnet>"
}

variable "gcp_region" {
  description = "Google Region"
  type        = string
  # default     = "us-central1"
}
variable "gcp_credentials" {
  description = "Either the path to or the contents of a service account key file in JSON format."
  type        = string
  # default     = "./serviceKey.json"
}

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
  type        = string
  # default     = "<fill out with your api key>"
}

variable "ibm_resource_group" {
  description = "Resource group name of the IBM Cloud account."
  type        = string
  # default     = "<IBM Cloud resource group - case sensitive>"
}

variable "worker_odf_disk_size" {
  description = "Size of ODF data disk to attach"
  type        = number
  # default     = 1800
}

# # ##################################################
# # # Google Resources Variables
# # ##################################################

variable "gcp_resource_prefix" {
  description = "Name to be used on all gcp resource as prefix"
  type        = string
  # default     = "satellite-google"

  validation {
    condition     = can(regex("^[a-zA-Z0-9-]{1,25}$", var.gcp_resource_prefix))
    error_message = "Sorry, gcp_resource_prefix must be between 1 and 25 characters, contain uppercase or lowercase characters, numbers, or hyphens."
  }
}

#------------------------------------------------------------------------------------------
# There is a bug with Google zones if zone is left null and count was more than 3  
# We now define each host in a variables file with zone specified 
# we now only use count of 1 in the locals.tf file to allow for easy Terraform host removal
#------------------------------------------------------------------------------------------
variable "cp_hosts" {
  description = "A map of GCP host objects used to create the location control plane, including instance_type, zone and a unique host id"
  type = list(
    object(
      {
        instance_type  = string
        zone           = string
        unique_host_id = string
        attach_script  = string
      }
    )
  )
  default = []

  validation {
    condition     = length(var.cp_hosts) % 3 == 0
    error_message = "Control plane hosts should always be in multiples of 3, such as 6, 9, or 12 hosts."
  }

  validation {
    condition     = can([for host in var.cp_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.cp_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.cp_hosts : host.unique_host_id])
    error_message = "Each object should have a unique_host_id."
  }

}

#------------------------------------------------------------------------------------------
# Same strategy as above but these hosts will have 2 disks added to them
# one for OpenShift data, the otehr for ODF
#------------------------------------------------------------------------------------------
variable "storage_hosts" {
  description = "A map of GCP host objects used to create storage hosts and attach to location"
  type = list(
    object(
      {
        instance_type   = string
        zone            = string
        unique_host_id  = string
        attach_script  = string
      }
    )
  )
  default = []

  validation {
    condition     = length(var.storage_hosts) >= 3
    error_message = "Storage hosts should have at least 3 hosts, one in each zone"
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
    condition     = can([for host in var.storage_hosts : host.unique_host_id])
    error_message = "Each object should have a unique_host_id."
  }

}

#------------------------------------------------------------------------------------------
# Same strategy as above but these hosts will have 1 disk added to them
# for OpenShift data
#------------------------------------------------------------------------------------------
variable "addl_hosts" {
  description = "A list of GCP host objects used for provisioning services on your location after setup, including instance_type and count."
  type = list(
    object(
      {
        instance_type = string
        zone            = string
        unique_host_id  = string
        attach_script  = string
      }
    )
  )
  default = []

  validation {
    condition     = length(var.addl_hosts) >= 3
    error_message = "Additional hosts should have at least 3 hosts, one in each zone"
  }

  validation {
    condition     = can([for host in var.addl_hosts : host.instance_type])
    error_message = "Each object should have an instance_type."
  }
  validation {
    condition     = can([for host in var.addl_hosts : host.zone])
    error_message = "Each object should have a zone."
  }
  validation {
    condition     = can([for host in var.addl_hosts : host.unique_host_id])
    error_message = "Each object should have a unique_host_id."
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

# # ##################################################
# # # IBMCLOUD Satellite Location Variables
# # ##################################################

variable "location" {
  description = "Location Name"
  # default     = "satellite-gcp"

  validation {
    condition     = var.location != "" && length(var.location) <= 32
    error_message = "Sorry, please provide value for location_name variable or check the length of name it should be less than 32 chars."
  }
}

variable "is_location_exist" {
  description = "Determines if the location has to be created or not"
  type        = bool
  default     = false
}

variable "managed_from" {
  description = "The IBM Cloud region to manage your Satellite location from. Choose a region close to your on-prem data center for better performance."
  type        = string
  # default     = "dal"
}

variable "location_zones" {
  description = "Allocate your hosts across these three zones"
  type        = list(string)
  # default   = ["us-central1-a", "us-central1-b", "us-central1-c"]
}

variable "location_bucket" {
  description = "COS bucket name"
  type        = string
  default     = ""
}

variable "ibm_region" {
  description = "COS region in IBM cloud"
  type        = string
  default     = ""
}

variable "host_labels" {
  description = "Labels to add to attach host script"
  type        = list(string)
  default     = []

  validation {
    condition     = can([for s in var.host_labels : regex("^[a-zA-Z0-9:]+$", s)])
    error_message = "Label must be of the form `key:value`."
  }
}

variable "worker_image_project" {
  description = "Operating system image project for the workers created"
  type        = string
  default     = "rhel-cloud"
}

variable "worker_image_family" {
  description = "Operating system image family for the workers created"
  type        = string
  default     = "rhel-8"
}

variable "TF_VERSION" {
  description = "Terraform version"
  type        = string
  default     = "0.13"
}