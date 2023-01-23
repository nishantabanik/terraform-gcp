provider "google" {
  project     = var.project_id
  credentials = "../../../../../tf-key.json"
}


/* # Enable Cloud Run API
resource "google_project_service" "cloudrun" {
  provider           = google-beta
  service            = "run.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "compute" {
  provider           = google-beta
  service            = "compute.googleapis.com"
  disable_on_destroy = false
}

resource "google_project_service" "clouddns" {
  provider           = google-beta
  service            = "dns.googleapis.com"
  disable_on_destroy = false
} */


module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "~> 6.3"
  name    = var.lb_name
  project = var.project_id

  ssl                             = var.ssl
  managed_ssl_certificate_domains = [var.domain]
  https_redirect                  = var.ssl
  labels                          = { "example-label" = "cloud-run-example" }
  #ip_address                      = ["10.10.10.10"] #var.ip_address

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.self_link
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
  project               = var.project_id
  region                = var.region
  name                  = var.serverless_neg_name
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = google_cloud_run_service.cloudrun-tf.name
  }
}

resource  "google_compute_forwarding_rule" "my_forwarding_rule" {
  name    = var.lb_name
  region  = var.region
  target  = google_cloud_run_service.cloudrun-tf.status[0].url
  ports = ["80, 443"]
  ip_address  = var.ip_address
}

####################################################################
# deploy Cloud Run Service with Service Account
####################################################################

/* module "td-mod-cloud-run" {
  source = "../tf-modules/services/tf-mod-cloud-run"
  project_id = var.project_id
  service_account_email = var.service_account_email
  region = var.region
} */


resource "google_cloud_run_service" "cloudrun-tf" {
  name     = var.cloud_run_name
  location = var.region
  project  = var.project_id

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
      "run.googleapis.com/ingress" = "internal-and-cloud-load-balancing"
    }
  }
  # Waits for the Cloud Run API to be enabled
  depends_on = [google_project_service.gcp_services]
}
