# Defining a Google Instance and its attributes
resource "google_compute_instance" "vm" {
    project = var.project_id
    name = var.instance_name
    description = var.description
    machine_type = var.machine_type
    zone = var.zone
    hostname = var.hostname
/* 
a) Dynamic block definition for configuring the service account for the instance.
b) Using for each to conditionally include  the service_account block.
c) Setting up the email of the service account from the input variable - var.service_account
d) Setting up the scope for the service account from the input variable - var.scopes 
*/ 

    dynamic service_account {

        for_each = var.service_account != "" ? [1] : []
        content {
            email = var.service_account
            scopes = var.scopes
        }
    }
}
