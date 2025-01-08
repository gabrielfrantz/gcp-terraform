terraform {
  required_version = ">=1.9.4"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "6.12.0"
    }
  }

  backend "gcs" {
    bucket = "nomedobucket" # precisa criar um bucket com esse nome manualmente na GCP antes de rodar a pipeline
    prefix = "terraform/" # subpasta
  }
}

provider "google" {
  project = "project-id" # id do projeto da GCP
  region  = var.region # região
}
