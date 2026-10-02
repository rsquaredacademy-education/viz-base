# Data Visualization with R

![Cover](img/viz-base.png)

*Base R graphics are the Matplotlib of R: verbose, dependency-free, pixel-precise — the right choice for package authors, locked-down production, and high-throughput batch reports. This book teaches that layer from first plot to publication-ready output.*

📖 **Read the book:** https://viz-base.rsquaredacademy.com

Free to read, built with [Quarto](https://quarto.org/). No packages to install — the book uses only the `graphics` package that ships with R, and the first three chapters each close with a live playground that runs in your browser via [WebR](https://docs.r-wasm.org/webr/latest/).

## Syllabus

| # | Chapter | You will learn |
|:--|:--------|:---------------|
| 1 | Introduction | The R graphics system (`graphics`/`ggplot2`/`lattice`), `?plot`, `mtcars`, and the six `plot()` dispatch cases |
| 2 | Titles and Labels | `main`, `sub`, `xlab`, `ylab`, `xlim`, `ylim`, and `title()` |
| 3 | Scatter Plots | `pch` shapes, `cex` size, `col`/`bg` color, and mapping a third variable to shape or color |
| 4 | Line Graphs | `type`, `lty`, `lwd`, enhancing points, and layering with `lines()` |
| 5 | Bar Plots | `table()`, width and spacing, labels, color, axes, and stacked vs. `beside` bivariate bars |
| 6 | Box Plots | Five-number summary, grouped boxplots, and `notch` for comparing medians |
| 7 | Histograms | `breaks`, interval choice, frequency tables, color, borders, and labels |
| 8 | Legends | Location, line/point/text styling, title, box appearance, justification, and text |
| 9 | Text Annotations | `text()`, `mtext()`, `pos`, `offset`, `padj`, `outer`, and `at` |
| 10 | Combining Plots | `par(mfrow)`/`par(mfcol)`, edge cases, and `layout()` with custom widths and heights |

Each chapter varies one argument at a time from a bare `plot()` call, then combines everything in a "Putting it all together" section. Downloadable as PDF and ePub from the book's landing page.

## Data

Two small teaching datasets are vendored in [`data/`](data/) so the book builds offline:

- `hsb2.csv` — High School and Beyond survey, 200 observations (originally UCLA Institute for Digital Research and Education)
- `brics-gdp-2010-14.csv` — frozen GDP vintage for the legend chapter, illustrative rather than citable

## Develop

```bash
quarto preview                     # live HTML preview
quarto render                      # full book (HTML + Typst PDF + ePub into docs/)
Rscript scripts/webr-smoke.R       # static check of every live {webr-r} cell
```

CI renders HTML, Typst PDF, and ePub, verifies the legacy slugs, and deploys `docs/` via GitHub Pages. `master` is the production branch.

## License

Content CC BY-NC-SA 4.0.