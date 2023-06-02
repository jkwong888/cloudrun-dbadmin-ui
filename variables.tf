/**
 * Copyright 2018 Google LLC
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *      http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

variable "billing_account_id" {
  default = ""
}

variable "organization_id" {
  default = "" 
}

variable "parent_folder_id" {
  default = "" 
}

variable "service_project_id" {
  description = "The ID of the service project which hosts the project resources e.g. airflow-project"
}

variable "shared_vpc_host_project_id" {
  description = "The ID of the host project which hosts the shared VPC e.g. vpc-project"
}

variable "registry_project_id" {
  description = "The ID of the service project which hosts the registry"
}

variable "shared_vpc_network" {
  description = "The ID of the shared VPC e.g. shared-network"
}

variable "subnet_name" {
  description = "Name of subnet to create"
}

variable "subnet_region" {
  description = "region subnet is located in"
}

variable "subnet_primary_range" {
}

variable "subnet_secondary_range" {
  type = map(any)
  default = {}
}

variable "instance_name" {
  default = "db"
}

variable "redis_memory_size_gb" {
  default = 1
}

variable "db_instance_type" { 
  default = "db-custom-2-8192"
}

variable "google_iap_email" {
  default = ""
}

variable "google_oauth_client_secret" {
  default = ""
}

variable "redisinsight_image" {
  default = ""
}