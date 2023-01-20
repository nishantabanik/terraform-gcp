
resource "google_project_service" "iam" {
  service            = "iam.googleapis.com"
  disable_on_destroy = false
}

resource "google_service_account" "example" {
  account_id   = var.service_account_email
  display_name = "Example Service Account"
}

resource "google_service_account_iam_binding" "binding" {
  service_account_id = google_service_account.example.name
  role               = "roles/editor"
  members = [
    "serviceAccount:${google_service_account.example.email}"
  ]
  depends_on = [google_service_account.example]
}

resource "google_cloud_run_service_iam_member" "access-cloudrun" {
  location = google_cloud_run_service.cloudrun-tf.location
  project  = google_cloud_run_service.cloudrun-tf.project
  service  = google_cloud_run_service.cloudrun-tf.name
  role     = "roles/run.invoker"
  member   = "allUsers"
}
