resource "google_iap_brand" "project_brand" {
  support_email     = var.google_iap_email
  application_title = "Cloud IAP protected Application"
  project           = module.service_project.project_id
}

resource "google_iap_client" "project_client" {
  display_name = "Test Client"
  brand        =  google_iap_brand.project_brand.name
}