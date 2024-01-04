


# take the GKE SA and allow storage object browser on the image registry bucket
resource "google_project_iam_member" "vpc_connector_use" {
    project = data.google_project.host_project.project_id
    role    = "roles/vpcaccess.user"
    member  = "serviceAccount:service-${module.service_project.number}@serverless-robot-prod.iam.gserviceaccount.com"
}

