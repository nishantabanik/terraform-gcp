
variable "project_id" {
  type    = string
  default = "lgf-devops-sandbox"
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "europe-west1"
}

variable "cloud_run_name" {
  description = "Cloud run instance for BILD application"
  type        = string
  default     = "dev-de-run-bild"
}

variable "ssl" {
  description = "Run load balancer on HTTPS and provision managed certificate with provided `domain`."
  type        = bool
  default     = true
}

variable "domain" {
  description = "Domain name to run the load balancer on. Used if `ssl` is `true`."
  type        = string
}

variable "lb_name" {
  description = "Name for load balancer and associated resources"
  default     = "tf-dev-bild-lb"
}

variable "ip_address" {
  default     = ("10.0.10.3")
}

variable "service_account_email" {
  description = "Service account email to run containers under"
  type        = string
  default     = "dev-load-balancer-sa"
}

variable "serverless_neg_name" {
  description = "Serverless NEG for BILD loadbalancer"
  type        = string
  default     = "dev-de-bild-lb-neg"
}
