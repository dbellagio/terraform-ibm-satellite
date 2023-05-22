data "ibm_resource_group" "res_group" {
  name = var.resource_group
}

resource "ibm_satellite_location" "create_location" {
  count = var.is_location_exist == false ? 1 : 0

  location          = var.location
  coreos_enabled    = var.coreos_enabled
  managed_from      = var.managed_from
  zones             = (var.location_zones != null ? var.location_zones : null)
  resource_group_id = data.ibm_resource_group.res_group.id

  cos_config {
    bucket = (var.location_bucket != null ? var.location_bucket : null)
    region = (var.ibm_region != null ? var.ibm_region : null)
  }
}

data "ibm_satellite_location" "location" {
  location   = var.location
  depends_on = [ibm_satellite_location.create_location]
}

data "ibm_satellite_attach_host_script" "control_plane_script" {
  location      = data.ibm_satellite_location.location.id
  labels        = (var.control_plane_host_labels != null ? concat(var.host_labels, var.control_plane_host_labels) : var.host_labels)

  #host_provider = var.host_provider
  custom_script = <<EOF
EOF
}

data "ibm_satellite_attach_host_script" "storage_script" {
  location      = data.ibm_satellite_location.location.id
  labels        = (var.storage_host_labels != null ? concat(var.host_labels, var.storage_host_labels) : var.host_labels)

  # host_provider = var.host_provider
  custom_script = <<EOF
EOF
}

data "ibm_satellite_attach_host_script" "worker_script" {
  location      = data.ibm_satellite_location.location.id
  labels        = (var.worker_host_labels != null ? concat(var.host_labels, var.worker_host_labels) : var.host_labels)

  # host_provider = var.host_provider
  custom_script = <<EOF
EOF
}

data "ibm_satellite_attach_host_script" "debug_script" {
  location      = data.ibm_satellite_location.location.id
  labels        = (var.debug_host_labels != null ? concat(var.host_labels, var.debug_host_labels) : var.host_labels)

  # host_provider = var.host_provider
  custom_script = <<EOF
  set +e
  date=`date`

  cmd=`grep user1 /etc/passwd`
  status=$?
  if [ $status -ne 0 ]
  then
    echo "======================================================================================================================================="
    echo ""
    echo "Using debug attach_host script"
    echo ""
    echo "[$date] - Executing code to enable serial port, add a user to use to login to the host, add user to sshd_config and restart ssh service"
    echo "======================================================================================================================================="

    # Turn on serial port and enable
    systemctl start serial-getty@ttyS1.service
    systemctl enable serial-getty@ttyS1.service

    # Add user to login to host as (change password if needed)
    useradd -m user1
    echo passw0rd | passwd user1 --stdin
    usermod -aG wheel user1
    usermod -aG google-sudoers user1

    if grep 'AllowUsers root' /etc/ssh/sshd_config
    then
      # this should change all lines in the /etc/ssh/sshd_config file to -> AllowUsers root user1
      sed -i '' -e 's/AllowUsers root/AllowUsers root user1/g' /etc/ssh/sshd_config
      echo
      echo "[$date] - Restarting ssh.service"
      echo
      systemctl restart sshd
    else
      echo
      echo "[$date] - Could not find AllowUsers root in file /etc/ssh/sshd_config. Adding user1 to Allow users."
      #cat /etc/ssh/sshd_config
      echo "AllowUsers user1" >> /etc/ssh/sshd_config
      #cat /etc/ssh/sshd_config
      echo "[$date] - Restarting sshd"
      systemctl restart sshd
    fi
  else
    echo
    echo "[$date] - Already executed commands to enable serial port, add RHEL subscription, and add a user, and restart ssh service"
    echo
  fi
  set -e
EOF
}
