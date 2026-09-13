<#
.SYNOPSIS
    Uninstalls the global cyclomatic-complexity Antigravity skill on Windows.
#>

$skillsDir = Join-Path $HOME ".gemini\config\skills"
$targetDir = Join-Path $skillsDir "cyclomatic-complexity"

if (Test-Path $targetDir) {
    Remove-Item -Recurse -Force $targetDir
    Write-Host "[SUCCESS] Removed cyclomatic-complexity from $targetDir" -ForegroundColor Green
} else {
    Write-Host "Skill not found at $targetDir" -ForegroundColor Yellow
}
