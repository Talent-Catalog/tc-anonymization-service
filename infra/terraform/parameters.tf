################################################################################
# SSM Parameter Store – config and secrets consumed by ECS tasks
################################################################################
# Parameters use path: /${var.project_name}/${var.environment}/PARAM_NAME
# ECS task definition references these via secrets[].valueFrom (parameter ARN).
################################################################################

locals {
  ssm_prefix = "/${var.project_name}/${var.environment}"
}

# TC API
resource "aws_ssm_parameter" "tc_api_url" {
  name  = "${local.ssm_prefix}/TC_API_URL"
  type  = "String"
  value = var.tc_api_url
}

resource "aws_ssm_parameter" "tc_api_search_id" {
  name  = "${local.ssm_prefix}/TC_API_SEARCH_ID"
  type  = "String"
  value = tostring(var.tc_api_search_id)
}

resource "aws_ssm_parameter" "tc_api_username" {
  name  = "${local.ssm_prefix}/TC_API_USERNAME"
  type  = "String"
  value = var.tc_api_username
}

resource "aws_ssm_parameter" "tc_api_password" {
  name  = "${local.ssm_prefix}/TC_API_PASSWORD"
  type  = "SecureString"
  value = var.tc_api_password
}

# Database (PostgreSQL) – URL is computed after RDS is available
resource "aws_ssm_parameter" "database_url" {
  depends_on = [module.db]

  name  = "${local.ssm_prefix}/DATABASE_URL"
  type  = "String"
  value = "jdbc:postgresql://${module.db.cluster_endpoint}/${var.db_name}"
}

resource "aws_ssm_parameter" "database_username" {
  name  = "${local.ssm_prefix}/DATABASE_USERNAME"
  type  = "String"
  value = var.db_user_name
}

resource "aws_ssm_parameter" "database_password" {
  name  = "${local.ssm_prefix}/DATABASE_PASSWORD"
  type  = "SecureString"
  value = var.database_password
}

# MongoDB – full connection string built here and stored in SSM
resource "aws_ssm_parameter" "mongo_url" {
  name  = "${local.ssm_prefix}/MONGO_URL"
  type  = "SecureString"
  value = format(
    "mongodb+srv://%s:%s@%s/%s?retryWrites=true&w=majority&appName=staging",
    var.doc_db_user_name,
    var.doc_db_password,
    var.doc_db_cluster_name,
    var.doc_db_name,
  )
}

# Batch tuning parameters
resource "aws_ssm_parameter" "batch_chunk_size" {
  name  = "${local.ssm_prefix}/BATCH_CHUNK_SIZE"
  type  = "String"
  value = var.batch_chunk_size
}

resource "aws_ssm_parameter" "batch_page_size" {
  name  = "${local.ssm_prefix}/BATCH_PAGE_SIZE"
  type  = "String"
  value = var.batch_page_size
}

resource "aws_ssm_parameter" "batch_max_read_skips" {
  name  = "${local.ssm_prefix}/BATCH_MAX_READ_SKIPS"
  type  = "String"
  value = var.batch_max_read_skips
}

resource "aws_ssm_parameter" "batch_fetch_delay_millis" {
  name  = "${local.ssm_prefix}/BATCH_FETCH_DELAY_MILLIS"
  type  = "String"
  value = var.batch_fetch_delay_millis
}
