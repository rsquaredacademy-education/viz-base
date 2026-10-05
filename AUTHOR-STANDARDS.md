# Rsquared Ebooks — Structure & Build Checklist

The conformance standard for every book in this workspace, and the template for
any new book. Applies to the six current titles:

`bash-intro` · `data-wrangling` · `intro-r` · `rdbsql` · `viz-base` · `viz-ggplot2`

## Where this document lives

**Canonical home: `AUTHOR-STANDARDS.md` in this repository** (`viz-base`).
It is versioned here, so `git clone` of any single book that points at it gets
the current standard.

Each book is an independent git repository on `master`; there is no repository
that owns the workspace root. The standard is therefore kept here rather than
in all six repos, because six copies drift immediately.

`viz-base` was chosen as the host for two reasons: it is the most complete book
in the set (References, How-to-cite with a DOI, an `AUTHORING.md`, and
consent-gated analytics), and its `render.yml` is already the reference CI
implementation the others were aligned to in wave 2.

**Per-book context that is not here:** each repo's own `revision.md` and
`revision-w2.md` record what changed in that book and what is still open. This
document holds only what is shared.

**Companion document:** `AUTHORING.md` in this repo documents the
viz-base-specific constraints, including the four failure modes that break
silently. Read both when working on any book — this one for what must be true,
`AUTHORING.md` for the traps in this particular book.

**House decisions** (2026-10-05, settled — not open questions):

| Decision | Standard |
|:---|:---|
| Engine | Quarto `type: book` — bookdown is fully retired |
| Hosting | Netlify, via `netlify.toml` + `_redirects` |
| PDF | Typst, with Quarto and Typst pinned **as a pair** |
| Chapter filenames | Bare topical slugs; order lives in `_quarto.yml` only |
| Solutions | Separate `solutions/` folder, one file per chapter slug |
| Output | `output-dir: docs`, committed by CI |

---

## 1. Findings

All six books are Quarto, on `master`, with clean working trees, last touched
2026-09-29 → 2026-10-04. The bookdown → Quarto migration is complete everywhere.
The books are individually strong; divergence is real but shallow, and clusters
in four places: front/back matter, chapter-internal conventions, toolchain pins,
and repo scaffolding.

The CI *skeleton* is already close to uniform — every book stages HTML/PDF/ePub
to `/tmp`, assembles `docs/`, tests redirects, runs a link check, and commits
output. What differs is the pins and which gates block.

### 1.1 Front and back matter

| | bash-intro | data-wrangling | intro-r | rdbsql | viz-base | viz-ggplot2 |
|:--|:--|:--|:--|:--|:--|:--|
| Preface | 2nd H1 *inside* `index.qmd` | own chapter | own chapter | own chapter | own chapter | own chapter (17 lines — thinnest) |
| About the Author | **absent** | 2nd | 2nd | 2nd | **last of 15** | 2nd |
| Exercise solutions | `solutions/` (12), **0 chapter links** | **rendered chapter 14** | n/a | `solutions/` (3) | **inline `<details>`** | `solutions/` (16, **1 mislinked**) |
| Appendices | **no `appendices:` key at all** | 3 | n/a | 2 | 1 | **no `appendices:` key** |
| References | `##` inside conclusion | absent | absent | absent | **own chapter** | absent |
| Cheat sheet | chapter | absent | absent | chapter | **`.typ` artifact only** | **8-line stub shipped live** |
| Conclusion chapter | yes | absent | absent | absent | absent | absent |
| How to cite | absent | absent | absent | absent | **yes** | absent |

`viz-base` is the only book with References, a How-to-cite section, and a
`.zenodo.json` DOI. Every other book is missing at least two of the three.

### 1.2 Chapter conventions

| | bash-intro | data-wrangling | intro-r | rdbsql | viz-base | viz-ggplot2 |
|:--|:--|:--|:--|:--|:--|:--|
| Exercises coverage | **13/13** | 6/14 | n/a | 3/7 | **1/12** | 16/22 |
| Exercise heading | `## Exercises` | `##/### Your Turn…` | — | `## Exercises` | `## Exercises` | `## Exercises` |
| H1 discipline | 3 violations | clean | clean | clean | clean | clean |
| Front matter | 5 mixed schemes | `description:` only | mixed | none | `description:` only | none |
| Filename scheme | slug | `00-`…`14-` | slug | slug | slug | `ggplot2-` prefix |
| Closing section | `## Exercises` | `## Try it live` (9/14) | — | none | `## Putting it all together` (5/12) | `## Where to go next` (22/22) |

