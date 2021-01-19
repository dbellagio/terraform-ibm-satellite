##################################################
# IBMCLOUD Satellite Location and Host Variables
##################################################
variable "location_zone" {
  description = "zone of the satellite location. Currently available in washing DC and London Zones."
  default     = "wdc06"
}
variable "location_name" {
  description = "Location Name"
  default     = "satellite-ibm"
}
variable "labels" {
  description = "Label to create location"
  default     = "prod=true"
}

#################################################################################################
# IBMCLOUD Authentication and Target Variables.
# The region variable is common across zones used to setup VSI Infrastructure and Satellite host.
#################################################################################################

variable "ibmcloud_api_key" {
  description = "IBM Cloud API Key"
}
variable "region" {
  description = "Region of the IBM Cloud account"
  default     = "us-east"
}
variable "resource_group" {
  description = "Name of the resource group on which location has to be created"
  default     = "Default"
}

##################################################
# IBMCLOUD VPC VSI Variables
##################################################

variable "is_prefix" {
  description = "Prefix to the Names of the VPC Infrastructure resources"
  type        = string
  default="ibm-satellite-vsi"
}
variable "public_key" {
  description="SSH Public Key. Get your ssh key by running `ssh-key-gen` command"
  type = string
}
