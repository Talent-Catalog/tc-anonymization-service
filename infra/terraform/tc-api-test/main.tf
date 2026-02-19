provider "aws" {
  region = "us-east-1"
}

module tc-test {
  source = "./.."

  # Terraform inputs
  project_name        = "tc-api"
  project_description = "Staging setup for tc-api"
  environment         = "test"
  image_tag           = "1.0.1-SNAPSHOT"
  fargate_cpu         = 512
  fargate_memory      = 2048
  app_port            = 8082
  health_check_path   = "/actuator/health"
  db_name             = "tcapi"
  db_user_name        = "tcapi"
  db_instance_class   = "db.t3.medium" # smallest test instance available for aurora
  db_version          = "17.5"
  dns_namespace       = "tc-api.local"
  site_domain         = "test.api.tctalent.org"

  # SSM-backed
  tc_api_url                   = "https://tctalent-test.org/api/admin"
  tc_search_id             = 2682
  tc_username              = "tc-api"
  tc_password              = "" # set via ssm-parameters.sh
  database_password        = "" # set via ssm-parameters.sh
  doc_db_cluster_name      = "staging.c8pam.mongodb.net"
  doc_db_name              = "tcapi"
  doc_db_user_name         = "tcapi"
  doc_db_password          = "" # set via ssm-parameters.sh
  batch_chunk_size         = "20"
  batch_page_size          = "20"
  batch_max_read_skips     = "10"
  batch_fetch_delay_millis = "1000"
}

terraform {
  backend "s3" {
    bucket         = "tc-api-terraform-state"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
