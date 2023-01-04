/* variable "gcp_service_list" {
  description ="The list of apis necessary for the project"
  type = list(string)
  default = [
    "cloudresourcemanager.googleapis.com",
    "serviceusage.googleapis.com",
    "dns.googleapis.com",
    "iam.googleapis.com",
    "run.googleapis.com",
    "cloudbuild.googleapis.com"
  ]
}

resource "google_project_service" "gcp_services" {
  for_each = toset(var.gcp_service_list)
  project = "playground-s-11-572e388d"
  service = each.key
} */


resource "google_project_service" "cloudbuild_api" {
  project  = var.project_id
  service  = "cloudbuild.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy = false
}

resource "google_cloudbuild_trigger" "build-prod" {
  location = var.region
  project  = var.project_id
  filename = "cloudbuild.yaml"
  name        = "my-trigger"
  description = "Trigger for building my application"
  disabled    = false # Status is enabled by default
  depends_on = [google_project_service.cloudbuild_api]

/*   approval_config {
    approval_required = yes
  } */

  # Connect to GitHub and trigger on push to develop branch
  # with specific glob pattern
  trigger_template {
    repo_name   = "https://github.com/nishantabanik/cloud-build-samples.git"
    branch_name = "main"
    #tag_name = ""
    dir         = "basic-config"
    #pattern     = "jest.config.js"
  }

  # Use dedicated service account to build the application
  service_account = var.service_account_email

  # Optionally, toggle on/off manual approval
  /* options {
    substitution_option = "ALLOW_LOOSE"
    disable_manual_triggers = false
  } */
}