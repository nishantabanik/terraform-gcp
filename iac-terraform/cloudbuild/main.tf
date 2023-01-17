provider "google" {
  project = var.project_id
  credentials = "../tf-key.json"
}

data "google_project" "project" {}

resource "google_cloudbuild_trigger" "service-account-trigger" {
  project    = var.project_id
  location   = var.region
  name       = "manual-build"
  disabled   = false # Status is enabled by default
  
  source_to_build {
    uri       = var.repo_name
    ref       = "refs/heads/main"
    repo_type = "GITHUB"
  }
  
  trigger_template {
    branch_name = "main"
    repo_name   = var.repo_name
    dir         = "basic-config"
  }

  approval_config {
    approval_required == var.environment == "cloudbuild" ? true : false
  }

  substitutions = {
    _FOO              = "bar"
    _BAZ              = "qux"
    _CLOUD_RUN_ALIAS  = "prod-europe-landing-pages"
    _CLOUD_RUN_REGION = var.region
    #_SERVICE_ACCOUNT = var.service_account_email
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename = "cloudbuild.yaml"
  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]
}
