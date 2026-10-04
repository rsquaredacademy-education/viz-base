# Authoring constraints

Developer documentation for editing this book. Not needed to read it.

Verified against **Quarto 1.6.40 + Typst 0.11.0**. All three formats build in CI
and the PDF/ePub steps are *required*, so everything below breaks the build rather
than degrading quietly. Where a failure is silent, that is called out — those are
the expensive ones.

## Layout

The chapter list lives in `_quarto.yml: book: chapters:` and is ordered
explicitly. Do not rely on filename prefixes. `book: appendices:` holds the
Rosetta Stone. **`docs/` is wiped and rebuilt by CI on every run**
(`rm -rf docs`), so never hand-maintain a file there — anything that must persist
lives at the repository root and is copied in by the workflow. That already
happened once: `HOW-TO-CITE.md` was drafted into `docs/` and would have been
deleted on the next build.

`sitemap.xml` is hand-maintained for the same reason — Quarto book sitemap
generation is unreliable here. It must stay in sync with `_quarto.yml`.

## The four that fail silently

**1. A YAML `title:` on a chapter creates a second `<h1>` and consumes a chapter
number.** `index.qmd` shipped with both `title:` and `# Preface {.unnumbered}`,
so the YAML title rendered as a numbered chapter and every page was numbered one
too high — the live site read "2 Introduction" through "11 Faceting".
`numbering: false` does **not** fix this; it applies only to the markdown H1.
Drop `title`/`subtitle`/`author` from a chapter's front matter — they belong in
`_quarto.yml: book:`. `description:` is safe: it produces no title block, one
`<h1>`, and no numbering shift. Verified on one chapter before applying it to
fifteen.

**2. Duplicated chunk labels warn once per figure and print no detail.** A chunk
with both a name in its header and a `#| label:` — `` ```{r par-mar} `` plus
`#| label: fig-par-mar` — makes knitr emit `Duplicated chunk option(s) 'label'`.
Quarto prints only `There were 16 warnings (use warnings() to see them)`. To see
them, run `knitr::knit()` yourself and inspect `warnings()`. The fix is to drop
the header name from any chunk that carries `#| label:`; the label still drives
the figure filename, so ids and cross-refs are unaffected.

**3. A `@sec-` heading reference fails the PDF.** Any heading reference, same
chapter or across chapters, resolves in HTML and ePub but dies in the PDF with
`error: cannot reference heading without numbering`. `@fig-` and `@tbl-` are fine
in all three. Chapter pointers in prose are therefore written as literal numbers
("Chapter 2") and have to be corrected by hand whenever the chapter list changes.

**4. Deleting a placeholder meta tag makes Quarto emit nothing.** `includes/head.html`
holds `description`, `og:title`, `og:description` and the `twitter:*` values as
*placeholders* that Quarto rewrites per page. Delete the `description` placeholder
and no `<meta name="description">` is emitted anywhere — which is exactly the bug
that had it missing from all 15 pages. Same mechanism for the og/twitter tags.

**5. Figure cross-references need a cell label, not a chunk name.** `@fig-x`
resolves only when the chunk carries *both* `#| label: fig-x` and
`#| fig-cap: "..."` as Quarto cell options. A bare `fig.cap=` in the chunk header
produces the caption but leaves `@fig-x` unresolved, with only a warning. Put
`fig-alt` in the same place as `fig-cap` — `fig-alt=` in the chunk header is
silently ignored.

## The rest

- **Callouts are unavailable.** `:::{.callout-tip}` fails the PDF with
  `error: unknown variable: callout` — Quarto's book-merge path drops Typst's
  `definitions.typ`. Use a blockquote signpost instead (house style, see
  `legend.qmd`).
- **`<details>` works** in HTML, ePub and PDF, including nested executable R
  chunks, so collapsed exercise solutions are safe to use.
- **The `webr` filter must stay scoped to `format.html`.** It rewrites the AST and
  breaks the Typst template's `#callout` definition.
- **Never hardcode canonical or `og:url`.** Quarto emits neither for
  `type: book`, and hard-coding them made every page claim the site root as its
  canonical URL. The comment in `includes/head.html` explains why their absence is
  deliberate.
- **Clear `.quarto/` when a cross-reference misbehaves.** A stale cache emits
  same-page anchors and unresolved text instead of erroring.
- **`format(1e5, big.mark = ',')` returns `"1e+05"`.** Add `scientific = FALSE`, or
  large point counts render as exponents in figure titles.
- **`par()` state must be restored.** Use the book's idiom,
  `init <- par(no.readonly = TRUE)` … `par(init)`, or `op <- par(x)` … `par(op)`.
  In a function, wrap the restore in `on.exit()`. Do not write
  `op <- par('mar')` — `par()` with a character returns a *list*, which reads as
  a restore but is not one.
- **New figures get looked at.** Clipped axis labels, titles that overflow the
  panel once the left margin grows, and `mtext` captions colliding with `xlab` are
  all easy to ship and invisible in the render log.
- **`par(mfrow = )` before the first `plot()`**, or each `plot()` emits its own
  figure rather than filling a panel. This is why five `par-*` comparisons in
  Chapter 12 were restructured as `mfrow` panels.

## The cheatsheet is not a Quarto chapter

`cheatsheet/base-par-cheatsheet.typ` is standalone Typst, built separately, and CI
asserts via `pdfinfo` that it is still **exactly one page**. Its R snippets live in
```` ```r ```` raw blocks, because `#` starts a comment in R but escapes into code
mode in Typst markup — a bare `# comment` in a `.typ` file is a parse error. Same
reason `<-` and `$` must be written as raw inline code, since `<` opens a Typst
label and `$` opens maths.

CI needs `poppler-utils` for the `pdfinfo` check; it is installed in the fonts
step. `typst` is not on `PATH` in a local Quarto install — add
`%LOCALAPPDATA%\Quarto\bin\tools\x86_64`.

## Analytics is hand-rolled on purpose

Do not "simplify" `includes/analytics.html` back into `_quarto.yml`.
`website.google-analytics` is **silently ignored for `type: book`** — no error, no
warning — and `website.cookie-consent` does not exist in Quarto 1.6.40. CI asserts
the negative: a static `<script src="...googletagmanager.com...">` in any output
page fails the build, because that is precisely the regression that would
reintroduce unconditional tracking while the banner still looks correct.

## What does not run at knit time

`scripts/bench.R` and `scripts/startup.R` require `bench` and `ggplot2`. They are
run by hand and their CSVs are committed. Nothing in the book may `library()`
anything outside base R, including in a chapter that only *discusses* ggplot2 —
Appendix A's ggplot2 code is `eval=FALSE` for exactly this reason.

`scripts/webr-smoke.R` guards the `{webr-r}` cells: they must parse, must not call
`library()`, must not read `data/` (the browser filesystem starts empty), and must
not reference anything but R's built-in datasets.