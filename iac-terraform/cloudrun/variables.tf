
variable "project_id" {
  type = string
  default = "lgf-devops-sandbox"
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "europe-west1"
}

variable "service_account_email" {
  description = "Service account email to run containers under"
  type        = string
  default = "abcmnop001"
}


