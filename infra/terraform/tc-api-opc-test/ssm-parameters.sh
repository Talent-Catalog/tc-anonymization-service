#!/usr/bin/env bash
# Update SSM parameters for tc-api (OPC staging).
# Path prefix: /tc-api/opc-staging/
# Replace placeholder values with real secrets; run with AWS profile/role for OPC staging account.
# Usage: ./ssm-parameters.sh   (or source and set REGION/PREFIX first)

set -euo pipefail

REGION="${REGION:-eu-west-2}"
PREFIX="${PREFIX:-/tc-api/opc-staging}"

put_string() {
  aws ssm put-parameter \
    --name "$1" \
    --value "$2" \
    --type "String" \
    --region "$REGION" \
    --overwrite
}

put_secure() {
  aws ssm put-parameter \
    --name "$1" \
    --value "$2" \
    --type "SecureString" \
    --region "$REGION" \
    --overwrite
}

# TC service
put_string "${PREFIX}/TC_API_URL" "https://tctalent-test.org/api/admin"
put_string "${PREFIX}/TC_SEARCH_ID" "2682"
put_string "${PREFIX}/TC_USERNAME" "tc-api"
put_secure "${PREFIX}/TC_PASSWORD" "REPLACE_ME"

# Database (PostgreSQL) – DATABASE_URL is set by Terraform from RDS endpoint; override only if needed
# put_string "${PREFIX}/DATABASE_URL" "jdbc:postgresql://..."
put_string "${PREFIX}/DATABASE_USERNAME" "tcapi"
put_secure "${PREFIX}/DATABASE_PASSWORD" "REPLACE_ME"

# MongoDB – full URI (sensitive)
put_secure "${PREFIX}/MONGO_URL" "REPLACE_ME"

# Batch tuning
put_string "${PREFIX}/BATCH_CHUNK_SIZE" "20"
put_string "${PREFIX}/BATCH_PAGE_SIZE" "20"
put_string "${PREFIX}/BATCH_MAX_READ_SKIPS" "10"
put_string "${PREFIX}/BATCH_FETCH_DELAY_MILLIS" "1000"

echo "Done. Replace REPLACE_ME with real values and re-run for secrets."
