

resource "google_project_service" "redis_api" {
  project                    = module.service_project.project_id
  service                    = "redis.googleapis.com"
  disable_on_destroy         = false
  disable_dependent_services = false
}



resource "google_redis_instance" "cache" {
  depends_on = [
      google_project_service.redis_api,
      //google_service_networking_connection.private_service_connection,
  ]

  name              = "${var.instance_name}-${random_id.random.hex}"
  tier              = "BASIC"
  memory_size_gb    = var.redis_memory_size_gb
  redis_version     = "REDIS_5_0"
  display_name      = "${var.instance_name}"

  region = var.subnet_region

  authorized_network = data.google_compute_network.shared_vpc.id
  connect_mode       = "PRIVATE_SERVICE_ACCESS"

  project            = module.service_project.project_id
}

output "redis_host" {
    value = google_redis_instance.cache.host
}

output "redis_port" {
    value = google_redis_instance.cache.port
}
