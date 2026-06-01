# Compress portfolio walkthrough videos (and optionally PNGs) for web delivery.
# Requires: ffmpeg on PATH — install once: winget install Gyan.FFmpeg
#
# Usage (from repo root):
#   .\scripts\compress-portfolio-media.ps1
#   .\scripts\compress-portfolio-media.ps1 -VideosOnly
#   .\scripts\compress-portfolio-media.ps1 -WhatIf
#
# Writes *.bak backups next to originals, then replaces in place.
# Re-run git add after compressing; LFS will track the smaller files.

param(
  [switch]$VideosOnly,
  [switch]$WhatIf,
  [int]$MaxVideoWidth = 1280,
  [int]$Crf = 26
)

$ErrorActionPreference = "Stop"
$PortfolioDir = Join-Path $PSScriptRoot "..\bill\assets\portfolio" | Resolve-Path

function Get-Ffmpeg {
  $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  return $null
}

function Compress-Video([string]$InputPath, [string]$Ffmpeg) {
  $dir = Split-Path $InputPath -Parent
  $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
  $tmp = Join-Path $dir ($base + "._compressed.mp4")
  $bak = $InputPath + ".bak"

  $args = @(
    "-y", "-i", $InputPath,
    "-an",
    "-c:v", "libx264",
    "-preset", "medium",
    "-crf", $Crf.ToString(),
    "-vf", "scale='min($MaxVideoWidth,iw)':-2:flags=lanczos",
    "-pix_fmt", "yuv420p",
    "-movflags", "+faststart",
    $tmp
  )

  Write-Host "Video: $([System.IO.Path]::GetFileName($InputPath))"
  if ($WhatIf) {
    Write-Host "  would run: ffmpeg $($args -join ' ')"
    return
  }

  & $Ffmpeg @args
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed for $InputPath" }

  $before = (Get-Item $InputPath).Length
  $after = (Get-Item $tmp).Length
  Copy-Item $InputPath $bak -Force
  Move-Item $tmp $InputPath -Force
  Write-Host ("  {0:N1} MB -> {1:N1} MB (backup: {2})" -f ($before/1MB), ($after/1MB), (Split-Path $bak -Leaf))
}

function Compress-Png([string]$InputPath) {
  $magick = Get-Command magick -ErrorAction SilentlyContinue
  if (-not $magick) {
    Write-Warning "ImageMagick (magick) not found — skipping PNG: $(Split-Path $InputPath -Leaf)"
    return
  }

  $bak = $InputPath + ".bak"
  $tmp = $InputPath + "._compressed.png"
  Write-Host "PNG: $([System.IO.Path]::GetFileName($InputPath))"

  if ($WhatIf) {
    Write-Host "  would run: magick convert -strip (optimize) $InputPath"
    return
  }

  $before = (Get-Item $InputPath).Length
  & $magick.Source $InputPath -strip -define png:compression-level=9 -define png:compression-filter=5 $tmp
  if ($LASTEXITCODE -ne 0) { throw "magick failed for $InputPath" }
  $after = (Get-Item $tmp).Length
  if ($after -ge $before) {
    Remove-Item $tmp -Force
    Write-Host "  already optimal ($([math]::Round($before/1MB,2)) MB)"
    return
  }
  Copy-Item $InputPath $bak -Force
  Move-Item $tmp $InputPath -Force
  Write-Host ("  {0:N1} MB -> {1:N1} MB" -f ($before/1MB), ($after/1MB))
}

$ffmpeg = Get-Ffmpeg
if (-not $ffmpeg) {
  Write-Error @"
ffmpeg not found on PATH.

Install (Windows):
  winget install Gyan.FFmpeg

Then open a new terminal and re-run this script.
"@
}

$videoNames = @(
  "winn-team-realtors-demo.mp4",
  "team-doherty-demo.mp4"
)

$pngNames = @(
  "winn-team-realtors-hero.png",
  "winn-team-realtors-1-trigger.png",
  "winn-team-realtors-2-popup.png",
  "winn-team-realtors-3-mobile.png",
  "team-doherty-card.png",
  "team-doherty-1-trigger.png",
  "team-doherty-2-popup.png",
  "team-doherty-3-mobile.png",
  "burton-real-estate-card.png",
  "coach-and-carlson-card.png",
  "see-nashville-homes-card.png",
  "realty-candy-card.png"
)

Write-Host "Portfolio dir: $PortfolioDir"
Write-Host ""

foreach ($name in $videoNames) {
  $path = Join-Path $PortfolioDir $name
  if (Test-Path $path) { Compress-Video $path $ffmpeg }
  else { Write-Warning "Missing: $name" }
}

if (-not $VideosOnly) {
  foreach ($name in $pngNames) {
    $path = Join-Path $PortfolioDir $name
    if (Test-Path $path) { Compress-Png $path }
    else { Write-Warning "Missing: $name" }
  }
}

Write-Host ""
Write-Host "Done. Review visuals, then: git add bill/assets/portfolio && git commit"
Write-Host "Delete *.bak when satisfied."
