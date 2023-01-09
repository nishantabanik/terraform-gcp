data "google_project" "project" {}

resource "google_cloudbuild_trigger" "service-account-trigger" {
  trigger_template {
    branch_name = "main"
    repo_name   = var.repo_name
  }

  service_account = google_service_account.cloudbuild_service_account.id
  filename        = "cloudbuild.yaml"
  depends_on = [
    google_project_iam_member.act_as,
    google_project_iam_member.logs_writer
  ]
}

resource "google_service_account" "cloudbuild_service_account" {
  account_id = var.service_account_email
}

resource "google_project_iam_member" "act_as" {
  project = data.google_project.project.project_id
  #role    = "roles/cloudbuild.builds.editor"
  role    = "roles/iam.serviceAccountUser"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = data.google_project.project.project_id
  role    = "roles/logging.logWriter"
  #role    = "roles/editor"
  member  = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}
