resource "google_storage_bucket" "redisinsight_data" {
  project       = module.service_project.project_id
  name          = "redisinsight-data"
  location      = var.subnet_region

    uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "redisinsight_storage_admin" {
  bucket = google_storage_bucket.redisinsight_data.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.redisinsight_sa.email}"
}

resource "google_storage_bucket" "pgadmin_data" {
  project       = module.service_project.project_id
  name          = "pgadmin-data"
  location      = var.subnet_region

    uniform_bucket_level_access = true
}

resource "google_storage_bucket_iam_member" "pgadmin_storage_admin" {
  bucket = google_storage_bucket.pgadmin_data.name
  role = "roles/storage.admin"
  member = "serviceAccount:${google_service_account.pgadmin_sa.email}"
}