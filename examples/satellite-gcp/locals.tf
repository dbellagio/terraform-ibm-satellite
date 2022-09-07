locals {

  unique_name = "${lower(var.gcp_resource_prefix)}-${lower(random_id.id.hex)}"
  disk_forroks = "${local.unique_name}-forroks"
  disk_osd = "${local.unique_name}-osd"

  # combine cp_hosts and addl_hosts into a map so we can use for_each later
  # support backwards compatibility with providing var.instance_type, satellite_host_count, and addl_host_count
  hosts = (var.satellite_host_count != null && var.addl_host_count != null && var.instance_type != null) ? {
    0 = {
      instance_type     = var.instance_type
      count             = var.satellite_host_count
      for_control_plane = true
      additional_disks = []
    }
    1 = {
      instance_type     = var.instance_type
      count             = var.addl_host_count
      for_control_plane = false
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            device_name = "${local.disk_forroks}"
            disk_name = "${local.disk_forroks}"
            disk_labels = {type = "forroks"}
          },{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = var.worker_odf_disk_size
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            device_name = "${local.disk_osd}"
            disk_name = "${local.disk_osd}"
            disk_labels = {type = "osd"}
          }]
    }
    } : merge({
      for i, host in var.cp_hosts :
      i => {
        instance_type     = host.instance_type
        count             = host.count
        for_control_plane = true
        additional_disks = []
      }
      }, {
      for i, host in var.addl_hosts :
      sum([i, length(var.cp_hosts)]) => {
        instance_type     = host.instance_type
        count             = host.count
        for_control_plane = false
        additional_disks = [{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = 100
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            device_name = "${local.disk_forroks}-${i}"
            disk_name = "${local.disk_forroks}-${i}"
            disk_labels = {type = "forroks"}
          },{
            mode = "READ_WRITE"
            disk_type = "pd-balanced"
            disk_size_gb = var.worker_odf_disk_size
            type = "PERSISTENT"
            boot = false
            auto_delete = true
            device_name = "${local.disk_osd}-${i}"
            disk_name = "${local.disk_osd}-${i}"
            disk_labels = {type = "osd"}
          }]
      }
  })
}

resource "random_id" "id" {
  byte_length = 2
}
