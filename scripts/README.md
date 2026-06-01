# Portfolio media compression

Walkthrough videos in `bill/assets/portfolio/` are large screen recordings. Compressing them before deploy dramatically improves Portfolio and lightbox load times.

## One-time setup (Windows)

```powershell
winget install Gyan.FFmpeg
```

Optional (PNG optimization — ImageMagick):

```powershell
winget install ImageMagick.ImageMagick
```

Close and reopen the terminal so `ffmpeg` is on PATH.

## Compress manually

From the repo root:

```powershell
.\scripts\compress-portfolio-media.ps1
```

- **Videos only** (fastest first pass): `.\scripts\compress-portfolio-media.ps1 -VideosOnly`
- **Dry run**: `.\scripts\compress-portfolio-media.ps1 -WhatIf`
- **Quality**: `-Crf 24` (larger, sharper) or `-Crf 28` (smaller). Default `26` is a good web balance.
- **Resolution cap**: `-MaxVideoWidth 1280` (default). Use `1920` if you need full HD.

The script backs up each file as `*.bak`, then replaces the original. Spot-check in the browser, delete `.bak` files, commit, and push.

## What the video settings mean

| Setting | Purpose |
|--------|---------|
| `-crf 26` | Quality knob for H.264 (roughly 18–28; lower = better, bigger) |
| `scale=min(1280,iw)` | Downscale wide screen captures; huge win for file size |
| `-an` | No audio (demos are muted anyway) |
| `-movflags +faststart` | Puts metadata at the start so playback can begin while downloading |

Typical results: **30–50 MB → ~3–8 MB** for a 1–2 minute screen demo.

## Automate it

**Option A — Run before each deploy (local habit)**  
Add to your release checklist: run the script after replacing screenshots or re-recording a demo.

**Option B — Git hook (local)**  
Create `.git/hooks/pre-push` (not committed) that runs the script when `bill/assets/portfolio/*.mp4` changed. Ask if you want this wired in the repo as an optional hook template.

**Option C — GitHub Action (CI)**  
On push to `main`, a workflow could run `ffmpeg` in the runner, commit optimized assets, or fail if files exceed a size budget. Useful for teams; needs LFS-aware checkout (`lfs: true`).

**Option D — Re-encode at source**  
When recording, export at 1280p and ~5 Mbps from your screen recorder — less to fix later.

## PNGs

Card and screenshot PNGs in this folder are also very large (multi‑MB). ImageMagick helps somewhat; for the biggest wins:

1. Export walkthrough shots at **~1100px wide** before saving.
2. Or convert cards to **WebP** (smaller) and update `portfolio.html` — a follow-up change.

## After compressing

```powershell
git add bill/assets/portfolio
git status
git commit -m "Compress portfolio walkthrough media for faster loads."
git push
```

Git LFS still applies; you are storing **smaller** blobs, which is what you want.
