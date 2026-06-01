# Portfolio media

Drop real screenshots / videos here using the **exact filenames below**, then run
`scripts/compress-portfolio-media.ps1` to generate the web-delivery files. Until a
file exists, the Portfolio page automatically shows a stock photo fallback, so
nothing looks broken in the meantime.

## Masters vs. delivery files

- **PNG masters** (the filenames below): the high-res source screenshots. These
  stay **local only** — they are gitignored and **not** committed.
- **Delivery files**: the script produces a `.webp` + `.jpg` for every PNG (the
  page uses `<picture>` with a WebP source and JPEG fallback) and a compressed
  `.mp4` for each demo video. **These small files are what gets committed** (via
  regular git — no LFS).

So after adding/replacing a PNG: run the script, then commit only the resulting
`.webp` / `.jpg` / `.mp4` files. No HTML edits needed.

Recommended source sizes: card images ~900×560 (16:10), walkthrough screenshots
~1100px+ wide, mobile screenshot tall/portrait, video MP4 (muted, short loop).

## Grid card thumbnails (all 6 partners)

- `winn-team-realtors-hero.png`  _(the Winn grid card uses the hero file)_
- `team-doherty-card.png`
- `burton-real-estate-card.png`
- `coach-and-carlson-card.png`
- `see-nashville-homes-card.png`
- `realty-candy-card.png`

## Walkthrough media (lightbox partners — currently Winn & Team Doherty)

### Winn Team Realtors  (added ✓)
- `winn-team-realtors-1-trigger.png`  — listing page showing the "Explore the Neighborhood" trigger button
- `winn-team-realtors-2-popup.png`    — the neighborhood popup open
- `winn-team-realtors-3-mobile.png`   — mobile version (portrait)
- `winn-team-realtors-demo.mp4`       — short looping, no-sound full-experience video

### Team Doherty  (added ✓)
- `team-doherty-card.png`              — grid card / hero thumbnail
- `team-doherty-1-trigger.png`         — listing page showing the trigger
- `team-doherty-2-popup.png`           — neighborhood popup open
- `team-doherty-3-mobile.png`          — mobile experience (screenshot)
- `team-doherty-demo.mp4`              — full-experience video

### Visit-site partners  (card heroes added ✓)
- `burton-real-estate-card.png`
- `coach-and-carlson-card.png`
- `see-nashville-homes-card.png`
- `realty-candy-card.png`

## Red marker circle (per site)

The hand-drawn circle on the first screenshot is tuned per partner in
`portfolio.html` via `marker: "winn"`, `marker: "doherty"`, etc. (CSS classes
`pf-marker--winn`, `pf-marker--doherty`). Both Winn and Team Doherty use the
**lower-left** DN icon; help/chat widgets sit on the right.

- **Winn Team Realtors → `marker: "winn"`**
- **Team Doherty → `marker: "doherty"`**

## Notes
- Filenames are case-sensitive on the live (Netlify) server — keep them lowercase exactly as above.
- To make a different partner use the lightbox walkthrough, tell me and I'll swap which cards open the modal.
