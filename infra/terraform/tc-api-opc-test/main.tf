# Configure the AWS provider
# NOTE: Provider configuration MUST remain here (cannot be moved to parent module).
# Providers cannot have configuration parameters injected via module variables.
# Each environment targets a different AWS account via different assume_role ARNs.
# OPC staging account: 164804461258
provider "aws" {
  region = "eu-west-2"

  assume_role {
    role_arn = "arn:aws:iam::164804461258:role/opc-staging-terraform-exec"
  }
}

# tc-api infrastructure for OPC AWS staging account
module tc-opc-test {
  source = "./.."

  # Provided as Terraform inputs
  project_name        = "tc-api"
  project_description = "OPC staging setup for tc-api"
  environment         = "opc-staging"
  image_tag           = "1.0.1-SNAPSHOT"
  fargate_cpu         = 512
  fargate_memory      = 2048
  app_port            = 8082
  health_check_path   = "/actuator/health"
  db_name             = "tcapi"
  db_user_name        = "tcapi"
  db_instance_class   = "db.t3.medium"
  db_version          = "17.5"
  dns_namespace       = "tc-api.local"
  site_domain         = "test.api.plus.tctalent.org"

  # SSM-backed (stored and managed in SSM, injected into ECS) – set via ssm-parameters.sh
  tc_api_url              = "https://tctalent-test.org/api/admin"
  tc_search_id        = 2682
  tc_username         = "tc-api"
  tc_password         = "" # set via ssm-parameters.sh
  database_password   = "" # set via ssm-parameters.sh; must match RDS if set
  doc_db_cluster_name = "staging.c8pam.mongodb.net"
  doc_db_name         = "tcapi"
  doc_db_user_name    = "tcapi"
  doc_db_password          = "" # set via ssm-parameters.sh
  batch_chunk_size         = "20"
  batch_page_size          = "20"
  batch_max_read_skips     = "10"
  batch_fetch_delay_millis = "1000"
}

# Configure the opc-staging terraform workspace
# NOTE: The terraform block with backend configuration MUST remain in this file (cannot be moved to parent module).
# This is because backend configuration can only exist in the root module where terraform init/apply is run
terraform {
  backend "s3" {
    bucket         = "opc-shared-terraform-state"
    key            = "staging/tc-api/terraform.tfstate"
    region         = "eu-west-2"
    dynamodb_table = "opc-terraform-locks"
    encrypt        = true
  }
}