**One correctness bug, not a style issue.** `viz-ggplot2/ggplot2-quicktour.qmd:178`
points at `solutions/scatter.md`. The correct `solutions/quicktour.md` exists, is
complete and matches the chapter's three exercises, and is referenced by nothing —
while `scatter.md` is referenced by two chapters.

### 1.3 Build and CI

| | R | Quarto | PDF | Deploy | Redirect gate | Slug gate | Sitemap |
|:--|:--|:--|:--|:--|:--|:--|:--|
| bash-intro | 4.4.2 | 1.6.40 | typst | Netlify | yes | **no** | `make-sitemap.sh` |
| data-wrangling | 4.5 | **`release`** | lualatex | Netlify | yes | yes | static file |
| intro-r | 4.5 | 1.6.40 | typst | Pages\* | yes | yes + stale check | `make-sitemap.sh` |
| rdbsql | 4.4.2 | 1.10.18 | typst | Pages | yes | **no** | post-render |
| viz-base | 4.5 | 1.6.40 | typst 0.11.0 | Pages | **no script** | yes | static file |
| viz-ggplot2 | 4.5 | **`release`** | lualatex | Netlify | yes | yes | `make-sitemap.sh` |

\* intro-r's workflow deploys to Pages, yet it ships `netlify.toml` and
`_redirects`, and CI Gate 2 checks that "legacy slugs must not exist as stale
files shadowing Netlify 301s". The target is genuinely ambiguous.

**Three unpinned `release` Quarto versions are the largest latent risk.**
data-wrangling and viz-ggplot2 will break on any upstream change, with no commit
to bisect against.

Two books make PDF and ePub non-fatal (`|| echo "PDF_FAILED=1" >> $GITHUB_ENV`),
which once shipped a green build advertising `downloads: [pdf, epub]` with no PDF
in it. viz-base is the counter-example: it makes them fatal and explicitly notes
why.

### 1.4 Repo scaffolding

| | bash-intro | data-wrangling | intro-r | rdbsql | viz-base | viz-ggplot2 |
|:--|:--|:--|:--|:--|:--|:--|
| `LICENSE` at root | **none of six** | | | | | |
| `renv.lock` + `.Rprofile` | yes | yes | yes | **no** | **no** | **no** |
| `.devcontainer/` | yes | no | no | yes | no | no |
| `scripts/make-sitemap.sh` | yes | **no** | yes | **no** | **no** | yes |
| `scripts/test-redirects.sh` | yes | yes | yes | yes | **no** | yes |
| `scripts/webr-smoke.R` | n/a | yes | yes | n/a | yes | **yes (uses WebR)** |
| `netlify.toml` | yes | yes | yes | **no** | **no** | yes |
| `_redirects` | yes (11) | no | via toml | yes (2) | **no** | via toml |
| `docs/` committed | no (ignored) | 176 files | 51 | 38 | 175 | 361 |

- **CC BY-NC-SA 4.0 is asserted in README prose only — no `LICENSE` file exists in
  any of the six.** Only viz-base declares it machine-readably, in `.zenodo.json`.
- **Three analytics conventions coexist.** `google-analytics.html` (bash-intro,
  data-wrangling, viz-ggplot2), `_ga_partial.html` (intro-r, rdbsql), and a
  consent-gated `includes/analytics.html` (viz-base). bash-intro ships **both**
  `google-analytics.html` (legacy `UA-57270671-37`) and `_ga_partial.html` (GA4).
  Only intro-r and viz-base consent-gate.
- **`AGENTS.md` exists in all six, but four are byte-identical** 300-byte
  boilerplate. Only intro-r's 2.2 KB version carries book-specific state.
- **`viz-ggplot2` declares `output-dir: _book` while CI assembles `docs/`.**
  Verified: `_book/` is git-ignored with 0 tracked files; `docs/` holds 361
  tracked files. A local `quarto render` therefore lands in `_book/` while CI
  publishes `docs/`. Not a broken deploy — a local-vs-CI divergence and a
  redundant ignore rule.

### 1.5 Other defects worth recording

