# Portfolio media compression

Walkthrough screenshots are exported at 4K but the site displays them at ~800–1200px.
This script generates **WebP + JPEG** delivery files from local PNG masters and
compresses demo videos.

## One-time setup (Windows)

```powershell
winget install Gyan.FFmpeg
```

Close and reopen the terminal, or refresh PATH:

```powershell
$env:Path = [System.Environment]::GetEnvironmentVariable("Path","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("Path","User")
ffmpeg -version
```

## Generate web assets

From the repo root:

```powershell
.\scripts\compress-portfolio-media.ps1
```

- **Videos only**: `.\scripts\compress-portfolio-media.ps1 -VideosOnly`
- **Images only**: `.\scripts\compress-portfolio-media.ps1 -ImagesOnly`
- **Dry run**: `.\scripts\compress-portfolio-media.ps1 -WhatIf`

## What gets created

| Source (local, gitignored) | Output (committed) | Max width |
|---|---|---|
| `winn-team-realtors-hero.png` | `.webp` + `.jpg` | 800px (grid card) |
| `*-card.png` | `.webp` + `.jpg` | 800px |
| `*-1-trigger.png`, `*-2-popup.png` | `.webp` + `.jpg` | 1200px (lightbox) |
| `*-3-mobile.png` | `.webp` + `.jpg` | 1200px |
| `*-demo.mp4` | compressed `.mp4` | 1280px wide, no audio |

**Typical results:** grid total ~500 KB (was ~34 MB), walkthrough ~1 MB (was ~6 MB).

## Workflow when adding a partner

1. Drop the PNG master(s) in `bill/assets/portfolio/` using names from `README.md` there.
2. Run `.\scripts\compress-portfolio-media.ps1`.
3. Spot-check `/bill/portfolio.html` locally.
4. Commit the `.webp`, `.jpg`, and `.mp4` files — not the PNG masters.

## Git LFS

Delivery assets no longer use Git LFS. The root `.gitattributes` no longer routes
`*.mp4` or `bill/assets/portfolio/*.png` through LFS — the small WebP/JPEG/MP4
files ship through regular git, and the large PNG masters stay local (gitignored
via `bill/assets/portfolio/.gitignore`).

Portfolio PNG paths were removed from git tracking (they were LFS pointers); only
`.webp` / `.jpg` / `.mp4` delivery files live in the repo now. Older commits still
contain LFS metadata for those PNG paths if you check them out — history was not
rewritten.
