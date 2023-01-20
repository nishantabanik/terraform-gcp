
variable "project_id" {
  type    = string
  default = "lgf-devops-sandbox"
}

variable "region" {
  description = "Location for the Cloud Run instance"
  default     = "europe-west1"
}

variable "service_account_email" {
  description = "Service account to run the Cloud Run instance"
  type        = string
  default     = "dev-cloudrun-sa"
}