Fixed in wave 1 are marked **[fixed 2026-10-05]**; see §4.1.

- ~~**viz-ggplot2 `quicktour` points at `solutions/scatter.md`**~~ **[fixed]**
- ~~`bash-intro/index.qmd:33-60` lists *sudo* before *Data Transfer*~~ **[fixed]**
  (both `_quarto.yml` and `README.md` put Data Transfer 6th and sudo 7th)
- ~~READMEs in bash-intro and viz-ggplot2 label chapters `A`/`B` that render as
  numbered chapters~~ bash-intro **[fixed]**; viz-ggplot2 still does — wave 8
- ~~`bash-intro/git-appendix.qmd` is named and titled as an appendix but sits in
  `book.chapters`; the book has no `appendices:` key`~~ **[fixed]** — it now has a
  real H1 and renders as chapter 14, honestly labelled. Moving it to
  `appendices/` is wave 7
- ~~`viz-ggplot2` ships a 16-file `code/` folder that no chapter links to~~ still
  true — wave 7
- `viz-base/sitemap.xml` lists `intro.html` before `why-base.html`; `_quarto.yml`
  has the reverse order. Wave 3.
- `rdbsql/sitemap.xml` is absent from `project.resources`, so it never reaches
  `docs/`, and omits both appendix pages. Wave 3.
- ~~"Putting it all together" ships in 5 spellings across 3 heading levels in 17
  places~~ **[fixed]** — one spelling at 16 sites; the deliberate `###` nesting
  is retained. ~~"Your Turn" in 4 variants~~ **[fixed]**.
- `intro-r/_extensions/` contains both `coatless/webr/` and a duplicate `webr/`.
  Wave 9.
- `viz-ggplot2/.gitignore` lists `.quarto/` twice. Wave 9.
- ~~Stray tracked files: `bash-intro/analysis.R`, `release.txt`,
  `imports_*.txt`, and `img/J?`~~ **[fixed]** — see §4.1.
- data-wrangling keeps ~39 MB of tracked fixtures (`analytics_raw.csv` alone is
  34.8 MB) at the repo root rather than in `data/`. Wave 9.

---

## 2. Template

### 2.1 Repository layout

```
<book>/
  _quarto.yml              # single source of truth for chapter order
  index.qmd                # Preface — unnumbered; Software information, cite, corrections
  about-the-author.qmd     # unnumbered, position 2
  <chapter-slug>.qmd       # bare topical slug, no numeric prefix
  conclusion.qmd
  cheatsheet.qmd
  references.qmd
  appendices/
    <appendix-slug>.qmd
  solutions/
    <chapter-slug>.md      # 1:1 with the chapter slug — no renames
  code/
    ch<NN>-<slug>.R        # numbered, linked from its chapter
  data/                    # vendored, offline-buildable
  scripts/
    make-sitemap.sh
    test-redirects.sh
    verify-slugs.sh
    webr-smoke.R           # only if the book uses WebR
    verify.R
  includes/
  img/                     # cover png + og-card.png
  netlify.toml
  _redirects
  404.html
  robots.txt
  sitemap.xml
  LICENSE
  AGENTS.md
  README.md
  renv.lock  .Rprofile  <book>.Rproj  .gitignore  .devcontainer/
```

### 2.2 `_quarto.yml`

