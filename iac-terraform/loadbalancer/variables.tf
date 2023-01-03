
variable "project_id" {
  type = string
  default = "playground-s-11-b34d40ba"
}

variable "region" {
  description = "Location for load balancer and Cloud Run resources"
  default     = "us-central1"
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
  default     = "tf-cr-lb"
}

variable "service_account_email" {
  description = "Service account email to run containers under"
  type        = string
  default = "servacc001"
}

