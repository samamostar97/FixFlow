param(
    [int]$MaxFileLines = 250,
    [int]$MaxBuildLines = 50,
    [switch]$StrictBuild,
    [string[]]$TargetPaths = @(
        "fixflow_mobile/lib",
        "fixflow_desktop/lib",
        "packages/fixflow_core/lib"
    )
)

$ErrorActionPreference = "Stop"

$repoRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
$baselinePath = Join-Path $PSScriptRoot "modularity_baseline.json"
$allowedLargeFiles = @{}

if (Test-Path -LiteralPath $baselinePath) {
    $baseline = Get-Content -LiteralPath $baselinePath -Raw | ConvertFrom-Json
    foreach ($entry in $baseline.allowedLargeFiles) {
        $normalized = ($entry.path -replace "\\", "/").ToLowerInvariant()
        $allowedLargeFiles[$normalized] = [int]$entry.maxLines
    }
}

function Get-BuildMethodLength {
    param(
        [string[]]$Lines,
        [int]$StartIndex
    )

    $braceDepth = 0
    $started = $false

    for ($index = $StartIndex; $index -lt $Lines.Count; $index++) {
        $line = $Lines[$index]
        foreach ($char in $line.ToCharArray()) {
            if ($char -eq '{') {
                $braceDepth++
                $started = $true
            } elseif ($char -eq '}') {
                if ($started) {
                    $braceDepth--
                }
            }
        }

        if ($started -and $braceDepth -eq 0) {
            return ($index - $StartIndex + 1)
        }
    }

    return $null
}

function Get-RelativePath {
    param(
        [string]$BasePath,
        [string]$TargetPath
    )

    $basePathWithSlash = $BasePath.TrimEnd('\', '/') + [System.IO.Path]::DirectorySeparatorChar
    $baseUri = New-Object System.Uri($basePathWithSlash)
    $targetUri = New-Object System.Uri($TargetPath)
    $relativeUri = $baseUri.MakeRelativeUri($targetUri)
    return [System.Uri]::UnescapeDataString($relativeUri.ToString()) -replace "\\", "/"
}

$hardViolations = [System.Collections.Generic.List[object]]::new()
$buildViolations = [System.Collections.Generic.List[object]]::new()
$debtFiles = [System.Collections.Generic.List[object]]::new()

foreach ($target in $TargetPaths) {
    $absoluteTarget = Join-Path $repoRoot $target
    if (-not (Test-Path -LiteralPath $absoluteTarget)) {
        continue
    }

    $dartFiles = Get-ChildItem -Path $absoluteTarget -Recurse -File -Filter *.dart |
        Where-Object {
            $_.Name -notlike "*.g.dart" -and
            $_.Name -notlike "*.freezed.dart" -and
            $_.FullName -notlike "*\.dart_tool\*" -and
            $_.FullName -notlike "*\build\*"
        }

    foreach ($file in $dartFiles) {
        $relativePath = Get-RelativePath -BasePath $repoRoot.Path -TargetPath $file.FullName
        $normalizedRelativePath = $relativePath.ToLowerInvariant()
        $lines = Get-Content -LiteralPath $file.FullName
        $lineCount = $lines.Count

        if ($lineCount -gt $MaxFileLines) {
            if ($allowedLargeFiles.ContainsKey($normalizedRelativePath)) {
                $allowedLimit = $allowedLargeFiles[$normalizedRelativePath]
                if ($lineCount -le $allowedLimit) {
                    $debtFiles.Add([PSCustomObject]@{
                        File  = $relativePath
                        Lines = $lineCount
                        Limit = $allowedLimit
                    }) | Out-Null
                } else {
                    $hardViolations.Add([PSCustomObject]@{
                        File    = $relativePath
                        Lines   = $lineCount
                        Limit   = $allowedLimit
                        Problem = "Prelazi baseline limit"
                    }) | Out-Null
                }
            } else {
                $hardViolations.Add([PSCustomObject]@{
                    File    = $relativePath
                    Lines   = $lineCount
                    Limit   = $MaxFileLines
                    Problem = "Prelazi hard limit"
                }) | Out-Null
            }
        }

        for ($i = 0; $i -lt $lines.Count; $i++) {
            if ($lines[$i] -match '^\s*Widget\s+build\s*\(') {
                $length = Get-BuildMethodLength -Lines $lines -StartIndex $i
                if ($null -ne $length -and $length -gt $MaxBuildLines) {
                    $buildViolations.Add([PSCustomObject]@{
                        File   = $relativePath
                        Line   = ($i + 1)
                        Length = $length
                        Limit  = $MaxBuildLines
                    }) | Out-Null
                }
            }
        }
    }
}

if ($debtFiles.Count -gt 0) {
    Write-Host ""
    Write-Host "Known baseline debt (allowed):" -ForegroundColor Yellow
    $debtFiles |
        Sort-Object Lines -Descending |
        Format-Table -AutoSize |
        Out-String |
        Write-Host
}

if ($buildViolations.Count -gt 0) {
    $messageColor = if ($StrictBuild) { "Red" } else { "Yellow" }
    Write-Host ""
    Write-Host "build() method length findings:" -ForegroundColor $messageColor
    $buildViolations |
        Sort-Object Length -Descending |
        Format-Table -AutoSize |
        Out-String |
        Write-Host
}

if ($hardViolations.Count -gt 0) {
    Write-Host ""
    Write-Host "Hard modularity violations:" -ForegroundColor Red
    $hardViolations |
        Sort-Object Lines -Descending |
        Format-Table -AutoSize |
        Out-String |
        Write-Host
    exit 1
}

if ($StrictBuild -and $buildViolations.Count -gt 0) {
    Write-Host ""
    Write-Host "Strict build() limit enabled; failing due to findings." -ForegroundColor Red
    exit 1
}

Write-Host ""
Write-Host "Modularity gate passed." -ForegroundColor Green
exit 0
