resource "google_project_organization_policy" "allowAllDomainsIam" {
  project    = module.service_project.project_id
  constraint = "constraints/iam.allowedPolicyMemberDomains"

  list_policy {
    allow {
      all = true
    }
  }

}