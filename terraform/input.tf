variable "project_id" {
    type = string
}

variable "instances" {
  type = map(object({
    machine_type = string
	zone  = string
	description = string
   }))
}

variable "service_account" {
    type = string
    default = ""
}

variable "scopes" {
    type = list(string)
    default = []
}

# New Code

# Creating a set of VM instances based on the map supplied by the "instances" variable.
resource "google_compute_instance" "vm_instance" {
  for_each = var.instances
# resource name is set to each key from the "instances" map, machine type, zone, and description are set from the properties of the map values.

  name         = each.key # Set the resource name from the map keys
  machine_type = each.value.machine_type
  zone         = each.value.zone
  description  = each.value.description

  boot_disk {
    initialize_params {
      image = "Required_Image" # Image name ex: hpc-centos-7 or hpc-rocky-linux-8
    }
  }

# Defining VPC Networks
  network_interface {
    network = "default" # I need to give Network name here
  }

  metadata = {
    # Here I need to set the metadata
  }

  service_account {
    email = var.service_account != "" ? var.service_account : null
    scopes = var.scopes != [] ? var.scopes : null
  }

  # Hostname is set using a metadata startup script that constructs the hostname, combining the instance name and the zone with a hyphen and the DNS suffix
  metadata_startup_script = <<-EOF
    #!/bin/bash
    hostnamectl set-hostname "${each.key}-${each.value.zone}.asx.com.au"
  EOF
}

