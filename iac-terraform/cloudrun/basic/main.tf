
module "service_account" {
  source     = "terraform-google-modules/service-accounts/google"
  version    = "~> 4.1.1"
  project_id = var.project_id
  prefix     = "sa-cloud-run"
  names      = ["simple"]
}

module "cloud_run" {
  source = "../../"
  
  service_name          = "ci-cloud-run"
  project_id            = var.project_id
  location              = var.region
  image                 = "us-docker.pkg.dev/cloudrun/container/hello"
  service_account_email = module.service_account.email
/*   resources {
          limits = {
            cpu    = "1000m"
            memory = "256M"
          }
        } */
}