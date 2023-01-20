provider "google" {
  project     = var.project_id
  credentials = "../tf-key.json"
}


# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  provider           = google-beta
  project            = var.project_id
  service            = "run.googleapis.com"
  disable_on_destroy = false
}


##########################################
# deploy Cloud Run Service
##########################################
resource "google_cloud_run_service" "cloudrun-tf" {
  name     = "example"
  location = var.region
  project  = var.project_id

  template {
    spec {
      containers {
        image = "gcr.io/cloudrun/hello"
        # image = "${var.registry}/${var.project}/${var.image_name}:${var.image_version}"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "256M"
          }
        }
      }
      service_account_name = google_service_account.example.email
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/minScale" = "2",
        "autoscaling.knative.dev/maxScale" = "5"
      }
    }
  }

  traffic {
    percent         = 100
    latest_revision = true
  }

  metadata {
    annotations = {
      "run.googleapis.com/ingress" = "all"
    }
  }
  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.cloudrun]
}









/* module "td-mod-cloud-run" {
  source = "../tf-modules/services/tf-mod-cloud-run"
  project_id = var.project_id
  service_account_email = var.service_account_email
  region = var.region
} */


