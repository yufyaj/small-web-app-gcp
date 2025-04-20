# 文字コード: UTF-8 with BOM
param(
    [Parameter(Mandatory=$false)]
    [switch]$Help,
    
    [Parameter(Mandatory=$false)]
    [Alias("e")]
    [ValidateSet("dev", "staging", "production")]
    [string]$Env
)

# コンソールのエンコーディングをUTF-8に設定
[Console]::OutputEncoding = [System.Text.Encoding]::UTF8

function Show-Help {
    Write-Host ""
    Write-Host "=== Terraform ビルドコマンド ===" -ForegroundColor Cyan
    Write-Host "使用方法: .\terraform_buid.ps1 -Env [dev|staging|production]"
    Write-Host "  -Env, -e   環境を指定 (dev|staging|production)"
    Write-Host "  -Help      このヘルプを表示"
    Write-Host ""
    Write-Host "例:"
    Write-Host "  .\terraform_buid.ps1 -Env dev    (開発環境)" -ForegroundColor Green
    Write-Host "  .\terraform_buid.ps1 -Env staging    (ステージング環境)" -ForegroundColor Yellow
    Write-Host "  .\terraform_buid.ps1 -Env production    (本番環境)" -ForegroundColor Red
    Write-Host ""
}

# ヘルプオプションまたはパラメータなしの場合はヘルプを表示
if ($Help -or (-not $Env)) {
    Show-Help
    exit 1
}

# 環境に応じた処理
$varFile = "env\$Env\terraform.tfvars"

# 環境表示
if ($Env -eq "dev") {
    Write-Host "開発環境用の Terraform を実行します..." -ForegroundColor Green
}
elseif ($Env -eq "staging") {
    Write-Host "ステージング環境用の Terraform を実行します..." -ForegroundColor Yellow
}
else {
    Write-Host "本番環境用の Terraform を実行します..." -ForegroundColor Red
}

# Terraform 実行
Push-Location -Path (Join-Path $PSScriptRoot 'terraform')
Write-Host "terraform init -var-file=`"$varFile`"" -ForegroundColor Cyan
terraform init -var-file="$varFile"

Write-Host "terraform apply -var-file=`"$varFile`"" -ForegroundColor Cyan
terraform apply -var-file="$varFile"
Pop-Location 