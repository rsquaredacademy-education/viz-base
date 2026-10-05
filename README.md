# Data Visualization with R

![Cover](img/viz-base.png)

*Base R graphics are the Matplotlib of R: verbose, dependency-free, pixel-precise — the right choice for package authors, locked-down production, and high-throughput batch reports. This book teaches that layer from first plot to publication-ready output.*

📖 **Read the book:** https://viz-base.rsquaredacademy.com

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

## Authoring documentation

This repository is the **canonical home** for the workspace-wide book standard:

- **[`AUTHOR-STANDARDS.md`](AUTHOR-STANDARDS.md)** — the conformance standard
  and template for all six books in the Rsquared ebooks workspace, plus the
  migration plan. Read this first.
- [`AUTHORING.md`](AUTHORING.md) — the constraints specific to *this* book,
  including the four failure modes that break silently.
- [`revision.md`](revision.md), [`revision-w2.md`](revision-w2.md) — what
  changed here in each review wave, and what is still open.

Every book in the workspace points at `AUTHOR-STANDARDS.md` here, so this
repository is versioned alongside the standard rather than duplicated into
six repos.

## Develop

```bash
quarto preview                     # live HTML preview
quarto render                      # full book (HTML + Typst PDF + ePub into docs/)
Rscript scripts/webr-smoke.R       # static check of every live {webr-r} cell
typst compile cheatsheet/base-par-cheatsheet.typ docs/base-par-cheatsheet.pdf
```

CI renders HTML, Typst PDF, and ePub, builds the cheatsheet, verifies every slug, and deploys `docs/` via GitHub Pages. `master` is the production branch. Editing the book has its own set of traps — read [AUTHORING.md](AUTHORING.md) before changing anything.


## Cite this book

```bibtex
@misc{vizbase2026,
  author    = {Aravind Hebbali},
  title     = {Data Visualization with R: Base Graphics},
  year      = {2026},
  version   = {1.0},
  publisher = {Rsquared Academy},
  doi       = {10.5281/zenodo.23138733},
  url       = {https://viz-base.rsquaredacademy.com},
  note      = {Version 1.0. Source: https://github.com/rsquaredacademy-education/viz-base}
}
```

DOI: [10.5281/zenodo.23138733](https://doi.org/10.5281/zenodo.23138733) — the Zenodo version DOI for v1.0.0, so the citation stays pinned to the edition you read. For a citation that tracks the current edition instead, the concept DOI `10.5281/zenodo.23138732` always resolves to the latest release.

The entry is also in [`citation.bib`](citation.bib), and the Preface carries the same block. See [HOW-TO-CITE.md](HOW-TO-CITE.md) for how the DOI is minted and what to do at the next release.

## License

Content CC BY-NC-SA 4.0.

## Privacy

The book collects nothing and has no accounts, comments or newsletter. Optional
Google Analytics is **off until the reader accepts it** — the Google tag is only
ever created inside the accept branch, so nothing reaches Google before then, and
the choice is reversible from an "Analytics preferences" button on every page.
WebR playgrounds run entirely in the browser. See [privacy.html](privacy.html).

Analytics is hand-rolled in `includes/analytics.html` rather than configured via
`website.google-analytics`, which Quarto silently ignores for `type: book`, and
which loads Google unconditionally when it does work.