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

resource "google_service_account" "pgadmin_sa" {
  project       = module.service_project.project_id
  account_id    = "pgadmin-sa"
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

resource "google_cloud_run_v2_service_iam_policy" "noauth_pgadmin" {
  location    = var.subnet_region
  project     = module.service_project.project_id
  name     = google_cloud_run_v2_service.pgadmin.name

  policy_data = data.google_iam_policy.noauth.policy_data
}

resource "google_cloud_run_v2_service" "pgadmin" {

  depends_on = [
    google_secret_manager_secret_iam_member.pgadmin_secret,
  ]

  project  = module.service_project.project_id
  name     = "pgadmin-${random_id.random_suffix.hex}"
  location = var.subnet_region

  ingress = "INGRESS_TRAFFIC_ALL"

  template {
    scaling {
      max_instance_count = 1
    }

    volumes {
      name = "cloudsql"
      cloud_sql_instance {
        instances = [google_sql_database_instance.db.connection_name]
      }
    }

    volumes {
      name = "server-json"
      secret {
        secret = google_secret_manager_secret.pgadmin_server_json.secret_id
        default_mode = 292
        items {
          version = google_secret_manager_secret_version.pgadmin_server_json.version
          path = "server.json"
          mode = 256
        }
      }
    }


    containers {
      image = var.pgadmin_image
      ports { 
        container_port = 80
      }
      env {
        name = "BUCKET"
        value = google_storage_bucket.pgadmin_data.name
      }
      env {
        name = "PGADMIN_DEFAULT_EMAIL"
        value = "admin@example.com"
      }
      env {
        name = "PGADMIN_DEFAULT_PASSWORD"
        value = "s3cret"
      }
      env {
        name = "PGADMIN_LISTEN_PORT"
        value = "80"
      }
      env {
        name = "PGADMIN_SERVER_JSON_FILE"
        value = "/secret/server.json"
      }
      resources {
        startup_cpu_boost = true
      }
      volume_mounts {
        name = "cloudsql"
        mount_path = "/cloudsql"
      }
      volume_mounts {
        name = "server-json"
        mount_path = "/secret"
      }
    }

    service_account = google_service_account.pgadmin_sa.email
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

resource "google_secret_manager_secret" "pgadmin_server_json" {
  secret_id = "pgadmin-server-json"
  project = module.service_project.project_id

  replication {
    automatic = true
  }

}

resource "google_secret_manager_secret_version" "pgadmin_server_json" {
  secret = google_secret_manager_secret.pgadmin_server_json.id
  secret_data = <<EOT
{
    "Servers": {
        "1": {
            "Name": "cloudsql",
            "Group": "Servers",
            "Port": 5432,
            "Username": "${google_sql_user.db.name}",
            "PassFile": "/var/lib/pgadmin/pgadmin-pass",
            "Host": "/cloudsql/${google_sql_database_instance.db.connection_name}",
            "SSLMode": "disable",
            "MaintenanceDB": "postgres"
        }
    }
}
EOT

}

resource "google_secret_manager_secret_iam_member" "pgadmin_secret" {
  project = module.service_project.project_id
  secret_id = google_secret_manager_secret.pgadmin_server_json.secret_id
  role = "roles/secretmanager.secretAccessor"
  member = "serviceAccount:${google_service_account.pgadmin_sa.email}"
}