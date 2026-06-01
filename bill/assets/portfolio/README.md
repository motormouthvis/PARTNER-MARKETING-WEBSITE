# Portfolio media

Drop real screenshots / videos here using the **exact filenames below**. Until a
file exists, the Portfolio page automatically shows a stock photo fallback, so
nothing looks broken in the meantime. Just add the file with the matching name
and push — no HTML edits needed.

Recommended sizes: card images ~900×560 (16:10), walkthrough screenshots
~1100px wide, mobile screenshot ~700px wide (tall/portrait), video MP4 (muted,
short loop).

## Grid card thumbnails (all 6 partners)

- `winn-team-realtors-card.png`
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

## Arrow direction (per site)

The animated arrow on the first screenshot points at the floating Dream
Neighborhood icon. Its corner is set per partner in the `PARTNERS` config inside
`portfolio.html` via `arrow: "bottom-left"` or `arrow: "bottom-right"`.

- **Winn Team Realtors → bottom-left** (their site has a help bubble in the
  bottom-right, so the DN icon sits lower-left).
- Set each new partner's corner to wherever the DN icon actually appears on
  that site.

## Notes
- Filenames are case-sensitive on the live (Netlify) server — keep them lowercase exactly as above.
- To make a different partner use the lightbox walkthrough, tell me and I'll swap which cards open the modal.
