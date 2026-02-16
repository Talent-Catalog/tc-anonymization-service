################################################################################
# RDS Aurora PostgreSQL
################################################################################

module "db" {
  source  = "terraform-aws-modules/rds-aurora/aws"
  version = "9.13.0"

  name = local.name

  engine         = "aurora-postgresql"
  engine_version = var.db_version
  instance_class = var.db_instance_class
  instances = {
    one = {}
  }

  publicly_accessible = true

  master_username = var.db_user_name
  master_password = var.database_password != "" ? var.database_password : null
  database_name   = var.db_name

  vpc_id               = module.vpc.vpc_id
  db_subnet_group_name = module.vpc.database_subnet_group
  security_group_rules = {
    allow_local_access = {
      type        = "ingress"
      from_port   = 5432
      to_port     = 5432
      protocol    = "tcp"
      description = "Allow local access to Aurora"
      cidr_blocks = ["0.0.0.0/0"]
    }
    egress_all = {
      type        = "egress"
      from_port   = 0
      to_port     = 0
      protocol    = "-1"
      cidr_blocks = ["0.0.0.0/0"]
    }
  }

  vpc_security_group_ids = [module.security_group.security_group_id]

  create_cloudwatch_log_group = true

  backup_retention_period = 1
  skip_final_snapshot     = true
  deletion_protection     = false

  performance_insights_enabled          = true
  performance_insights_retention_period = 7
  create_monitoring_role                = true
  monitoring_interval                   = 60

  storage_encrypted             = true
  apply_immediately             = true
  allow_major_version_upgrade   = true

  enabled_cloudwatch_logs_exports = ["postgresql"]

  tags = local.tags
}
