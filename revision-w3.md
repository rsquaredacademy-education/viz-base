# Revision Notes — Wave 3 (CI convergence)

**Date:** 2026-10-05
**Scope:** One workflow shape per book; gates that cannot drift
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-publications/viz-base/blob/master/AUTHOR-STANDARDS.md).
This file records only what changed in **this** repository.

---

## Summary

- Generate `sitemap.xml` instead of hand-maintaining it.
- Add `scripts/verify-sitemap.sh` — **found a live page missing from the
  sitemap**.
- Replace the hand-maintained slug list with `scripts/verify-slugs.sh`.
- Add a cross-reference gate — this book carries 2 `@sec-` references and had none.
- Add `scripts/make-sitemap.sh`.
- Update `AUTHORING.md`.

This is the canonical host of the workspace standard, so the gates added here
were written to be copied verbatim.

---

## 1. The hand-maintained sitemap was missing a page

`scripts/verify-sitemap.sh` reported it on first run:

```
SITEMAP is missing rendered pages:
  privacy.html
```

`privacy.html` is live, linked from the book's privacy notice, and referenced by
the consent-gate step in this very workflow — but it was absent from the
sitemap. The file also listed `intro.html` before `why-base.html`, contradicting
`_quarto.yml`, which `AUTHORING.md:20-21` explicitly required it to match.

**A count-based gate would have missed this.** The file had 17 entries for 17
pages, because a bare `/` root entry — not a page — offset the missing one. The
new gate compares sets, so it names the page instead of balancing past it.

---

## 2. The sitemap is now generated

`scripts/make-sitemap.sh` runs after the HTML render. The root `sitemap.xml` is
deleted, and `_quarto.yml` no longer lists it under `resources`, since there is
no root copy to copy in.

`AUTHORING.md:20-21` claimed the file was hand-maintained because "Quarto book
sitemap generation is unreliable here". That rationale was stale — `sitemap: true`
was set in `_quarto.yml` and then immediately overwritten by a `cp`. The comment
described a workaround for a problem that no longer applied. Rewritten to
describe generation.

---

## 3. Slug and cross-reference gates

The 16-slug list is replaced by `scripts/verify-slugs.sh`, derived from
`_quarto.yml`. Added the unresolved-cross-reference gate, which this book lacked
despite carrying 2 `@sec-` references.

---

## Two traps this work exposed

**Do not add `set -e` to `verify-slugs.sh`.** Under it, a failing `[ ! -f ]` can
abort the script before the explicit `exit 1`, and the shell reports success —
the gate prints `FAIL` while CI stays green. The script sets exit status
explicitly and says so in a comment.

**The sitemap generator must recurse.** A flat listing emits `/foo.html` for a
page served at `/appendices/foo.html`, which is a 404 for a crawler. This book
has no subdirectory pages, but the other books do, so the shared version
recurses.

---

## Verification

- Slug gate: all 16 chapters pass against committed `docs/`.
- Sitemap gate: all 17 pages covered, including the recovered `privacy.html`.
- Negative controls: removing `legend.html` makes the sitemap gate exit 1;
  removing `references` makes the slug gate exit 1; hand-deleting
  `privacy.html` from the sitemap makes it exit 1.
- Workflow parses as valid YAML; 20 steps.
- CI green (2m40s, deployed to GitHub Pages).

Confirmed live: `https://viz-base.rsquaredacademy.com/sitemap.xml` now lists 19
URLs including `privacy.html`.

---

## Commits

| SHA | Message |
|:--|:--|
| `f0c48f8` | ci: generate the sitemap and replace hand-maintained gates |

---

## Not done here

- No `netlify.toml`, `_redirects` or `scripts/test-redirects.sh` — the only book
  with no redirect testing. Wave 4.
- **Exercises in only 1 of 12 content chapters** (8%), though the README frames
  "Putting it all together" as universal. Wave 7.
- `citation.bib` and `HOW-TO-CITE.md` sit at the root but are in neither
  `book.chapters`, `book.appendices` nor `project.resources`, so they never
  reach `docs/`.
- No `renv.lock` / `.Rprofile`.
- **This repo now also hosts `AUTHOR-STANDARDS.md`**, the workspace-wide
  standard. It was moved here from the workspace root, which is not a git
  repository, so it was unversioned and unreachable from a clone of any single
  book. Every book's revision notes link here.

`AUTHORING.md` remains the viz-base-specific companion to that standard — this
book's constraints, and the four failure modes that break silently.