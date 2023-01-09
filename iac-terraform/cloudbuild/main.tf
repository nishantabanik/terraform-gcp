resource "google_project_service" "cloudbuild_api" {
  project                    = var.project_id
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_cloudbuild_trigger" "filename-trigger" {
  location   = var.region
  project    = var.project_id
  name       = "manual-build"
  disabled   = false # Status is enabled by default
  filename   = "cloudbuild.yaml"
  depends_on = [google_project_service.cloudbuild_api]
  source_to_build {
    uri       = "https://github.com/nishantabanik/cloud-build-samples.git"
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
  approval_config {
    approval_required = true
  }


  trigger_template {
    branch_name = "main"
    repo_name   = var.repo_name
    dir         = "basic-config"
  }

  substitutions = {
    _FOO              = "bar"
    _BAZ              = "qux"
    _CLOUD_RUN_ALIAS  = "prod-europe-landing-pages"
    _CLOUD_RUN_REGION = "europe-west1"
    _SERVICE_ACCOUNT = var.service_account_email

  }
