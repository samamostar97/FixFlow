param(
    [switch]$NoStrictBuild
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$modularityScript = Join-Path $PSScriptRoot "check_dart_modularity.ps1"

function Invoke-Step {
    param(
        [string]$Name,
        [string]$WorkingDirectory,
        [scriptblock]$Action
    )

    Write-Host ""
    Write-Host "==> $Name" -ForegroundColor Cyan
    Push-Location $WorkingDirectory
    try {
        & $Action
        if ($LASTEXITCODE -ne 0) {
            throw "$Name failed with exit code $LASTEXITCODE"
        }
    } finally {
        Pop-Location
    }
}

Write-Host "Running modularity gate and Flutter quality checks..." -ForegroundColor Cyan

if ($NoStrictBuild) {
    & $modularityScript
} else {
    & $modularityScript -StrictBuild
}
if ($LASTEXITCODE -ne 0) {
    exit $LASTEXITCODE
}

Invoke-Step -Name "fixflow_core analyze" -WorkingDirectory (Join-Path $repoRoot "packages/fixflow_core") -Action { flutter analyze }
Invoke-Step -Name "fixflow_core test" -WorkingDirectory (Join-Path $repoRoot "packages/fixflow_core") -Action { flutter test }

Invoke-Step -Name "fixflow_mobile analyze" -WorkingDirectory (Join-Path $repoRoot "fixflow_mobile") -Action { flutter analyze }
Invoke-Step -Name "fixflow_mobile test" -WorkingDirectory (Join-Path $repoRoot "fixflow_mobile") -Action { flutter test }

Invoke-Step -Name "fixflow_desktop analyze" -WorkingDirectory (Join-Path $repoRoot "fixflow_desktop") -Action { flutter analyze }
Invoke-Step -Name "fixflow_desktop test" -WorkingDirectory (Join-Path $repoRoot "fixflow_desktop") -Action { flutter test }

Write-Host ""
Write-Host "All UI quality gates passed." -ForegroundColor Green