```yaml
project:
  type: book
  output-dir: docs
  pre-render: "Rscript scripts/reset-fixture.R"   # only if the book has mutable fixtures
  resources:
    - "robots.txt"
    - "sitemap.xml"
    - "netlify.toml"
    - "_redirects"
    - "404.html"

quarto-required: "==1.6.40"     # pinned exactly, never "release"

book:
  title: "<Title>"
  subtitle: "<Subtitle>"
  author: "Aravind Hebbali"
  date: last-modified
  description: "<One sentence, <=160 chars, identical to website.description>"
  chapters:
    - index.qmd
    - about-the-author.qmd
    - <chapter-slug>.qmd
    - cheatsheet.qmd
    - conclusion.qmd
    - references.qmd
  appendices:
    - appendices/<appendix-slug>.qmd
  downloads: [pdf, epub]       # required; omitting this ships nothing and says nothing

website:
  site-url: https://<slug>.rsquaredacademy.com
  description: "<same string as book.description>"
  open-graph: true
  twitter-card: true
  repo-url: https://github.com/rsquaredacademy-education/<slug>
  navbar:
    right:
      - text: "GitHub"
        href: https://github.com/rsquaredacademy-education/<slug>

execute:
  freeze: auto
  warning: false

format:
  html:
    filters: [webr]            # omit entirely if the book has no WebR cells
    theme:
      light: flatly
      dark: darkly
    toc: true
    toc-depth: 3
    search: true
    code-copy: true
    code-overflow: wrap
    fig-align: center
    fig-dpi: 192
    include-in-header: [_ga_partial.html, meta-og.html]
  pdf:
    pdf-engine: typst          # house standard
    keep-typ: false
    papersize: us-letter
    toc: true
    number-sections: true
    toc-depth: 3
    code-overflow: wrap
    mainfont: "Linux Libertine"   # NOT "Libertinus Serif" — must exist on the runner
    monofont: "DejaVu Sans Mono"
    fig-format: png
    fig-dpi: 300
  epub:
    toc-depth: 2
    epub-chapter-level: 1
    code-overflow: wrap
```

### 2.3 Chapter file

````markdown
---
description: "<one sentence, unique across the book>"
---

# Chapter Title {#chapter-slug}

## Introduction

In this chapter, you will learn how to ...

## First argument

> **Note**
> Signposts use a blockquote, not `:::{.callout-tip}`. Callouts break the Typst
> PDF — see viz-base/AUTHORING.md:64-66.

## Exercises

1. ...
2. ...
3. ...

