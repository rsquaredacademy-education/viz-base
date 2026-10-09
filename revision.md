# Revision Notes

**Date:** 2026-10-05
**Scope:** Structural and build-consistency review (wave 1 — correctness)
**Author:** automated review pass, render-verified with Quarto 1.6.40

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-publications/viz-base/blob/master/AUTHOR-STANDARDS.md). This file records only what changed in
**this** repository.

---

## Summary

Two small changes:

1. Five "Putting it all together" headings reduced to one exact spelling.
2. Three Preface headings switched from `{-}` to `{.unnumbered}`.

Plus a `LICENSE` file. No URLs, slugs or redirects affected.

---

## 1. Heading spelling normalized

"Putting it all together" shipped in three variants across this book. Text is
now one exact string at all five sites:

| File | Before | After |
|:--|:--|:--|
| `bar.qmd` | `## Putting it all together...` | `## Putting it all together` |
| `facet.qmd` | `## Putting it all together...` | `## Putting it all together` |
| `line.qmd` | `## Putting it all together...` | `## Putting it all together` |
| `hist.qmd` | `## Putting it all together..` | `## Putting it all together` |
| `box.qmd` | `## Putting it all together` | *already correct — the reference spelling* |

The bare spelling in `box.qmd` was treated as canonical and the other four
brought into line. `viz-base` had the same problem and was fixed in the same
pass, so both books now agree with each other as well as internally.

Heading levels were left alone — all five are `##`, and no structural change was
wanted.

Checked beforehand that nothing cross-references
`#putting-it-all-together`, so no anchor was broken.

---

## 2. Unnumbered attribute normalized

`index.qmd` mixed both accepted spellings of the unnumbered attribute in a
single file:

```markdown
# Preface {.unnumbered}      ← correct
## Software information {-}
## How to cite this book {-}
## Corrections {-}
```

All three `{-}` converted to `{.unnumbered}`, giving one spelling per book
across the workspace. (`bash-intro` had the same mix and was fixed in the same
pass.)

This is cosmetic — both spellings render identically. It matters for
consistency and for grep-ability.

---

## 3. LICENSE added

`LICENSE` — verbatim CC BY-NC-SA 4.0 International legal code (438 lines),
fetched from `creativecommons.org`. License text is never reconstructed from
memory.

This book already declared CC BY-NC-SA 4.0 in `.zenodo.json`, in
`README.md`, and in its Preface; there is now a root `LICENSE` to match.

---

## Verification

Rendered with Quarto **1.6.40**; no errors or warnings. Confirmed in output:

| Page | Rendered heading |
|:--|:--|
| `bar.html` | `6.8 Putting it all together` |
| `box.html` | `7.5 Putting it all together` |
| `facet.html` | `11.6 Putting it all together` |
| `hist.html` | `8.10 Putting it all together` |
| `line.html` | `5.9 Putting it all together` |

0 unresolved `??` cross-references.

---

## Before committing

- Git reports `LF will be replaced by CRLF` for `index.qmd`. Pre-existing repo
  line-ending behaviour, not introduced here, but it may enlarge the diff on
  next checkout.
- Suggested message: `docs: unify heading spellings`

---

## Not done here (tracked in the workspace checklist)

This is the most complete book in the workspace — it already has the
`AUTHORING.md` authoring guide, a References chapter, a How-to-cite section
with a Zenodo DOI, and consent-gated analytics. That pattern is worth adopting
elsewhere.

Remaining gaps:

- **No `netlify.toml`, no `_redirects`, no `scripts/test-redirects.sh`** — the
  only book with no redirect testing. Migrating to Netlify is wave 4.
- **Exercises in only 1 of 12 content chapters** (8%), yet the README frames
  "Putting it all together" as universal. Either add exercises or soften the
  README claim.
- `citation.bib` and `HOW-TO-CITE.md` sit at the repo root but are in neither
  `book.chapters`, `book.appendices` nor `project.resources`, so they never
  reach `docs/`.
- `sitemap.xml` is hand-maintained and out of order — it lists `intro.html`
  before `why-base.html`, while `_quarto.yml` has `why-base` first.
  `AUTHORING.md:20-21` requires these to stay in sync.
- No `style.css` (and none wired in `_quarto.yml`).
- No `renv.lock` / `.Rprofile`, so local package versions are unpinned.
- Callouts are unavailable on the Typst PDF
  (`AUTHORING.md:64-66`) — house style here is blockquote signposts. Two of the
  six books violate this because they use lualatex (wave 5).