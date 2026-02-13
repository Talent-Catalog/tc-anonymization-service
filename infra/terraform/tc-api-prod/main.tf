provider "aws" {
  region = "us-east-1"
}

module tc-prod {
  source = "./.."
  project_name = "tc-api"
  project_description = "Production setup for tc-api"
  image_tag = "1.0.1-SNAPSHOT"
  fargate_cpu = 512
  fargate_memory = 2048
  db_name = "tcapi"
  db_user_name = "tcapi"
  db_instance_class = "db.t3.medium" # 2vCPU, 4GB RAM
  db_version = "17.5"
  doc_db_name = "tcapi"
  doc_db_user_name = "tcapi"
  doc_db_password = ""
  doc_db_cluster_name = "prod.t9anmq2.mongodb.net"
  dns_namespace = "tc-api.local"
  app_port = 8082
  health_check_path = "/actuator/health"
  tc_api_url = "https://tctalent.org/api/admin"
  tc_api_search_id = 3434
  tc_api_username = "tc-api"
  site_domain = "api.tctalent.org"
}

terraform {
  backend "s3" {
    bucket         = "tc-api-terraform-state-prod"
    key            = "state/terraform.tfstate"
    region         = "us-east-1"
    encrypt        = true
  }
}
