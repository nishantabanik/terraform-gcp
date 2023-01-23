
resource "google_service_account" "cloudbuild_service_account" {
  account_id = var.service_account_email
}

resource "google_project_iam_member" "act_as" {
  project = data.google_project.project.project_id
  role    = "roles/cloudbuild.builds.editor"
  member = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_project_iam_member" "logs_writer" {
  project = data.google_project.project.project_id
  role    = "roles/logging.logWriter"
  member = "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
}

resource "google_service_account_iam_binding" "binding" {
  service_account_id = google_service_account.cloudbuild_service_account.name
  role               = "roles/iam.serviceAccountAdmin"
  members = [
    "serviceAccount:${google_service_account.cloudbuild_service_account.email}"
  ]
  depends_on = [google_service_account.cloudbuild_service_account]
}
