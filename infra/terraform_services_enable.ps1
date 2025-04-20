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
    Write-Host "=== GCPサービスAPI有効化用 Terraformコマンド ===" -ForegroundColor Cyan
    Write-Host "使用方法: .\\services_apply.ps1 -Env [dev|staging|production]"
    Write-Host "  -Env, -e   環境を指定 (dev|staging|production)"
    Write-Host "  -Help      このヘルプを表示"
    Write-Host ""
    Write-Host "例:"
    Write-Host "  .\\services_apply.ps1 -Env dev" -ForegroundColor Green
    Write-Host ""
}

if ($Help -or (-not $Env)) {
    Show-Help
    exit 1
}

$varFile = "..\env\$Env\terraform.tfvars"

Push-Location -Path (Join-Path $PSScriptRoot 'terraform\services')
Write-Host "terraform init -var-file=`"$varFile`"" -ForegroundColor Cyan
terraform init -var-file="$varFile"

Write-Host "terraform apply -var-file=`"$varFile`"" -ForegroundColor Cyan
terraform apply -var-file="$varFile"
Pop-Location