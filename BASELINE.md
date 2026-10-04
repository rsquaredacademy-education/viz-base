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

- **`docs/references.html` is back.** Present at tag `bookdown-legacy` (`git ls-tree
  bookdown-legacy docs/`), absent after the Quarto migration because no chapter emitted a
  references section. This was a live URL deletion, not just a missing page. Resolved on
  2026-10-04 by adding `references.qmd`, which restores the slug and carries the sources
  for every claim in Chapter 1 plus dataset provenance. CI now asserts the slug
  explicitly, because a silent drop is how it disappeared the first time.
- **`img/intro-r.png` stays.** (309 KB, tracked.) The `data-viz.png` reference removed
  in Phase 0.9 was meant to be repointed here, leaving the asset unreferenced. Checked
  against the sibling books on 2026-10-04: `data-wrangling`, `viz-ggplot2` and `rdbsql`
  all carry the same five-image cross-promotion set (`intro-r`, `rdbsql`, `viz-base`,
  `viz-ggplot2`, `wrangle-r`) and none of them references `intro-r.png` either. Carrying
  it unused is the house pattern, so deleting it here would have made viz-base the only
  sibling missing the asset. No action.
- **Unlogged content bugs found during the Phase 0/1 residue sweep** (all fixed): the
  roadmap's DoD clauses for tasks 0.5, 0.7, 0.9 and 0.10 were not fully met even though
  `daily-logs.md` recorded Phase 0 as complete.
- **The preface was silently consuming Chapter 1.** `index.qmd` carried both YAML
  `title:` and `# Preface {.unnumbered}`. Quarto renders the YAML title as a numbered
  chapter, so every page shipped one number too high — the site read "2 Introduction"
  through "11 Faceting", contradicting both `README.md` and the roadmap's own numbering
  plan. `numbering: false` does *not* fix this; it applies only to the markdown H1. Fixed
  2026-10-04 by dropping `title`/`subtitle`/`author` from `index.qmd`, which is what all
  four sibling books do — those values already live in `_quarto.yml: book:`.
- **No page had a `<meta name="description">` at all**, and every page shared one
  site-wide `og:description`. Fixed 2026-10-04: each chapter now carries `description:`
  front matter, and `includes/head.html` holds the placeholder Quarto rewrites it from.
  Per-chapter descriptions were the precondition for the figure alt-text work, since
  captions and descriptions turned out to be the same task.

## Still outstanding

- ~~GA4 measurement ID~~ — resolved 2026-10-04, see below.
- **No citable DOI yet.** `.zenodo.json` is filled in and `citation.bib` exists, but
  minting requires a Zenodo account action. See `HOW-TO-CITE.md`. Until it exists the
  citation deliberately has no `doi` field rather than a placeholder that would resolve
  to nothing.
- **Figure captions and alt-text are partial.** 49 of 191 figures — the argument-carrying
  ones plus everything in the three Phase 2 chapters — have both. The remainder are
  gallery figures (a 3x2 grid of `lty` values, a 3x3 grid of `pch` values) whose content
  is fully described by the surrounding prose.
- **Lighthouse and build time are still unmeasured.** No figure recorded for either.
- **No end-of-chapter exercises outside Chapter 12.** The roadmap blocker list also called
  for a `solutions/` directory; Chapter 12's solutions are inline and collapsed.
- **Search Console and outreach** need browser access, not code.

## Analytics (added 2026-10-04)

GA4 measurement ID `G-P98W8WC0XC`, wired up in `includes/analytics.html` rather than
`_quarto.yml`. Both halves of Quarto's native mechanism turned out to be unusable here,
and both were confirmed by experiment rather than by reading docs:

- `website.google-analytics` is **silently ignored for `type: book`**. The same config
  emits a gtag tag in a minimal `type: website` project and emits nothing in this book,
  with no warning or error.
- `website.cookie-consent` **does not exist in Quarto 1.6.40**, the version CI pins
  because newer Quarto breaks the Typst PDF.

Quarto's own analytics injects unconditionally, so a reader could not refuse — a banner
would have been theatre. Instead the Google script element is created only inside the
accept branch: before consent, nothing is requested from Google, no cookie is written and
no measurement ID is transmitted. The choice is stored in `localStorage` and is reversible
from an "Analytics preferences" button on every page (the 1.6.40 book template has no
`<footer>` to inject into, so it is anchored bottom-left).

`privacy.html` is a hand-written static page, added to `project.resources` and copied by
CI. It is not a chapter: it is legal text, not book content, and a chapter would give it a
chapter number.

CI asserts the negative rather than the positive — a *static* gtag script tag in any
output page fails the build, because that is the exact regression that would silently
reintroduce unconditional tracking. It also asserts `privacy.html` made it into `docs/`.

Verified: no analytics reference of any kind in the PDF or the ePub.
