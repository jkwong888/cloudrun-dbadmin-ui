terraform {
  backend "gcs" {
    bucket  = "jkwng-altostrat-com-tf-state"
    prefix = "jkwng-dbadm-dev"
  }

  required_providers {
    google = {
      #version = "~> 3.71.0"
      version = "~> 4"
    }
    google-beta = {
      #version = "~> 3.71.0"
      version = "~> 4"

    }
    null = {
      version = "~> 2.1"
    }
    random = {
      version = "~> 2.2"
    }
  }
}

provider "google" {
#  credentials = file(local.credentials_file_path)
}

provider "google-beta" {
#  credentials = file(local.credentials_file_path)
}

provider "null" {
}

provider "random" {
}


data "google_client_config" "client_config" {
}

data "google_client_openid_userinfo" "me" {
}