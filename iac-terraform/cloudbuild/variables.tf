
variable "project_id" {
  type    = string
  default = "lgf-devops-sandbox"
}

variable "repo_name" {
  type    = string
  #default = "https://github.com/Sonova-Marketing/geolocation.git"
  default = "https://github.com/nishantabanik/cloud-build-samples.git"
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "europe-west1"
}

variable "service_account_email" {
  description = "Service account email to run containers under"
  type        = string
  default     = "abcmnop001"
}

variable "environment" {
  description = "Our application deployment environment"
  type        = string
  default     = basename(abspath(path.module))
}
