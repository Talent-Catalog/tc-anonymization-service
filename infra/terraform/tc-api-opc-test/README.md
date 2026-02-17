# tc-api OPC Staging Environment

Deploy the tc-api infrastructure to the OPC AWS staging account (`164804461258`, `eu-west-2`).

## Prerequisites

- AWS CLI configured with credentials that can assume `arn:aws:iam::164804461258:role/opc-staging-terraform-exec`
- Terraform >= 1.0
- The S3 backend bucket (`opc-shared-terraform-state`) and DynamoDB lock table (`opc-terraform-locks`) 
  must already exist in the OPC account

## 1. Initialise Terraform

```bash
cd infra/terraform/tc-api-opc-test
terraform init
```

## 2. Set secrets

Edit `secrets.auto.tfvars` in this directory with the real password values:

```hcl
database_password = "..."
doc_db_password   = "..."
tc_password       = "..."
```

This file is git-ignored and auto-loaded by Terraform. **Do not commit it.**

## 3. Deploy infrastructure

```bash
terraform plan -out tfplan
terraform apply tfplan
```

This creates all infrastructure (VPC, RDS Aurora, ECS, ALB, Route53, ACM) and populates all SSM 
parameters with real values:

- `database_password` sets both the RDS Aurora master password and the `DATABASE_PASSWORD` SSM parameter
- `doc_db_password` is combined with the other MongoDB vars to build the full `MONGO_URL` SSM parameter
- `tc_password` sets the `TC_PASSWORD` SSM parameter

All other SSM parameters (TC_API_URL, TC_SEARCH_ID, TC_USERNAME, DATABASE_URL, DATABASE_USERNAME, 
BATCH_*) are populated directly from `main.tf` values.

## Secret and parameter updates

To update any of the secrets or parameters, simply update the relevant SSM parameter directly in the 
AWS console.

Then restart the ECS service to pick up the new values.

ECS tasks that restart (scaling, crashes, deployments) automatically fetch the current SSM values 
without needing to re-run Terraform.
