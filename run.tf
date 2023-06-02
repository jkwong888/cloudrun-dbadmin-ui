data "google_iam_policy" "noauth" {
  binding {
    role = "roles/run.invoker"
    members = [
      "allUsers",
    ]
  }
}

resource "google_cloud_run_v2_service_iam_policy" "noauth" {
  location    = var.subnet_region
  project     = module.service_project.project_id
  name     = google_cloud_run_v2_service.redisinsight.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_service_account" "redisinsight_sa" {
  project       = module.service_project.project_id
  account_id    = "redisinsight-sa"
}


resource "google_cloud_run_v2_service" "redisinsight" {
  project  = module.service_project.project_id
  name     = "redisinsight-${random_id.random_suffix.hex}"
  location = var.subnet_region

  ingress = "INGRESS_TRAFFIC_INTERNAL_LOAD_BALANCER"

  template {
    scaling {
      max_instance_count = 1
    }
    containers {
      image = var.redisinsight_image
      ports { 
        container_port = 5000
      }
      env {
        name = "BUCKET"
        value = google_storage_bucket.redisinsight_data.name
      }
      resources {
        startup_cpu_boost = true
      }
    }
    service_account = google_service_account.redisinsight_sa.email
    execution_environment  = "EXECUTION_ENVIRONMENT_GEN2"
      vpc_access{
        connector = google_vpc_access_connector.connector.id
        egress = "ALL_TRAFFIC"
      }

  }
      traffic {
        type = "TRAFFIC_TARGET_ALLOCATION_TYPE_LATEST"
        percent = 100
      }

}

