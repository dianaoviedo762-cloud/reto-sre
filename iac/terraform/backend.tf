terraform {
  backend "s3" {
    bucket = "miorg-terraform-state-reto-sre"
    key    = "projects/reto-sre/terraform.tfstate"
    region = "us-west-2"
    use_lockfile = true
  }
}