Worked solutions in
[`solutions/chapter-slug.md`](https://github.com/rsquaredacademy-education/<repo>/blob/master/solutions/chapter-slug.md)
(attempt first).
````

**Hard rules.** Each traces to a real defect found in the audit.

- **No `title:` in chapter front matter.** It renders a second `<h1>` and shifts
  every chapter number by one. Documented at `viz-base/AUTHORING.md:25-33`;
  bash-intro violates this in 8 files, and `index.qmd` twice over.
- **`description:` only** in front matter. `title` breaks numbering; its absence
  costs the page its meta description.
- **Exactly one `#` H1**, on the first line after front matter. bash-intro's
  `cheatsheet.qmd` and `git-appendix.qmd` have none; its `index.qmd` has two.
- **Heading strings are exact.** One spelling per section name. No `...` or `..`
  variants, and no mixed levels for the same section.
- **`{.unnumbered}`, never `{-}`**, for front and back matter. Unnumbered
  sections always carry `{.unnumbered}`.
- **`solutions/<slug>.md` matches the chapter slug exactly.** No
  `bar-plot` → `bar.md` shortenings.
- **Signposts are blockquotes, not callout divs**, on the Typst pipeline.

### 2.4 Required back matter

Every book ships these, in this order:

| Slot | File | Numbering |
|:--|:--|:--|
| Preface | `index.qmd` | unnumbered |
| About the Author | `about-the-author.qmd` | unnumbered |
| Chapters | `<slug>.qmd` | 1 … N |
| Cheat Sheet | `cheatsheet.qmd` | unnumbered |
| Conclusion | `conclusion.qmd` | numbered |
| References | `references.qmd` | unnumbered |
| Appendices | `appendices/*.qmd` | A, B, … |

The Preface carries `## Software information`, `## How to cite this book` (with
the BibTeX block), and `## Corrections`. Every content chapter ends with
`## Exercises`, three items, and the solutions pointer.

### 2.5 CI workflow

One file per book.

```yaml
name: Build & Deploy to Netlify

on:
  push:
    branches: [master]
    # `date: last-modified` re-stamps every page, so the bot's own docs/
    # commit would otherwise retrigger this workflow forever.
    paths-ignore: ['docs/**']
  pull_request:
  workflow_dispatch:

permissions:
  contents: write

jobs:
  build-deploy:
    runs-on: ubuntu-24.04
    steps:
      - uses: actions/checkout@v4

      - uses: quarto-dev/quarto-actions/setup@v2
        with:
          version: "1.6.40"        # exact pin

      # Bump Quarto and Typst together, never one alone. viz-base pins 0.11.0
      # because newer Typst fails inside Quarto's own template.
      - uses: typst-community/setup-typst@v4
        with:
          version: "0.11.0"        # exact pin

      - uses: r-lib/actions/setup-r@v2
        with:
          r-version: "4.5"
          use-public-rspm: true

      # Typst ships no fonts and the bare runner has none; without this the PDF
      # dies with "font fallback list must not be empty".
      - name: Install fonts
        run: |
          sudo apt-get update
          sudo apt-get install -y fonts-linuxlibertine fonts-dejavu-core zip unzip
          fc-cache -f

      - uses: r-lib/actions/setup-renv@v2

      - run: Rscript scripts/webr-smoke.R        # only if the book uses WebR

      - run: quarto render --to html --output-dir /tmp/stage-html

      # Fatal, not advisory: `downloads: [pdf, epub]` is advertised on the
      # landing page. A silent non-fatal render once shipped a green build
      # with no PDF at all.
      - run: quarto render --to pdf  --output-dir /tmp/stage-pdf
      - run: quarto render --to epub --output-dir /tmp/stage-epub

      - name: Assemble docs
        run: |
          rm -rf docs && mkdir -p docs
          cp -r /tmp/stage-html/. docs/
          cp /tmp/stage-pdf/*.pdf /tmp/stage-epub/*.epub docs/
          cp netlify.toml _redirects 404.html robots.txt sitemap.xml docs/
          bash scripts/make-sitemap.sh docs https://<slug>.rsquaredacademy.com
          rm -rf docs/docs
          test -f docs/sitemap.xml || { echo "sitemap.xml missing"; exit 1; }

      - run: bash scripts/verify-slugs.sh
      - run: bash scripts/test-redirects.sh docs
      - run: |
          if grep -r '??</strong>' docs/*.html; then
            echo 'FAIL: unresolved cross-references'; exit 1
          fi

      # Advisory only. Never a gate.
      - uses: lycheeverse/lychee-action@v2
        continue-on-error: true
        with:
          args: "docs/**/*.html --root-dir docs --exclude 'mailto:*'"

      - if: github.event_name != 'pull_request'
        uses: stefanzweifel/git-auto-commit-action@v5
        with:
          commit_message: "docs: rebuild site via ci"
          file_pattern: docs/

      - uses: nwtgck/actions-netlify@v3
        with:
          publish-dir: ./docs
          production-branch: master
          github-token: ${{ secrets.GITHUB_TOKEN }}
          deploy-message: ${{ github.event.head_commit.message }}
        env:
          NETLIFY_SITE_ID: ${{ secrets.NETLIFY_SITE_ID }}
          NETLIFY_AUTH_TOKEN: ${{ secrets.NETLIFY_AUTH_TOKEN }}
```

**Gates that block, in every book:** PDF and ePub exist · every `_quarto.yml` slug
rendered · no `??` cross-references · redirect targets resolve · sitemap covers
every page. Only the link check is advisory.

### 2.6 README

Twelve sections, same order in all six: Title and cover · one-line pitch · live
URL · badges (Posit Cloud, Codespaces) · **Syllabus** · Zero-setup environments ·
How this book differs · Data and evidence · Develop · Cite this book · License ·
Contact.

**The syllabus table is generated from `_quarto.yml`, never hand-maintained.**
Hand-maintenance is the source of the current drift: three books label chapters
`A`/`B` that render as numbered chapters, and bash-intro's in-book outline
disagrees with `_quarto.yml` on chapter order. Appendices are labelled `A`/`B`
only when they are actually under `book.appendices`.

---

## 3. Checklist

### 3.1 Structure

- [ ] `_quarto.yml` declares `chapters`, `appendices`, and `downloads: [pdf, epub]`
- [ ] Preface is `index.qmd`, `.unnumbered`, with Software information, How to cite, Corrections
- [ ] `about-the-author.qmd` exists at position 2, `.unnumbered`
- [ ] `conclusion.qmd` and `references.qmd` exist
- [ ] Cheat sheet is real content, not a stub, and not a numbered chapter
- [ ] Appendices live in `appendices/` and are declared under `book.appendices`
- [ ] Exactly one `#` H1 per chapter, on the first line after front matter
- [ ] Every chapter has `description:`; no chapter has `title:`
- [ ] `{.unnumbered}` used throughout, never `{-}`
- [ ] One exact spelling and level per section heading name
- [ ] Every content chapter ends `## Exercises` with 3 items plus a solutions pointer
- [ ] `solutions/<chapter-slug>.md` matches the slug exactly; every pointer resolves
- [ ] Chapter code is linked from its chapter; `scripts/verify.R` runs all of it

### 3.2 Build

- [ ] `output-dir: docs`; no `_book/`
- [ ] Quarto and Typst pinned exactly; bumped as a pair
- [ ] `fc-cache -f` runs after font install
- [ ] `mainfont` is a font the CI runner actually has
- [ ] PDF and ePub renders are fatal, not `|| echo FAILED`
- [ ] Zero callout divs, or the book is explicitly documented as lualatex

### 3.3 CI

- [ ] One workflow file; triggers on push to `master`, pull_request, and dispatch
- [ ] `paths-ignore: ['docs/**']` present
- [ ] Deploys to Netlify via `actions-netlify@v3`, `production-branch: master`
- [ ] `permissions: contents: write` where `docs/` is committed
- [ ] Gate: every `_quarto.yml` slug rendered
- [ ] Gate: redirect targets resolve
- [ ] Gate: sitemap covers every page
- [ ] Gate: no `??` in output
- [ ] Link check is advisory

### 3.4 Repo hygiene

- [ ] `LICENSE` at root — CC BY-NC-SA 4.0
- [ ] `.gitignore` carries the canonical list (see below)
- [ ] `.Rprofile` and `renv.lock` present and current
- [ ] `scripts/make-sitemap.sh` and `scripts/test-redirects.sh` both present
- [ ] `netlify.toml` and `_redirects` consistent with each other
- [ ] `AGENTS.md` carries book-specific state, not shared boilerplate
- [ ] No stray artifacts at repo root
- [ ] `img/og-card.png` and the cover PNG present

Canonical `.gitignore`:

```gitignore
.Rproj.user
.Rhistory
.RData
.Ruserdata
roadmap/
daily-logs.md

*_files/
_bookdown_files/
/.stage/

/.quarto/
/_book/
**/*.quarto_ipynb
```

Add `docs/` only for books that do not commit built output (currently
bash-intro, the only one).

### 3.5 New-book gate

A book is publishable when all of the following hold:

- [ ] `quarto render` is clean for HTML, PDF, and ePub on a bare runner
- [ ] All blocking CI gates are green
- [ ] The syllabus table is generated from `_quarto.yml`
- [ ] Every chapter has exercises and a reachable solution
- [ ] Analytics are consent-gated, or absent entirely — never unconditional
- [ ] `LICENSE` present
- [ ] The sitemap covers every published page

---

## 4. Migration status

Decided 2026-10-05. Work is sequenced in nine waves; each is independently
shippable and none blocks a later one.

| # | Wave | Scope | Status |
|:--|:--|:--|:--|
| 1 | Correctness | viz-ggplot2 `quicktour`/`scatter` mislink; `LICENSE` ×6; missing solutions (bash-intro `git-appendix`); heading-string and `{.unnumbered}` unification | **Done 2026-10-05** |
| 2 | Pin the toolchain | Quarto + Typst pinned as a pair; PDF/ePub fatal; `fc-cache -f`; `mainfont` resolvable | **Done 2026-10-05** |
| 3 | One CI file per book | Adopt the template; add the missing slug gate (bash-intro, rdbsql); extract `scripts/verify-slugs.sh` | Not started |
| 4 | Migrate to Netlify | rdbsql, viz-base — add `netlify.toml` + `_redirects`, switch the deploy step | Not started |
| 5 | Typst migration | data-wrangling (16 callouts), viz-ggplot2 (48 callouts) | Not started |
| 6 | Solutions normalisation | data-wrangling chapter → folder; viz-base inline → folder; rename all files to exact slugs | Partly done (see below) |
| 7 | Back-matter completeness | Add Conclusions and References where missing; build real cheat sheets; move `git-appendix.qmd` into `appendices/` | Not started |
| 8 | README convergence | Adopt the 12-section template; generate syllabus tables from `_quarto.yml` | Partly done (see below) |
| 9 | Repo hygiene | Canonical `.gitignore`; `renv.lock` for the three without; root junk removal; per-book `AGENTS.md` | Partly done (see below) |

Waves 1–3 are risk reduction with no content decisions. Wave 5 is 64 mechanical
callout edits plus a PDF read per chapter. Waves 7–9 are the cosmetic tail.

### 4.0 Wave 2 record — shipped 2026-10-05

Toolchain pinned across all six; viz-base needed no changes and is the
reference implementation.

| Book | Quarto | Typst | PDF/ePub fatal | Notes |
|:--|:--|:--|:--|:--|
| bash-intro | `1.6.40` | `0.11.0` | yes | Typst was floating on latest |
| data-wrangling | `1.10.18` | lualatex | yes | was `version: "release"` |
| intro-r | `1.6.40` | `0.11.0` | yes | Typst was floating on latest |
| rdbsql | `1.10.18` | `0.13.1` | yes | **PDF was broken in production** |
| viz-base | `1.6.40` | `0.11.0` | yes | already correct — no changes |
| viz-ggplot2 | `1.10.18` | lualatex | yes | was `version: "release"` |

**Two Quarto baselines, deliberately.** rdbsql cannot move to the 1.6.40 the
others use: its `_quarto.yml` requires `>=1.10.0`, and forcing it lower fails
with `cannot reference heading without numbering`. It also needs Typst
**0.13.1**, not 0.11.0, because Quarto 1.10's Typst template emits
`place(..., scope: "parent")`, which 0.11 rejects outright. All four Typst
books are documented individually; do not standardise them to one pair
without re-testing each.

**What the swallow was hiding.** `rdbsql`'s PDF had never built. The step
was `... || echo "PDF_FAILED=1"`, which always exits 0, so the build stayed
green and the assemble step logged "No PDF staged". Three books did this.
Demonstrated the semantics rather than assuming them:

```
$ sh -c 'exit 42' || echo swallowed   ->  exit 0    (green, no PDF)
$ sh -c 'exit 42'                      ->  exit 42   (red)
```

**`mainfont` was unresolvable everywhere it was requested.** Four books asked
for `Libertinus Serif`; CI installs only `fonts-linuxlibertine`, which ships
`LinLibertine_*.otf` / `LinBiolinum_*.otf` — the **Linux Libertine** and
**Linux Biolinum** families. No Ubuntu suite (noble/plucky/questing) has a
Libertinus package at all. The PDFs had been rendering through Typst's silent
fallback. All four now request `Linux Libertine`, which the runner provides.
Confirmed harmless: PDFs are byte-for-byte the same size before and after.

**Download links must match emitted filenames.** `book.downloads` bakes the
whole-book output filename into the landing page link *at render time*, so
renaming afterwards always breaks it. rdbsql hit this twice; the correct fix
is `book.output-file`, set in `_quarto.yml`, not a post-render `mv`.

**Lesson worth keeping:** two of the fixes here were wrong on first attempt
(a package name that does not exist, a rename that could not work) and were
caught only because the toolchain was exercised locally before pushing. CI
had been green throughout.

### 4.1 Wave 1 record — shipped 2026-10-05

All changes render-verified with Quarto 1.6.40 (the version CI pins).

| Fix | Detail |
|:--|:--|
| viz-ggplot2 wrong answer key | `ggplot2-quicktour.qmd` pointed at `solutions/scatter.md`; `solutions/quicktour.md` was complete and orphaned. Corrected and verified in rendered HTML |
| Solutions coverage | bash-intro gained `solutions/git-appendix.md` (answers checked against a real `git init` repo, not written from memory) |
| Solutions reachability | bash-intro had 12 solution files and **zero** chapter pointers. All 13 exercise chapters now link one, matching the byte-identical template rdbsql and viz-ggplot2 already used. 32 pointers total across the three books: 0 broken, 0 orphaned |
| `LICENSE` | Verbatim CC BY-NC-SA 4.0 legalcode (438 lines, fetched from creativecommons.org — license text is never reconstructed from memory) added to all six books |
| **bash-intro chapter numbering** | The serious one. 9 files carried a chapter-level `title:` in front matter *in addition to* an `#` H1. On the live site the YAML `title:` claimed the chapter number and the H1 was counted as a further chapter, so every page's own heading rendered one higher than its own sidebar entry (`navigating-files-and-directories.html` showed sidebar "3", body "4"). `index.qmd`'s `title:` also consumed chapter slot 1, putting the whole book one ahead of its own README. Removed the 9 `title:` lines, added the 2 missing H1s (`cheatsheet.qmd`, `git-appendix.qmd` had none), merged `index.qmd`'s duplicate H1. **Verified: sidebar, body heading and in-page TOC now agree, and chapters 1–12 match the README** |
| `{.unnumbered}` | 9 headings converted from `{-}` (bash-intro, viz-base). viz-base's Preface mixed both spellings |
| Heading strings | "Putting it all together" 16 sites and "Your Turn" 7 sites reduced to one exact spelling each. Heading *levels* left alone — `###` variants are deliberate nesting, not drift |
| bash-intro latent path bug | `r-command-line.qmd` and `conclusion.qmd` read `cline/` fixtures but omitted `knitr: root.dir: "cline"`, so those paths resolved from the repo root. Harmless today (all affected chunks are `eval=FALSE`), a trap for the first person who enables one. Fixed |
| Stray artifacts | `img/J?` was a byte-identical copy of `cline_cover_image.png` whose filename contained U+F02A, a private-use character — an illegal Windows filename from a bad copy-paste. Deleted. Five root-level files (`analysis.R`, `release.txt`, `imports_*.txt`, `zip_example.zip`) are duplicates of fixtures that live in `seed/cline-seed.tar.gz` and are read from `cline/`; untracked but left on disk so no exercise breaks. Dead `_bookdown.yml`/`_output.yml` ignored, history preserved |

**Deliberately deferred.** Trailing whitespace in 53 headings (cosmetic, not
worth the diff noise). The viz-ggplot2 "Why this chart" vs "Why this matters"
split (13 vs 9) is an authoring decision, not a mechanical fix — wave 7.

**Still open from wave 1's scope:** bash-intro has no About the Author and no
References chapter, and `style.css` is orphaned there (`_quarto.yml` has no
`css:` key, unlike rdbsql). All wave 7 / wave 9.

**Wave 5 cost, stated plainly.** Callouts are unavailable on Typst —
`viz-base/AUTHORING.md:64-66` documents `:::{.callout-tip}` failing with
`error: unknown variable: callout`, because Quarto's book-merge path drops
Typst's `definitions.typ`. Migrating data-wrangling and viz-ggplot2 means
converting 16 and 48 callout sites respectively into blockquote signposts, then
verifying each affected chapter's PDF.

---

## 5. Per-book deviation log

State after wave 1. Resolved items struck through.

| Book | Blocking gaps | Notable |
|:--|:--|:--|
| **bash-intro** | No About the Author; no References chapter; no `appendices:` key; no slug gate; `style.css` orphaned (no `css:` key in `_quarto.yml`) | ~~Chapter numbering off by one~~ fixed and verified; ~~no chapter linked to `solutions/`~~ all 13 now do; ships two analytics files with different IDs; still has both, wave 9 |
| **data-wrangling** | Unpinned Quarto; lualatex; solutions as a book chapter; 39 MB of root fixtures; no `make-sitemap.sh` | Most internally consistent chapter structure of the six; only book with `00-`…`14-` numbering |
| **intro-r** | No `renv.lock` gate in CI (uses an explicit package list) | Only book with a `DESCRIPTION` and `.Rbuildignore`; best `AGENTS.md` in the workspace; deploy target ambiguous between Pages and Netlify |
| **rdbsql** | No `renv.lock`; no `netlify.toml`; no slug gate; `sitemap.xml` not in resources and omits appendices | `code/ch1`–`ch7` numbered correctly and linked from every chapter — the pattern others should copy |
| **viz-base** | No `netlify.toml`, `_redirects`, `scripts/test-redirects.sh`, `style.css`; Exercises in only 1/12 chapters; `citation.bib` and `HOW-TO-CITE.md` never reach `docs/` | The most complete book: References, How to cite, DOI, `AUTHORING.md`, consent-gated analytics. Adopt its `AUTHORING.md` pattern everywhere |
| **viz-ggplot2** | `output-dir: _book` vs CI `docs/`; 16 orphaned `code/` files; stub cheat sheet shipped live; unpinned Quarto | ~~Solutions mislink~~ fixed and verified; duplicate `_extensions/webr`; `.quarto/` listed twice in `.gitignore` |

**House state.** All six books now carry a `LICENSE`. All solutions pointers
resolve. Heading strings and the unnumbered attribute are consistent. No book
has a chapter-level `title:` except intro-r's `index.qmd`, which is correct —
that is the book landing page, where `title`/`author`/`date` belong.