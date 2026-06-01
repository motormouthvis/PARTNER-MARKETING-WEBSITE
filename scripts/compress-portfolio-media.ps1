# Generate web-optimized portfolio assets from local PNG/MP4 masters.
# Requires: ffmpeg (winget install Gyan.FFmpeg)
#
# Usage (from repo root):
#   .\scripts\compress-portfolio-media.ps1
#   .\scripts\compress-portfolio-media.ps1 -VideosOnly
#   .\scripts\compress-portfolio-media.ps1 -WhatIf
#
# Outputs (committed to git):
#   Grid cards     -> {name}.webp + {name}.jpg  at 800px max width
#   Lightbox shots -> {name}.webp + {name}.jpg  at 1200px max width
#   Videos         -> compressed {name}.mp4
#
# Source PNG masters stay local (gitignored). Re-run after replacing a screenshot.

param(
  [switch]$VideosOnly,
  [switch]$ImagesOnly,
  [switch]$WhatIf,
  [int]$CardWidth = 800,
  [int]$LightboxWidth = 1200,
  [int]$MaxVideoWidth = 1280,
  [int]$Crf = 26,
  [int]$WebpQuality = 82,
  [int]$JpegQuality = 85
)

$ErrorActionPreference = "Stop"
$PortfolioDir = Join-Path $PSScriptRoot "..\bill\assets\portfolio" | Resolve-Path
$BytesPerMb = 1048576

function Get-Ffmpeg {
  $cmd = Get-Command ffmpeg -ErrorAction SilentlyContinue
  if ($cmd) { return $cmd.Source }
  $wingetRoot = Join-Path $env:LOCALAPPDATA "Microsoft\WinGet\Packages"
  if (Test-Path $wingetRoot) {
    $found = Get-ChildItem $wingetRoot -Recurse -Filter "ffmpeg.exe" -ErrorAction SilentlyContinue |
      Where-Object { $_.DirectoryName -match "\\bin$" } |
      Select-Object -First 1 -ExpandProperty FullName
    if ($found) { return $found }
  }
  return $null
}

function Format-Mb([long]$Bytes) {
  return "{0:N2} MB" -f ($Bytes / $BytesPerMb)
}

function Compress-Video([string]$InputPath, [string]$Ffmpeg) {
  $dir = Split-Path $InputPath -Parent
  $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
  $tmp = Join-Path $dir ($base + "._compressed.mp4")

  $args = @(
    "-hide_banner", "-loglevel", "error",
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

  # ffmpeg logs to stderr; redirect so $ErrorActionPreference='Stop' doesn't
  # treat the banner as a terminating error. Rely on $LASTEXITCODE instead.
  & $Ffmpeg @args 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg failed for $InputPath" }

  $before = (Get-Item $InputPath).Length
  $after = (Get-Item $tmp).Length
  Move-Item $tmp $InputPath -Force
  Write-Host ("  {0} -> {1}" -f (Format-Mb $before), (Format-Mb $after))
}

function Export-Image([string]$InputPath, [string]$Ffmpeg, [int]$MaxWidth) {
  $dir = Split-Path $InputPath -Parent
  $base = [System.IO.Path]::GetFileNameWithoutExtension($InputPath)
  $webp = Join-Path $dir ($base + ".webp")
  $jpg = Join-Path $dir ($base + ".jpg")
  $scale = "scale='min($MaxWidth,iw)':-2:flags=lanczos"

  Write-Host "Image ($MaxWidth px): $([System.IO.Path]::GetFileName($InputPath))"

  if ($WhatIf) {
    Write-Host "  would write: $base.webp, $base.jpg"
    return
  }

  $before = (Get-Item $InputPath).Length

  # ffmpeg logs to stderr; redirect so $ErrorActionPreference='Stop' doesn't
  # treat the banner as a terminating error. Rely on $LASTEXITCODE instead.
  & $Ffmpeg -hide_banner -loglevel error -y -i $InputPath -vf $scale -c:v libwebp -quality $WebpQuality $webp 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg webp failed for $InputPath" }

  & $Ffmpeg -hide_banner -loglevel error -y -i $InputPath -vf $scale -q:v $JpegQuality $jpg 2>&1 | Out-Null
  if ($LASTEXITCODE -ne 0) { throw "ffmpeg jpeg failed for $InputPath" }

  $webpSize = (Get-Item $webp).Length
  $jpgSize = (Get-Item $jpg).Length
  Write-Host ("  source {0} -> webp {1}, jpg {2}" -f (Format-Mb $before), (Format-Mb $webpSize), (Format-Mb $jpgSize))
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

# Card images: 800px wide (grid thumbnails)
$cardSources = @(
  @{ png = "winn-team-realtors-hero.png"; width = $CardWidth },
  @{ png = "team-doherty-card.png"; width = $CardWidth },
  @{ png = "burton-real-estate-card.png"; width = $CardWidth },
  @{ png = "coach-and-carlson-card.png"; width = $CardWidth },
  @{ png = "see-nashville-homes-card.png"; width = $CardWidth },
  @{ png = "realty-candy-card.png"; width = $CardWidth }
)

# Lightbox screenshots: 1200px wide
$lightboxSources = @(
  "winn-team-realtors-1-trigger.png",
  "winn-team-realtors-2-popup.png",
  "winn-team-realtors-3-mobile.png",
  "team-doherty-1-trigger.png",
  "team-doherty-2-popup.png",
  "team-doherty-3-mobile.png"
)

$videoNames = @(
  "winn-team-realtors-demo.mp4",
  "team-doherty-demo.mp4"
)

Write-Host "Portfolio dir: $PortfolioDir"
Write-Host "Card width: $CardWidth px | Lightbox width: $LightboxWidth px"
Write-Host ""

if (-not $VideosOnly) {
  foreach ($item in $cardSources) {
    $path = Join-Path $PortfolioDir $item.png
    if (Test-Path $path) { Export-Image $path $ffmpeg $item.width }
    else { Write-Warning "Missing card source: $($item.png)" }
  }

  foreach ($name in $lightboxSources) {
    $path = Join-Path $PortfolioDir $name
    if (Test-Path $path) { Export-Image $path $ffmpeg $LightboxWidth }
    else { Write-Warning "Missing lightbox source: $name" }
  }
}

if (-not $ImagesOnly) {
  foreach ($name in $videoNames) {
    $path = Join-Path $PortfolioDir $name
    if (Test-Path $path) { Compress-Video $path $ffmpeg }
    else { Write-Warning "Missing: $name" }
  }
}

Write-Host ""
Write-Host "Done. Review in browser, then:"
Write-Host "  git add bill/assets/portfolio/*.webp bill/assets/portfolio/*.jpg bill/assets/portfolio/*.mp4"
Write-Host "  git commit -m 'Optimize portfolio media for web delivery.'"
