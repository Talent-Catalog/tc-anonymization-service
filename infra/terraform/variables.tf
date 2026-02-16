# -----------------------------------------------------------------------------
# Kept as Terraform module inputs (infra / config)
# -----------------------------------------------------------------------------

variable "project_name" {
  description = "Name of project - all resources will be named based on this"
}

variable "project_description" {
  description = "Description of project"
}

variable "environment" {
  description = "Environment name used in SSM parameter paths (e.g. opc-staging, test, prod)"
  default     = "staging"
}

variable "aws_region" {
  description = "The AWS region things are created in"
  default     = "us-east-1"
}

variable "image_tag" {
  description = "The image tag for the ECS service"
  default     = "latest"
}

variable "app_port" {
  description = "Port exposed by the docker image to redirect traffic to"
  default     = 8088
}

variable "health_check_path" {
  default = "/"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "4096"
}

variable "db_name" {
  description = "Name of the database"
}

variable "db_user_name" {
  description = "Database user name"
}

variable "db_version" {
  description = "Version of the database engine"
}

variable "db_instance_class" {
  description = "Instance class of database - see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Summary.html"
  default     = "db.t3.micro"
}

variable "dns_namespace" {
  description = "Private DNS namespace"
}

variable "site_domain" {
  description = "The domain name for the ACM certificate (e.g. skills.staging.example.org)"
}

# -----------------------------------------------------------------------------
# SSM-backed config and secrets (stored in SSM, injected into ECS task)
# -----------------------------------------------------------------------------

variable "tc_api_url" {
  description = "Talent Catalog core service URL (TC_API_URL in SSM)"
}

variable "tc_api_search_id" {
  description = "Talent Catalog search id used by tc-api (TC_API_SEARCH_ID in SSM)"
}

variable "tc_api_username" {
  description = "Talent Catalog username used by tc-api (TC_API_USERNAME in SSM)"
}

variable "tc_api_password" {
  description = "Talent Catalog API password (TC_API_PASSWORD in SSM as SecureString)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "database_password" {
  description = "RDS Aurora master password (DATABASE_PASSWORD in SSM as SecureString, used by RDS and ECS)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "doc_db_cluster_name" {
  description = "MongoDB Atlas cluster hostname (used to build MONGO_URL in SSM)"
}

variable "doc_db_name" {
  description = "MongoDB database name (used to build MONGO_URL in SSM)"
}

variable "doc_db_user_name" {
  description = "MongoDB user name (used to build MONGO_URL in SSM)"
}

variable "doc_db_password" {
  description = "MongoDB Atlas password (stored in SSM SecureString, used to build MONGO_URL)"
  type        = string
  sensitive   = true
  default     = ""
}

variable "batch_size" {
  description = "Batch size for batch jobs (BATCH_SIZE in SSM)"
  type        = string
  default     = ""
}

variable "batch_interval_ms" {
  description = "Batch interval in ms (BATCH_INTERVAL_MS in SSM)"
  type        = string
  default     = ""
}
