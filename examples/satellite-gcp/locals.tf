/*

This entire file is not needed anymore if using the resource approach

locals {

  # combine cp_hosts, storage_hosts, and addl_hosts into a map so we can use for_each later
  # common stuff can go here for each host type
  # unique host attributes should go in the variables file and referenced/added here
 
  hosts = merge({
      for host_cp in var.control_plane_hosts :
      host_cp.unique_host_id => {
        instance_type     = host_cp.instance_type
        count             = 1
        for_control_plane = true
        additional_disks  = []
        zone              = host_cp.zone
        service_account   = host_cp.service_account
        attach_script     = host_cp.attach_script
        image_family     = host_cp.image_family
        image_project     = host_cp.image_project
        source_image     = host_cp.source_image
      }
      }, {
      for host_storage in var.storage_hosts :
      host_storage.unique_host_id => {
        instance_type     = host_storage.instance_type
        count             = 1
        for_control_plane = false
        zone              = host_storage.zone
        service_account   = host_storage.service_account
        attach_script     = host_storage.attach_script
        image_family     = host_storage.image_family
        image_project     = host_storage.image_project
        source_image     = host_storage.source_image

#        additional_disks = [{
#            mode = "READ_WRITE"
#            disk_type = "pd-balanced"
#            disk_size_gb = 100
#            type = "PERSISTENT"
#            boot = false
#            auto_delete = true
#            # these device names need to be unique for GCP project in each zone
#            device_name = "${var.gcp_resource_prefix}-roks-${host_storage.unique_host_id}"
#            disk_name = "${var.gcp_resource_prefix}-roks-${host_storage.unique_host_id}"
#            disk_labels = {type = "forroks"}
#          },{
#            mode = "READ_WRITE"
#            disk_type = "pd-balanced"
#            disk_size_gb = var.worker_odf_disk_size
#            type = "PERSISTENT"
#            boot = false
#            auto_delete = true
#            # these device names need to be unique for GCP project in each zone
#            device_name = "${var.gcp_resource_prefix}-osd-${host_storage.unique_host_id}"
#            disk_name = "${var.gcp_resource_prefix}-osd-${host_storage.unique_host_id}"
#            disk_labels = {type = "osd"}
#          }]

      }
      }, {
      for host_addl in var.worker_hosts :
      host_addl.unique_host_id => {
        instance_type     = host_addl.instance_type
        count             = 1
        for_control_plane = false
        zone              = host_addl.zone
        service_account   = host_addl.service_account
        attach_script     = host_addl.attach_script
        image_family     = host_addl.image_family
        image_project     = host_addl.image_project
        source_image     = host_addl.source_image

#        additional_disks = [{
#            mode = "READ_WRITE"
#            disk_type = "pd-balanced"
#            disk_size_gb = 100
#            type = "PERSISTENT"
#            boot = false
#            auto_delete = true
#            # these device names need to be unique for GCP project in each zone
#            device_name = "${var.gcp_resource_prefix}-roks-${host_addl.unique_host_id}"
#            disk_name = "${var.gcp_resource_prefix}-roks-${host_addl.unique_host_id}"
#            disk_labels = {type = "forroks"}
#        }]

      }
  })
}
*/