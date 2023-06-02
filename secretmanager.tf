/*
resource "google_secret_manager_secret" "deploy_key" {
  depends_on = [
    google_project_service.service_project_computeapi, 
  ]

  secret_id = "jkwng-gitlab-runner-deploy-key"
  project = data.google_project.service_project.project_id

  replication {
    automatic = true
  }

}

resource "google_secret_manager_secret_iam_member" "gitlab_runner_secret_reader" {
  project = data.google_project.service_project.project_id
  member = format("serviceAccount:%s", google_service_account.gitlab_runner.email)
  role = "roles/secretmanager.secretAccessor"
  secret_id = google_secret_manager_secret.deploy_key.id
}
*/