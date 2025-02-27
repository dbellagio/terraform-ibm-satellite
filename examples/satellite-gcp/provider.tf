provider "google" {
  project     = var.gcp_project
  credentials = var.gcp_credentials
}
provider "google-beta" {
  project     = var.gcp_project
  credentials = var.gcp_credentials
}
provider "ibm" {
  ibmcloud_api_key = var.ibmcloud_api_key
}
