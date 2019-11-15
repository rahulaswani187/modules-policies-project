provider "google" {
 credentials = "${file("Terraform Project-77797bdb9a02.json")}"
 project     = "terraform-project-258803"
 region      = "australia-southeast1"
}

// Terraform plugin for creating random ids
resource "random_id" "instance_id" {
 byte_length = 8
}

// A single Google Cloud Engine instance
resource "google_compute_instance" "default" {
 name         = "flask-vm-${random_id.instance_id.hex}"
 machine_type = "f1-micro"
 zone         = "australia-southeast1-a"

 boot_disk {
   initialize_params {
     image = "debian-cloud/debian-9"
   }
 }

metadata = {
   ssh-keys = "rahul:${file("my-ssh-key.pub")}"
 }


// Make sure flask is installed on all new instances for later steps
 metadata_startup_script = "sudo apt-get update; sudo apt-get install -yq build-essential python-pip rsync; pip install flask"

 network_interface {
   network = "default"

   access_config {
     // Include this section to give the VM an external ip address
   }
 }
}

// A variable for extracting the external ip of the instance
output "ip" {
 value = "${google_compute_instance.default.network_interface.0.access_config.0.nat_ip}"
}

variable "tfe_token" {}

variable "tfe_hostname" {
    description = "TFE host domain"
    default = "ptfe-dev.woolworths.com.au"
}

variable "tfe_organization" {
    description = "Organization to apply changes to"
    default = "SOI-Platform"
}

provider "tfe" {
    hostname = "${var.tfe_hostname}"
    token = "${var.tfe_token}"
    version = "~> 0.6"
}

#resource "tfe_sentinel_policy" "gcp-restrict-machine-type" {
#  name         = "gcp-restrict-machine-type"
#  description  = "Limit GCP instances to approved list"
#  organization = "${var.tfe_organization}"
#  policy       = "${file("policy.sentinel")}"
#  enforce_mode = "soft-mandatory"
#}