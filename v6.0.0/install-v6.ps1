param(
    [string]$ProjectRoot = (Get-Location).Path
)

$ErrorActionPreference = 'Stop'
$Version = '6.0.0'
$Repo = 'connorfieldphone/greenteamnetworks-npm'
$Branch = 'Update'
$NotesUrl = "https://raw.githubusercontent.com/$Repo/$Branch/v6.0.0/updatenotes@v6.0.0.txt"

function Fail([string]$Message) {
    Write-Host ""
    Write-Host "UPDATE FAILED" -ForegroundColor Red
    Write-Host $Message
    exit 1
}

$ProjectRoot = (Resolve-Path $ProjectRoot).Path
$PackagePath = Join-Path $ProjectRoot 'package.json'

if (-not (Test-Path $PackagePath)) {
    Fail "package.json was not found in $ProjectRoot"
}

try {
    $Package = Get-Content $PackagePath -Raw | ConvertFrom-Json
} catch {
    Fail "package.json is not valid JSON. No files were changed."
}

$OldVersion = [string]$Package.version
if ([string]::IsNullOrWhiteSpace($OldVersion)) {
    Fail "package.json does not contain a version. No files were changed."
}

Write-Host "GreenTeam Networks v$Version updater"
Write-Host "==================================="
Write-Host "Current version: v$OldVersion"
Write-Host "Target version:  v$Version"
Write-Host "Source: $Repo / $Branch"
Write-Host ""

$Backup = Join-Path (Split-Path $ProjectRoot -Parent) "greenteamnetworks-backup-v$OldVersion-$(Get-Date -Format yyyyMMdd-HHmmss)"

try {
    Copy-Item $ProjectRoot $Backup -Recurse -Force
} catch {
    Fail "Could not create backup. No update was attempted."
}

Write-Host "Backup created: $Backup"
Write-Host ""

# This script is intentionally conservative. It only changes package.json
# and the v6 update notes unless a complete v6 update archive is supplied.
$Package.version = $Version

try {
    $Json = $Package | ConvertTo-Json -Depth 100
    [System.IO.File]::WriteAllText(
        $PackagePath,
        $Json + [Environment]::NewLine,
        [System.Text.UTF8Encoding]::new($false)
    )
} catch {
    Copy-Item $Backup $ProjectRoot -Recurse -Force
    Fail "Could not write package.json. The backup was restored."
}

try {
    $Verify = Get-Content $PackagePath -Raw | ConvertFrom-Json
    if ([string]$Verify.version -ne $Version) {
        throw 'Version verification failed.'
    }
} catch {
    Copy-Item $Backup $ProjectRoot -Recurse -Force
    Fail "Post-update verification failed. The backup was restored."
}

Write-Host "Version updated to v$Version"
Write-Host ""
Write-Host "Update notes:"
Write-Host $NotesUrl
Write-Host ""
Write-Host "v6.0.0 local update preparation completed successfully."
Write-Host "Backup: $Backup"
