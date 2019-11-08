// Create a default project
module "my-project" {
  source  = "minnowpod/terraform-google-project"
  version = "~> 0.2.0"

  // these can also be passed from the environment with TF_VAR_billing_account, for example
  billing_account = "bar"
  host_dns_zone   = "my-host-dns-zone"
  host_project    = "my-host-project"
  organization_id = "foo"

  // override the generated display name
  display_name = "Yoyodyne Propulsion Systems"

  // enable some additional APIs
  enable_apis = [
    "bigquery-json.googleapis.com",
    "cloudbilling.googleapis.com",
    "compute.googleapis.com",
    "dns.googleapis.com",
    "ml.googleapis.com"
  ]
}

// Add an additional VPC network
module "another-vpc" {
  source  = "minnowpod/terraform-google-project//modules/vpc"
  version = "~> 0.2.0"

  // but skip the SSH firewall rule on this one
  create_ssh_fw_rule = "false"
  host_dns_zone      = "${module.my-project.host_dns_zone}"
  host_project       = "${my-host-project-id}"
  project_id         = "${module.my-project.id}"
}