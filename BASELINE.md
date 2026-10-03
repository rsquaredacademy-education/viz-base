# Baseline — Day 0 (Phase 0.0)

- Date: 2026-09-26
- Repo: rsquaredacademy-education/viz-base (`bookdown::gitbook` → `docs/`)
- R: 4.5.2 (ucrt); bookdown 0.48 (installed); `_bookdown.yml` legacy gitbook stack
- Git HEAD: 1bd2625 (8 commits total); tag `bookdown-legacy` → see 0.1
- `docs/` slugs: index, intro, titlelabels, scatter, line, bar, box, hist, legend, textann, facet, about-the-author, references
- Known debt: UA `UA-57270671-37` in `google-analytics.html`; `style.css` 14 lines; no PDF/EPUB; fragile UCLA CSV (06); missing `data-viz.png` (01-intro:19); `{c}` placeholder (08-legends:291)
- Link check: `lychee` not installed locally — run in CI weekly post-Phase-0 (UCLA URL excluded after vendoring)
- Build time: `bookdown::render_book()` was the intended measurement but the toolchain was
  replaced during Phase 1, so no clean-build time was ever recorded against this baseline.
  Current figure for reference (full `quarto render`, all three formats, warm `_freeze/`,
  local Windows dev box): ~2 min. CI timings are in the render workflow logs.

## Deltas recorded after the fact

Phase 0.11 (QA render) and task 0.0 were closed without leaving artifacts, so the items
below are back-filled from the git history. Flagged here rather than in the roadmap, which
is the planning document.

- **`docs/references.html` is gone.** Present at tag `bookdown-legacy` (`git ls-tree
  bookdown-legacy docs/`), absent after the Quarto migration because no chapter emits a
  references section. This is a live URL deletion, not just a missing page — either restore
  a references chapter or leave a redirect at that path. It is deliberately absent from
  `sitemap.xml` (13 entries = 12 chapters + root), so it was a silent drop.
- **`img/intro-r.png` is an orphan** (309 KB, tracked). The `data-viz.png` reference removed
  in Phase 0.9 was meant to be repointed here, but `intro.qmd` ended up with no image
  reference at all. Either place the figure or drop the asset.
- **Unlogged content bugs found during the Phase 0/1 residue sweep** (all fixed): the
  roadmap's DoD clauses for tasks 0.5, 0.7, 0.9 and 0.10 were not fully met even though
  `daily-logs.md` recorded Phase 0 as complete.
