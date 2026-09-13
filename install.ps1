<#
.SYNOPSIS
    Installs cyclomatic-complexity as a global Antigravity skill on Windows.
.DESCRIPTION
    Clones the cyclomatic-complexity skill into $HOME\.gemini\config\skills\cyclomatic-complexity.
    Supports both direct script execution and piped execution (irm ... | iex).
#>

param(
    [string]$RepoUrl = "https://github.com/JohnJodinho/cyclomatic-complexity-skill.git",
    [switch]$Force
)

$ErrorActionPreference = "Stop"

$skillsDir = Join-Path $HOME ".gemini\config\skills"
$targetDir = Join-Path $skillsDir "cyclomatic-complexity"

Write-Host "==> Antigravity Skill Installer: cyclomatic-complexity" -ForegroundColor Cyan

if (-not (Test-Path $skillsDir)) {
    New-Item -ItemType Directory -Path $skillsDir -Force | Out-Null
    Write-Host "Created Antigravity global skills directory: $skillsDir" -ForegroundColor Green
}

if (Test-Path $targetDir) {
    if ($Force) {
        Write-Host "Removing existing installation at $targetDir..." -ForegroundColor Yellow
        Remove-Item -Recurse -Force $targetDir
    }
    elseif (Test-Path (Join-Path $targetDir ".git")) {
        Write-Host "Existing git installation found. Updating via git pull..." -ForegroundColor Yellow
        Push-Location $targetDir
        try {
            git pull --ff-only
            Write-Host "Successfully updated cyclomatic-complexity skill!" -ForegroundColor Green
        }
        finally {
            Pop-Location
        }
        return
    }
    else {
        Write-Host "Destination $targetDir already exists. Use -Force to overwrite." -ForegroundColor Yellow
        return
    }
}

Write-Host "Cloning from $RepoUrl into $targetDir..." -ForegroundColor Cyan
git clone $RepoUrl $targetDir

if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERROR] git clone failed. Ensure git is installed and the URL is reachable." -ForegroundColor Red
    return
}

Write-Host "`n[SUCCESS] cyclomatic-complexity skill installed globally for Antigravity!" -ForegroundColor Green
Write-Host "Location: $targetDir" -ForegroundColor Gray
Write-Host "`nAntigravity agents will now automatically discover this skill for code refactoring and complexity reviews." -ForegroundColor Cyan
