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

## 2. Deploy infrastructure

```bash
terraform plan
terraform apply
```

This creates the VPC, RDS Aurora cluster, ECS cluster/service, ALB, Route53 zone, ACM certificate, 
and SSM parameters.

SSM parameters for non-secret values (TC_API_URL, TC_SEARCH_ID, batch tuning, etc.) are populated 
by Terraform directly from `main.tf` inputs.

## 3. Set secret SSM parameters

After `terraform apply` completes, run `ssm-parameters.sh` to write the secret values that are not 
stored in Terraform state.

The script requires three environment variables for the secrets:

| Variable | Description |
|---|---|
| `TC_PASSWORD` | Talent Catalog API password |
| `DATABASE_PASSWORD` | RDS Aurora master password |
| `MONGO_URL` | Full MongoDB Atlas connection URI |

Run the script:

```bash
TC_PASSWORD="..." \
DATABASE_PASSWORD="..." \
MONGO_URL="mongodb+srv://user:pass@cluster/db?..." \
./ssm-parameters.sh
```

The script will verify it is running against the expected AWS account before writing any parameters.

## When to re-run ssm-parameters.sh

- **First deploy** -- always run after the initial `terraform apply`
- **Secret rotation** -- whenever a password or connection string changes (doesn't have to be done 
  through the script, e.g. you could rotate the database password in the RDS console and then update 
  the SSM parameter directly in the AWS console without using the script)
- **Parameter updates** -- if you want to update any of the parameters that are set by the script (e.g. 
  TC_SEARCH_ID, batch tuning parameters) without changing Terraform state (i.e. without updating 
  `main.tf` and re-applying)

