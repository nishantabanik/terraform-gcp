
provider "google" {
  project = var.project_id
}

provider "google-beta" {
  project = var.project_id
}

# Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  provider = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "clouddns" {
  provider = google-beta
  service            = "dns.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "iam" {
  service = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_dns_record_set" "a" {
  name         = "backend.${google_dns_managed_zone.prod.dns_name}"
  managed_zone = google_dns_managed_zone.prod.name
  type         = "A"
  ttl          = 300

  rrdatas = ["8.8.8.8"]
}

resource "google_dns_managed_zone" "prod" {
  name     = "prod-zone"
  dns_name = "prod.mydomain123.com."
  depends_on = [google_project_service.clouddns]
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = var.lb_name
  project = var.project_id

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl
  labels                          = { "example-label" = "cloud-run-example" }

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn              = true
      security_policy         = null
      custom_request_headers  = null
      custom_response_headers = null

      iap_config = {
        enable               = false
        oauth2_client_id     = ""
        oauth2_client_secret = ""
      }
      log_config = {
        enable      = true
        sample_rate = null
      }
    }
  }
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  provider              = google-beta
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.default.name
  }
}

####################################################################
# deploy Cloud Run Service with Service Account
####################################################################

resource "google_service_account" "example" {
  account_id   = var.service_account_email
  display_name = "Example Service Account"
}

resource "google_service_account_iam_binding" "binding" {
  service_account_id = google_service_account.example.name
  role = "roles/editor"
  #role = "roles/iam.serviceAccountAdmin"
  members = [
    "serviceAccount:${google_service_account.example.email}"
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


resource "google_cloud_run_service" "default" {
  name     = "example"
  location = var.region
  project  = var.project_id
  /* google_service_account {
    service = google_service_account.example.account_id
  } */

  template {
    spec {
      service_account_name = google_service_account.example.email
      containers {
        image = "gcr.io/cloudrun/hello"
        resources {
          limits = {
            cpu    = "1000m"
            memory = "256M"
          }
        }
      }
    }
    metadata {
            annotations = {
                    "autoscaling.knative.dev/minScale" = "2",
                    "autoscaling.knative.dev/maxScale" = "5"
                }
            }
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