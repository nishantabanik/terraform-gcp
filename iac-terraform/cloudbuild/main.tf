provider "google" {
  project     = var.project_id
  credentials = "../../../../../tf-key.json"
}

data "google_project" "project" {}

resource "google_cloudbuild_trigger" "service-account-trigger" {
  project  = var.project_id
  location = var.region
  name     = "dev-deploy-de-hoergeraete-bild"
  disabled = false # Status is enabled by default

  source_to_build {
    uri       = var.repo_name
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }

  trigger_template {
    branch_name = "^develop$"
    repo_name   = var.repo_name
    dir         = "apps/microsites/bild/.build/hoergeraete/"
  }

  approval_config {
    approval_required = var.environment == "development" ? true : false
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]
  
  substitutions = {
    _CLOUD_RUN_ALIAS         = "dev-de-hoergeraete-bild"
    _CLOUD_RUN_MAX_INSTANCES = "3"
    _CLOUD_RUN_REGION        = var.region
  }
}
