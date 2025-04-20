#!/bin/bash

set -e

function show_help() {
  echo ""
  echo "=== GCPサービスAPI有効化用 Terraformコマンド ==="
  echo "使い方: ./services_apply.sh [dev|staging|production]"
  echo ""
  echo "例:"
  echo "  ./services_apply.sh dev"
  echo ""
}

if [ "$1" = "-h" ] || [ "$1" = "--help" ] || [ -z "$1" ]; then
  show_help
  exit 1
fi

ENV="$1"
VAR_FILE="../env/${ENV}/terraform.tfvars"

cd "$(dirname "$0")/terraform/services"

echo "terraform init -var-file=\"$VAR_FILE\""
terraform init -var-file="$VAR_FILE"

echo "terraform apply -var-file=\"$VAR_FILE\""
terraform apply -var-file="$VAR_FILE"