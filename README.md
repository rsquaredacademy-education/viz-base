# Data Visualization with R

![Cover](img/viz-base.png)

*Base R graphics are the Matplotlib of R: verbose, dependency-free, pixel-precise — the right choice for package authors, locked-down production, and high-throughput batch reports. This book teaches that layer from first plot to publication-ready output.*

📖 **Read the book:** https://viz-base.rsquaredacademy.com

## Cite this book

```bibtex
@misc{vizbase2026,
  author    = {Aravind Hebbali},
  title     = {Data Visualization with R: Base Graphics},
  year      = {2026},
  publisher = {Rsquared Academy},
  url       = {https://viz-base.rsquaredacademy.com},
  note      = {Version 1.0. Source: https://github.com/rsquaredacademy-education/viz-base}
}
```

The entry is also in [`citation.bib`](citation.bib), and the Preface carries the same block. A `doi` field will be added once a Zenodo record exists for a versioned release — see [HOW-TO-CITE.md](HOW-TO-CITE.md). There is deliberately no placeholder DOI in the meantime: one that looks authoritative but does not resolve is worse than none.

Free to read, built with [Quarto](https://quarto.org/). No packages to install — the book uses only the `graphics` package that ships with R, and Chapters 2–4 each close with a live playground that runs in your browser via [WebR](https://docs.r-wasm.org/webr/latest/).

## Syllabus

| # | Chapter | You will learn |
|:--|:--------|:---------------|
| 1 | Why Base R Graphics | Measured case for base graphics in 2026: draw speed, session startup, CRAN dependency counts, container sizes, and a decision tree for when to switch to ggplot2 |
| 2 | Introduction | The R graphics system (`graphics`/`ggplot2`/`lattice`), `?plot`, `mtcars`, and the six `plot()` dispatch cases |
| 3 | Titles and Labels | `main`, `sub`, `xlab`, `ylab`, `xlim`, `ylim`, and `title()` |
| 4 | Scatter Plots | `pch` shapes, `cex` size, `col`/`bg` color, and mapping a third variable to shape or color |
| 5 | Line Graphs | `type`, `lty`, `lwd`, enhancing points, layering with `lines()`, plus `segments()` error bars, `arrows()` callouts and `polygon()` confidence bands |
| 6 | Bar Plots | `table()`, width and spacing, labels, color, axes, and stacked vs. `beside` bivariate bars |
| 7 | Box Plots | Five-number summary, grouped boxplots, and `notch` for comparing medians |
| 8 | Histograms | `breaks`, interval choice, frequency tables, color, borders, and labels |
| 9 | Legends | Location, line/point/text styling, title, box appearance, justification, and text |
| 10 | Text Annotations | `text()`, `mtext()`, `pos`, `offset`, `padj`, `outer`, and `at` |
| 11 | Combining Plots | `par(mfrow)`/`par(mfcol)`, edge cases, and `layout()` with custom widths and heights |
| 12 | Production Export & Devices | `png()`/`pdf()`/`svg()`, `dev.off()`, batch report loops, the `par()` master set, custom `axis()`, and colourblind-safe palettes |
| A | Appendix: Base ↔ ggplot2 | A Rosetta Stone mapping every base construct to its ggplot2 equivalent, with guidance on when to stop translating |

Each chapter varies one argument at a time from a bare `plot()` call, then combines everything in a "Putting it all together" section. Chapter 12 closes with three exercises and collapsed solutions, and the whole book's `par()` and device reference is distilled into a [one-page cheatsheet](docs/base-par-cheatsheet.pdf). Downloadable as PDF and ePub from the book's landing page.

## Data and evidence

Small teaching datasets are vendored in [`data/`](data/) so the book builds offline:

- `hsb2.csv` — High School and Beyond survey, 200 observations (originally UCLA Institute for Digital Research and Education)
- `brics-gdp-2010-14.csv` — frozen GDP vintage for the legend chapter, illustrative rather than citable

Chapter 1's claims are measured rather than asserted, and every number is regenerable:

- `bench-base-vs-ggplot2.csv` — draw time and peak memory, 10k/100k points, base vs. ggplot2 (`scripts/bench.R`)
- `startup-latency.csv` — wall clock to start a plotting session, by engine (`scripts/startup.R`)
- `cran-deps.csv` — declared non-base CRAN dependencies per package (`scripts/cran-deps.R`)
- `docker-sizes.csv` — published container image sizes for R vs. R + tidyverse (`scripts/docker-sizes.R`)

None of these run at knit time — the book never requires `ggplot2` or `bench` to build. Each script prints its own caveats and stamps the date and versions it ran under.

## Develop

```bash
quarto preview                     # live HTML preview
quarto render                      # full book (HTML + Typst PDF + ePub into docs/)
Rscript scripts/webr-smoke.R       # static check of every live {webr-r} cell
typst compile cheatsheet/base-par-cheatsheet.typ docs/base-par-cheatsheet.pdf
```

CI renders HTML, Typst PDF, and ePub, builds the cheatsheet, verifies every slug, and deploys `docs/` via GitHub Pages. `master` is the production branch.

### Authoring constraints

Verified against Quarto 1.6.40 + Typst 0.11.0. All three formats build in CI and PDF/ePub are
required steps, so anything below breaks the build rather than degrading quietly.

- **Callouts are unavailable.** `:::{.callout-tip}` fails the PDF with
  `error: unknown variable: callout` — Quarto's book-merge path drops Typst's
  `definitions.typ`. Use a blockquote signpost instead (house style, see `legend.qmd`).
- **`<details>` works** in HTML, ePub and PDF, including nested executable R chunks, so
  collapsed exercise solutions are safe to use.
- **Cross-references split by type.** `@fig-`/`@tbl-` resolve in all three formats. Any
  `@sec-` heading reference — same chapter or cross-chapter — resolves in HTML and ePub but
  fails the PDF with `error: cannot reference heading without numbering`. Chapter pointers
  in prose are therefore written as literal numbers (`Chapter 2`); keep them correct by hand
  when the chapter list changes.
- **Never hardcode Open Graph or canonical tags.** `includes/head.html` holds
  `og:title`/`twitter:*` as *placeholders* that Quarto rewrites per page; delete them and
  Quarto emits nothing. Quarto emits no `canonical` or `og:url` for `type: book` — see the
  comment in that file for why they are absent on purpose.
- **Clear `.quarto/` when a cross-reference misbehaves.** A stale cache silently emits
  same-page anchors and unresolved text instead of erroring.
- **Figure cross-references need a cell label, not a chunk name.** `@fig-x` resolves only
  when the chunk carries both, as Quarto cell options:
  ` ```{r chunkname}` / `#| label: fig-x` / `#| fig-cap: "..."` `. A bare `fig.cap=` in the
  chunk header produces the caption but leaves `@fig-x` unresolved, with only a warning.
- **`format(1e5, big.mark = ',')` returns `"1e+05"`.** Add `scientific = FALSE` or large
  tick and point counts render as exponents in figure titles.
- **The cheatsheet is not a Quarto chapter.** `cheatsheet/base-par-cheatsheet.typ` is Typst,
  built separately, and CI asserts it is still exactly one page. Its R snippets live in
  ```` ```r ```` raw blocks because `#` starts a comment in R but escapes into code mode in
  Typst markup — a bare `# comment` in a `.typ` file is a parse error.


## License

Content CC BY-NC-SA 4.0.