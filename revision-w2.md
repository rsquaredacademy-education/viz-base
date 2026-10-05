# Revision Notes — Wave 2 (toolchain pinning)

**Date:** 2026-10-05
**Scope:** Pin the build toolchain; make PDF/ePub failures fatal
**Author:** automated review pass

Part of a workspace-wide standard for all six books, documented at
[`viz-base/AUTHOR-STANDARDS.md`](https://github.com/rsquaredacademy-education/viz-base/blob/master/AUTHOR-STANDARDS.md). This file records only what changed in
**this** repository.

---

## Summary

**No changes were needed in this book.**

Wave 2 standardised the build toolchain across all six books. This book's
`render.yml` already satisfied every requirement, so it was reviewed and
left untouched — no commit was made.

This is worth stating explicitly, because it is the reason this file exists:
the template in `BOOK-STRUCTURE-CHECKLIST.md` §2.5 was largely written from
this book's workflow.

---

## What was checked

| Requirement | State |
|:--|:--|
| Quarto pinned exactly | ✅ `1.6.40` |
| Typst pinned exactly | ✅ `0.11.0` |
| Quarto/Typst bumped together documented | ✅ in a comment |
| PDF render fatal | ✅ bare `run:`, no `\|\|` |
| ePub render fatal | ✅ bare `run:`, no `\|\|` |
| Downloads existence gate | ✅ `Verify downloads are present` |
| `fc-cache -f` after font install | ✅ |
| `mainfont` resolvable on the runner | ✅ `Linux Libertine` |
| `paths-ignore: ['docs/**']` | ✅ |
| `permissions: contents: write` | ✅ |
| Link check advisory | ✅ `continue-on-error: true` |
| Analytics consent-gated and asserted | ✅ unique to this book |

---

## Notes for the other books

**This workflow is the reference implementation.** Three specific things it
does that the others now copy:

1. **Explains *why* each pin exists**, in comments rather than leaving the
   next person to reverse-engineer it:

   ```yaml
   # Pinned to the toolchain verified locally for this book. Unpinned
   # "release" (1.10.18) + latest typst fails the PDF inside Quarto's own
   # Typst template: rgb(content-to-string(linkcolor)) -> "color string
   # contains non-hexadecimal letters". Bump both together, never one.
   ```

2. **Asserts the negative for analytics.** Because analytics is
   consent-gated by hand, a static `gtag` script tag in any page means
   Google is contacted before anyone clicks accept:

   ```bash
   if grep -rqE '<script[^>]+src="https://www\.googletagmanager\.com' docs/*.html; then
     echo "UNCONDITIONAL ANALYTICS"; exit 1
   fi
   ```

   Nothing else in the workspace has a gate that protects a privacy
   property from being silently reverted.

3. **Makes PDF and ePub fatal**, with the reason recorded:

   ```yaml
   # PDF/EPUB are required, not advisory: the roadmap's Phase 1 DoD is
   # "PDF + EPUB build clean in CI", and `downloads: [pdf, epub]` is
   # advertised on the landing page. A silent non-fatal render previously
   # shipped a green build with no PDF at all.
   ```

---

## Not done here

Wave 2 was toolchain only. This book's structural gaps are unchanged and
tracked elsewhere — most usefully, its `AUTHORING.md` documents several of
them (Typst callout limitation, `title:` front-matter hazard, cheatsheet
not being a Quarto chapter) and is the template the other five should adopt.

Specifically still open:

- No `netlify.toml`, `_redirects` or `scripts/test-redirects.sh` — the only
  book with no redirect testing. Wave 4.
- Exercises in only 1 of 12 content chapters, though the README frames
  "Putting it all together" as universal. Wave 7.
- `citation.bib` and `HOW-TO-CITE.md` never reach `docs/`.
- `sitemap.xml` is hand-maintained and out of order relative to
  `_quarto.yml`, which `AUTHORING.md:20-21` requires to stay in sync.
- No `renv.lock` / `.Rprofile`.