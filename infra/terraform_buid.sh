#!/usr/bin/env bash
set -e

usage() {
  cat <<EOF
Usage: $0 -e|--env [dev|staging|production] [-h|--help]
  -e, --env   環境を指定 (dev|staging|production)
  -h, --help  このヘルプを表示
EOF
}

# 引数がない場合はヘルプ
if [ $# -eq 0 ]; then
  usage
  exit 1
fi

# 引数パース
while [ $# -gt 0 ]; do
  case "$1" in
    -e|--env)
      ENV="$2"
      shift 2
      ;;
    -h|--help|\?)
      usage
      exit 0
      ;;
    *)
      echo "Unknown option: $1"
      usage
      exit 1
      ;;
  esac
done

# 環境チェック
case "$ENV" in
  dev|staging|production)
    VAR_FILE="env/${ENV}/terraform.tfvars"
    ;;
  *)
    echo "Invalid environment: $ENV"
    usage
    exit 1
    ;;
esac

# Terraform 実行
cd infra/terraform
terraform init -var-file="$VAR_FILE"
terraform apply -var-file="$VAR_FILE"
