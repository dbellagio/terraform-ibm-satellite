#---------------------------------
# Variables for dev environment
#---------------------------------
gcp_credentials = "./serviceKey.json"
ibmcloud_api_key = "<your API-Key>"
ibm_resource_group = "<your resource group>"

gcp_project = "<your GCP Project>"
gcp_region = "us-central1"

gcp_shared_network = "projects/<global network project>/global/networks/<your shared networkt>"
gcp_subnet = "projects/<global network project>/regions/us-central1/subnetworks/<your subnet>"

#---------------------------------------
# For deployment to dev
#---------------------------------------
gcp_resource_prefix = "dev-sat-google"

#---------------------------------
# Satellite location name
#---------------------------------
location = "sat-dev-gcp-was"
is_location_exist = false

#--------------------------------------
# Satellite location region in us-south
#--------------------------------------
managed_from = "dal"

#------------------------------------------------------------------------
# Satellite control plane zones in GCP, must match host zones used below
#------------------------------------------------------------------------
location_zones = ["us-central1-a", "us-central1-b", "us-central1-c"]

#------------------------------------------------------------------------
# Satellite COS bucket in IBM cloud to use for etc db backup
#------------------------------------------------------------------------
location_bucket = "<your COS bucket for Sat location>"

#------------------------------------------------------------------------
# Custom host labels to apply on the Satellite hosts that are created
# in addition to the auto-applied lablels (cpu, mem, os)
#------------------------------------------------------------------------
host_labels = ["env:dev","tech:was"]
storage_host_labels = ["type:storage"]
worker_host_labels = ["type:worker"]
control_plane_host_labels = ["type:cp"]
debug_host_labels = ["type:debug"]

#---------------------------------
# Size of ODF storage disk to add
# to storage hosts
#---------------------------------
worker_odf_disk_size = 1800

#---------------------------------
# Control plane hosts
# No added disks on these hosts
#---------------------------------
control_plane_hosts = {
  #-------------------
  # Zone us-central1-a
  #-------------------
  cp-000 = {
     instance_type   = "n2-standard-4"
      zone            = "us-central1-a"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
  },
  cp-003 = {
      instance_type   = "n2-standard-4"
      zone            = "us-central1-a"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
   },
  #-------------------
  # Zone us-central1-b
  #-------------------
  cp-001 = {
      instance_type   = "n2-standard-4"
      zone            = "us-central1-b"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
  cp-004 = {
      instance_type   = "n2-standard-4"
      zone            = "us-central1-b"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
  #-------------------
  # Zone us-central1-c
  #-------------------
  cp-002 = {
      instance_type   = "n2-standard-4"
      zone            = "us-central1-c"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
  cp-005 = {
      instance_type   = "n2-standard-4"
      zone            = "us-central1-c"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    }
}

#---------------------------------
# Storage hosts
# Will have OCP data disk added 
# and ODF storage disk added
#---------------------------------
storage_hosts = {
    #-------------------
    # Zone us-central1-a
    #-------------------
    st-100 = {
      instance_type   = "n2-standard-16"
      zone            = "us-central1-a"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    #-------------------
    # Zone us-central1-b
    #-------------------
    st-101 = {
      instance_type   = "n2-standard-16"
      zone            = "us-central1-b"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    #-------------------
    # Zone us-central1-c
    #-------------------
    st-102 = {
      instance_type   = "n2-standard-16"
      zone            = "us-central1-c"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
  }
}

#---------------------------------
# Worker hosts
# Will have OCP data disk added
#---------------------------------
worker_hosts = {
    #-------------------
    # Zone us-central1-a
    #-------------------
    wk-200 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-a"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    wk-203 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-a"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    #-------------------
    # Zone us-central1-b
    #-------------------
    wk-201 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-b"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    wk-204 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-b"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
   },
    #-------------------
    # Zone us-central1-c
    #-------------------
    wk-202 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-c"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    },
    wk-205 = {
      instance_type   = "n2-standard-8"
      zone            = "us-central1-c"
      service_account = "project_sa@gmail.com"
      #---------------------------------
      # OS to load on the hosts
      #---------------------------------
      image_project = "rhel-cloud"
      image_family = "rhel-8"
      source_image = "<specific-image-to-load>"
    }
}

