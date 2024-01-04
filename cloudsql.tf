resource "google_project_service" "cloudsql_adminapi" {
  project                    = module.service_project.project_id
  service                    = "sqladmin.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}

resource "google_sql_database_instance" "db" {
  depends_on = [
    google_project_service.cloudsql_adminapi,
    //google_service_networking_connection.private_service_connection,
  ]

  name                  = "${var.instance_name}-14-${random_id.random.hex}"
  database_version      = "POSTGRES_15"
  region                = var.subnet_region
  project               = module.service_project.project_id
  deletion_protection   = false

  settings {
    tier                = var.db_instance_type

    ip_configuration {
      ipv4_enabled      = false
      private_network   = data.google_compute_network.shared_vpc.id
    }

    insights_config {
      query_insights_enabled  = true 
      query_string_length     = 1024 
      record_application_tags = false 
      record_client_address   = false 
    }

  }
}

resource "google_sql_database" "db" {
    name = "db"
    instance = google_sql_database_instance.db.name
    project = module.service_project.project_id
}

resource "google_sql_user" "db" {
    name = "dbuser"
    instance = google_sql_database_instance.db.name
    project = module.service_project.project_id
    password = random_password.postgres_password.result
}

resource "random_password" "postgres_password" {
  length           = 16
  special          = true
  override_special = "_%@"
}

resource "google_project_iam_member" "project" {
  project = module.service_project.project_id
  role    = "roles/cloudsql.client"
  member = format("serviceAccount:%s", google_service_account.pgadmin_sa.email)
}


/*
resource "local_file" "db_secret_yaml" {
  filename = "${path.module}/../manifests/secret-postgres-password.yaml"
  content = templatefile("${path.module}/templates/secret-postgres-password.yaml.tpl",
    {
        password = random_password.postgres_password.result,
    }
  )
}
*/

output "db_ip" {
  value = google_sql_database_instance.db.first_ip_address
}

output "db_port" {
  value = 5432
}

output "db_username" {
    value = google_sql_user.db.name
}

output "db_password" {
    value = random_password.postgres_password.result
    sensitive = true
}

output "db_connection_string" {
    value = google_sql_database_instance.db.connection_name
}

output "db_name" {
  value = google_sql_database.db.name
}

resource "google_secret_manager_secret" "cloudsql_password" {
  secret_id = "cloudsql-pasword"
  project = module.service_project.project_id

  replication {
    automatic = true
  }
}

resource "google_secret_manager_secret_version" "cloudsql_password" {

  secret = google_secret_manager_secret.cloudsql_password.id
  secret_data = random_password.postgres_password.result


}

