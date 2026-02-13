# variables.tf

variable "project_name" {
  description = "Name of project - all resources will be named based on this"
}

variable "project_description" {
  description = "Description of project"
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

variable "db_name" {
  description = "Name of the database"
}

variable "db_user_name" {
  description = "Data base user name"
}

variable "db_version" {
  description = "Version of the database engine"
}

variable "db_instance_class" {
  description = "Instance class of database - see https://docs.aws.amazon.com/AmazonRDS/latest/UserGuide/Concepts.DBInstanceClass.Summary.html"
  default = "db.t3.micro"
}

variable "doc_db_name" {
  description = "Name of the document database"
}

variable "doc_db_user_name" {
  description = "Doc data base user name"
}

variable "doc_db_password" {
  description = "Doc data base password"
}

variable "doc_db_cluster_name" {
  description = "Cluster name of the document database"
}

variable "dns_namespace" {
  description = "Private DNS namespace"
}

variable "fargate_cpu" {
  description = "Fargate instance CPU units to provision (1 vCPU = 1024 CPU units)"
  default     = "1024"
}

variable "fargate_memory" {
  description = "Fargate instance memory to provision (in MiB)"
  default     = "4096"
}

variable "tc_api_url" {
  description = "Talent Catalog core service URL"
}

variable "tc_api_search_id" {
  description = "Talent Catalog search id used by tc-api"
}

variable "tc_api_username" {
  description = "Talent Catalog username used by tc-api"
}

variable "site_domain" {
  description = "The domain name for the ACM certificate (e.g. skills.staging.example.org)"
}
