data "google_project" "host_project" {
  project_id = var.shared_vpc_host_project_id
}

resource "random_id" "random_suffix" {
  byte_length = 2
}

data "google_compute_network" "shared_vpc" {
  name    =  var.shared_vpc_network
  project = data.google_project.host_project.project_id
}

module "service_project" {
  source = "git@github.com:jkwong888/tf-gcp-service-project.git"
  #source = "../jkwng-tf-service-project-gke"

  billing_account_id          = var.billing_account_id
  shared_vpc_host_project_id  = var.shared_vpc_host_project_id
  shared_vpc_network          = var.shared_vpc_network
  project_id                  = var.billing_account_id != "" ? format("%s-%s", var.service_project_id, random_id.random_suffix.hex) : var.service_project_id

  apis_to_enable              = local.service_apis_to_enable

  subnets                     = [
    {
        name = var.subnet_name
        primary_range = var.subnet_primary_range
        region = var.subnet_region
        secondary_range = {}
    }
  ]

  #subnet_users                = [google_service_account.gke_sa.email]
  skip_delete = false
}

locals {
  host_apis_to_enable = [
    "container.googleapis.com",
    "compute.googleapis.com",
  ]
  service_apis_to_enable = [
    "compute.googleapis.com",
    "secretmanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "iap.googleapis.com",
    "servicenetworking.googleapis.com",
    "run.googleapis.com",
  ]

}

resource "google_project_service" "vpcaccess_adminapi" {
  project       = data.google_project.host_project.project_id
  service                    = "vpcaccess.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_vpc_access_connector" "connector" {
  depends_on = [
    google_project_service.vpcaccess_adminapi,
  ]
  project       = data.google_project.host_project.project_id
  name          = "vpcconn"
  region        = var.subnet_region
  ip_cidr_range = "10.210.0.0/28"
  network       = data.google_compute_network.shared_vpc.name
}