#!/usr/bin/env bash
# Update SSM parameters for tc-api (OPC staging).
# Path prefix: /tc-api/opc-staging/
# Replace placeholder values with real secrets; run with AWS profile/role for OPC staging account.
# Usage: ./ssm-parameters.sh   (or source and set REGION/PREFIX first)
#   REGION=eu-west-2 PREFIX=/tc-plus/opc-staging/tc-api ./ssm-parameters.sh

set -euo pipefail

REGION="${REGION:-eu-west-2}"
PREFIX="${PREFIX:-/tc-api/opc-staging}"

# Safety check: set expected account id in env
EXPECTED_ACCOUNT_ID="${EXPECTED_ACCOUNT_ID:-164804461258}"

require_not_placeholder() {
  local name="$1"
  local value="$2"
  if [[ "$value" == "REPLACE_ME" || -z "$value" ]]; then
    echo "ERROR: Refusing to set $name to placeholder/empty value. Provide a real value." >&2
    exit 1
  fi
}

# Safety check: verify we're in the expected AWS account
whoami_check() {
  local acct
  acct="$(aws sts get-caller-identity --region "$REGION" --query Account --output text)"
  echo "AWS Account: $acct  Region: $REGION  Prefix: $PREFIX"
  if [[ -n "$EXPECTED_ACCOUNT_ID" && "$acct" != "$EXPECTED_ACCOUNT_ID" ]]; then
    echo "ERROR: Expected account $EXPECTED_ACCOUNT_ID but got $acct. Aborting." >&2
    exit 1
  fi
}

put_string() {
  aws ssm put-parameter \
    --name "$1" \
    --value "$2" \
    --type "String" \
    --region "$REGION" \
    --overwrite >/dev/null
}

put_secure() {
  aws ssm put-parameter \
    --name "$1" \
    --value "$2" \
    --type "SecureString" \
    --region "$REGION" \
    --overwrite >/dev/null
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
