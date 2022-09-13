locals {

  # combine cp_hosts and addl_hosts into a map so we can use for_each later
  # support backwards compatibility with providing var.instance_type, satellite_host_count, and addl_host_count

  # removed the backward compatibility code as it was more confusing and we are not using it
  hosts = merge({
      for i, host_cp in var.cp_hosts :
      i => {
        instance_type     = host_cp.instance_type
        count             = host_cp.count
        for_control_plane = true
        additional_disks  = []
        zone              = null
      }
      }, {
      for s, host_storage in var.storage_hosts :
      sum([s, length(var.cp_hosts)]) => {
        instance_type     = host_storage.instance_type
        count             = host_storage.count
        for_control_plane = false
        # zone = null only works if we are doing 3 in the GCP zones where they have more that 3 zones available
        zone              = null
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-roks-host-${s + 1}"
            disk_name = "${var.gcp_resource_prefix}-roks-host-${s + 1}"
            disk_labels = {type = "forroks"}
          },{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = var.worker_odf_disk_size
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-osd-host-${s + 1}"
            disk_name = "${var.gcp_resource_prefix}-osd-host-${s + 1}"
            disk_labels = {type = "osd"}
          }]
      }
      }, {
      for j, host_addl in var.addl_hosts :
      sum([j, length(var.cp_hosts), length(var.storage_hosts)]) => {
        instance_type     = host_addl.instance_type
        count             = host_addl.count
        for_control_plane = false
        # get the zone from the structure as this structure hard codes zone to work around host number being greater than 3
        zone              = host_addl.zone
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            # these device names need to be unique for GCP project in each zone
            device_name = "${var.gcp_resource_prefix}-roks-host-${j + 1 + length(var.storage_hosts)}"
            disk_name = "${var.gcp_resource_prefix}-roks-host-${j + 1 + length(var.storage_hosts)}"
            disk_labels = {type = "forroks"}
        }]
      }
  })
}
