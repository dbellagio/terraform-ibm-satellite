data "ibm_resource_group" "res_group" {
  name = var.resource_group
}

resource "ibm_satellite_location" "create_location" {
  count = var.is_location_exist == false ? 1 : 0

  location          = var.location
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

data "ibm_satellite_attach_host_script" "script" {
  location      = data.ibm_satellite_location.location.id
  labels        = (var.host_labels != null ? var.host_labels : null)
 # host_provider = var.host_provider
  custom_script = <<EOF
  set +e
  date=`date`

  cmd=`grep user1 /etc/passwd`
  status=$?
  if [ $status -ne 0 ]
  then
    echo
    echo "[$date] - Executing code to enable serial port, add RHEL package updates, and add a user to use to login to the hosts"
    echo

    # Turn on serial port and enable
    systemctl start serial-getty@ttyS1.service
    systemctl enable serial-getty@ttyS1.service

    # Add user to login to host as (change password if needed)
    useradd -m user1
    echo passw0rd | passwd user1 --stdin
    usermod -aG wheel user1
    usermod -aG google-sudoers user1

    # Enable GCP RHEL package updates
    yum update --disablerepo=* --enablerepo="*" -y
    yum repolist all
    yum install container-selinux -y
    yum install subscription-manager -y
  else
    echo
    echo "[$date] - Already executed commands to enable serial port, add RHEL subscription, and add a user"
    echo
  fi
  set -e
EOF
}
