locals {

  # combine cp_hosts and addl_hosts into a map so we can use for_each later
  # support backwards compatibility with providing var.instance_type, satellite_host_count, and addl_host_count

  # removed the backward compatibility code as it was more confusing and we are not using it
  hosts = merge({
      for host_cp in var.cp_hosts :
      host_cp.unique_host_id => {
        instance_type     = host_cp.instance_type
        count             = 1
        for_control_plane = true
        additional_disks  = []
        zone              = host_cp.zone
      }
      }, {
      for host_storage in var.storage_hosts :
      host_storage.unique_host_id => {
        instance_type     = host_storage.instance_type
        count             = 1
        for_control_plane = false
        zone              = host_storage.zone
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-roks-${host_storage.unique_host_id}"
            disk_name = "${var.gcp_resource_prefix}-roks-${host_storage.unique_host_id}"
            disk_labels = {type = "forroks"}
          },{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = var.worker_odf_disk_size
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-osd-${host_storage.unique_host_id}"
            disk_name = "${var.gcp_resource_prefix}-osd-${host_storage.unique_host_id}"
            disk_labels = {type = "osd"}
          }]
      }
      }, {
      for host_addl in var.addl_hosts :
      host_addl.unique_host_id => {
        instance_type     = host_addl.instance_type
        count             = 1
        for_control_plane = false
        zone              = host_addl.zone
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-roks-${host_addl.unique_host_id}"
            disk_name = "${var.gcp_resource_prefix}-roks-${host_addl.unique_host_id}"
            disk_labels = {type = "forroks"}
        }]
      }
  })
}
