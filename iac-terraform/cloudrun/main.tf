provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  provider = google-beta
  service  = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "example" {
  #account_id   = var.service_account_email
  account_id   = "example-service-account"
  display_name = "Example Service Account"
  #service = google_service_account.example.account_id
  #depends_on = [google_project_service.iam]
}

resource "google_service_account_iam_binding" "binding" {
  service_account_id = google_service_account.example.name
  role = "roles/run.admin"
  members = [
    #"serviceAccount:${google_service_account.example.name}@playground-s-11-02b39fdb.iam.gserviceaccount.com",
    "serviceAccount:example-service-account@playground-s-11-02b39fdb.iam.gserviceaccount.com"
    ]
  depends_on = [google_service_account.example]
}

resource "google_cloud_run_service_iam_member" "access-cloudrun" {
  location = google_cloud_run_service.default.location
  project  = google_cloud_run_service.default.project
  service  = google_cloud_run_service.default.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}

##########################################
# deploy Cloud Run Service
##########################################
resource "google_cloud_run_service" "default" {
  name     = "example"
  location = var.region
  project  = var.project_id

  template {
    spec {
      service_account_name = google_service_account.example.email
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
    }
  }
  
  traffic {
            percent = 100
            latest_revision = true
        }

  metadata {
    annotations = {
      # For valid annotation values and descriptions, see
      # https://cloud.google.com/sdk/gcloud/reference/run/deploy#--ingress
      "run.googleapis.com/ingress" = "all"
    }
  }
  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.cloudrun]
}


# [END cloudloadbalancing_ext_http_cloudrun]


