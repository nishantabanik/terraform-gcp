
variable "project_id" {
  type    = string
  default = "lgf-devops-sandbox"
}

variable "repo_name" {
  type = string
  default = "dev-deploy-de-hoergeraete-bild"
}

variable "repo_url"
type = string
default = "https://github.com/Sonova-Marketing/web-mono.git"

variable "region" {
  description = "Location for BILD Cloudbuild development resources"
  default     = "europe-west1"
}

variable "service_account_email" {
  description = "Service account email to run build trigger"
  type        = string
  default     = "dev-build-trigger-sa"
}

variable "environment" {
  description = "Our application deployment environment"
  type        = string
  default     = "$(path.module)"
  #default = "$(dirname(path.module))" #"${path.module}"
}
