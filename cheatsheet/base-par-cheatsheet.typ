// base-par-cheatsheet.typ
//
// One-page reference for base R graphics: devices and par().
//
// Built with Typst rather than as a Quarto chapter, for three reasons.
// It must stay exactly one page, and page-fitting is a fight in every other
// tool. It must not run R, so it cannot drift out of sync with a data
// dependency or fail on a machine with no R. And it should compile in about
// two seconds, which Typst does and nothing else here does.
//
// The book's own PDF is also rendered with Typst (see _quarto.yml), so this
// adds no toolchain to CI. Build it with:
//
//     typst compile cheatsheet/base-par-cheatsheet.typ docs/base-par-cheatsheet.pdf
//
// Typst is not on PATH by default in a local Quarto install; CI exposes it via
// `quarto install tool typst` and the render workflow builds this file there.
//
// Everything below is set at a small type size on purpose. A cheatsheet that
// needs scrolling has failed at the only job it has.

// R comments start with '#', which is Typst's escape into code mode. Every R
// snippet therefore has to live in a raw block, where '#' is just a character.
// That is why these are ```r blocks and not #code(...) markup.
#set page(
  width: 210mm,
  height: 297mm,
  margin: (x: 12mm, y: 11mm),
)
#set text(font: "Linux Libertine", size: 7.4pt)
#set par(leading: 0.5em, justify: false)

#let accent = rgb("#0072B2")
#let warn = rgb("#D55E00")
#let faint = rgb("#6b7280")
#let bodycol = rgb("#374151")

// Section heading: small label with a rule under it. The `above` gap is the
// single biggest lever on whether this fits on one page, so it is kept tight.
#let sect(title) = block(above: 0.5em, below: 0.32em, breakable: false)[
  #text(fill: accent, size: 8.8pt, weight: "bold")[#upper(title)]
  #v(-2pt)
  #line(length: 100%, stroke: 0.4pt + accent)
]

// Two-column definition row: the code on the left, the meaning on the right.
#let row(term, meaning) = block(breakable: false, below: 0.06em)[
  #grid(
    columns: (33mm, 1fr),
    gutter: 3mm,
    [*#text(fill: accent)[#term]*],
    [#text(size: 7pt, fill: bodycol)[#meaning]],
  )
]

// A framed raw block. `body` is raw Typst content, so callers pass a ```r block.
#let code(body) = block(
  width: 100%,
  fill: rgb("#f4f6f8"),
  stroke: 0.3pt + rgb("#d8dee4"),
  radius: 1.5pt,
  inset: (x: 2.6mm, y: 1.1mm),
  above: 0.2em, below: 0.28em,
  breakable: false,
)[
  #set text(size: 6.9pt)
  #body
]

// A warning aside.
#let note(body) = block(above: 0.15em, below: 0.3em, breakable: false)[
  #text(size: 6.9pt, fill: warn)[#body]
]

// Header row for a two-column list, matching `row`.
#let rowhead(a, b) = block(breakable: false, below: 0.1em)[
  #grid(
    columns: (33mm, 1fr),
    gutter: 3mm,
    [#text(size: 7.2pt, weight: "bold", fill: accent)[#a]],
    [#text(size: 7pt, weight: "bold", fill: accent)[#b]],
  )
]

#align(center)[
  #text(size: 13pt, weight: "bold")[Base R Graphics]
  #h(0.5em)
  #text(size: 9pt)[— devices & par() cheatsheet]
]

#v(0.35em)
#align(center)[
  #text(size: 6.8pt, fill: faint)[
    Data Visualization with R · viz-base.rsquaredacademy.com · CC BY-NC-SA 4.0
  ]
]

#v(0.5em)
#line(length: 100%, stroke: 0.4pt + accent)

#sect[Devices]

Devices are a stack. Opening one makes it active; closing it returns to the one
underneath. Every open device must be closed or output lands somewhere you did
not choose — usually `Rplots.pdf`.

#row([png(f, width, height)], [raster. `units` defaults to `"px"`; `res` is ignored unless `units` is physical])
#row([pdf(f, width, height)], [vector, for print. `width`/`height` are *inches*])
#row([svg(f, width, height)], [vector, for web. Needs a cairo build])
#row([jpeg(f, ...) / tiff(...)], [raster, lossy / lossless])
#row([dev.off()], [close the newest device; returns its name and number])
#row([dev.cur() / dev.list()], [which device is active / which are open])
#row([dev.new()], [push a copy of the current device onto the stack])
#row([capabilities("cairo")], [`TRUE` if `svg()` will work])

#code([
  ```r
  # dev.off() belongs INSIDE the loop, not after it
  for (g in groups) {
    png(file.path(out, paste0(g, ".png")), width = 1800, res = 150)
    plot(x[[g]], y[[g]])
    dev.off()
  }
  ```
])

#sect[`par()` — margins and text]

`mar` and `oma` are measured in *lines of text*, so they scale with `cex` and
`pointsize`. A margin tuned on screen is wrong in a high-`res` export unless you
raise `pointsize` too.

#row([par(mar = c(b, l, t, r))], [plot margins, in lines of text])
#row([par(oma = c(b, l, t, r))], [outer margins, only for multi-panel figures])
#row([par(mgp = c(3, 1, 0))], [margin lines, tick labels, axis title])
#row([par(las = 0..3)], [tick labels: parallel, horizontal, perpendicular, vertical])
#row([par(bty = "o")], [box: `"o"`, `"l"`, `"7"`, `"u"`, `"."`, `"["`])
#row([par(xaxs = "i")], [`"r"` (default, 4% padding) or `"i"` (exact data range)])
#row([par(yaxs = "i")], [same, for the y axis])
#row([par(tck = -0.02)], [tick length; negative draws outside, `0` removes])
#row([par(cex = 1.2)], [scale all plot text])
#row([par(family = "mono")], [base font family])
#row([par(font.main = 2)], [point size, main text])

#note([`las = 1` is worth setting on any chart with numeric ticks — it stops y-axis labels being drawn slanted.])

#sect[`par()` — panels and state]

#row([par(mfrow = c(2, 2))], [panels filled by row])
#row([par(mfcol = c(2, 2))], [panels filled by column])
#row([layout(matrix, widths, heights)], [ragged panels; `widths`/`heights` in 0–1])
#row([layout(1)], [cancel `layout()`, back to a single panel])
#row([par(new = TRUE)], [draw onto the current plot without clearing it])
#row([par(no.readonly = TRUE)], [capture *all* current settings, for restoring])
// '<-' and '$' are markup-significant in Typst ('<' opens a label, '$' opens
// maths), so R snippets containing them have to be raw inline code rather than
// plain markup.
#row([`op <- par(x)` / `par(op)`], [set and capture in one call, then restore])

`par()` is device state and persists until changed. Capture and restore rather
than hand-writing old values back — and in a function, wrap the restore in
`on.exit()` so an error cannot leave the device mangled.

#code([
  ```r
  init <- par(no.readonly = TRUE)      # snapshot everything
  par(mfrow = c(1, 2), mar = c(4, 4, 3, 1))
  plot(x1)
  plot(x2)
  par(init)                           # always restore
  ```
])

#sect[Export recipes]

#row([units = "in", res = 300], [the combination to use for anything printed])
#row([pdf(onefile = FALSE)], [one file per page — safer for long batch jobs])
#row([pdf(width = 6, height = 4)], [inches, not pixels])
#row([pointsize = 12], [raise it on small or high-`res` exports, or labels vanish])
#row([`file.info(f)$size`], [print it in a batch loop; `0` means `dev.off()` was missed])

#sect[Colourblind-safe palettes (R >= 4.1)]

#code([
  ```r
  palette.pals()                             # every built-in palette
  palette.colors(palette = "Okabe-Ito")      # 9 colours, colourblind-safe
  palette.colors(palette = "Okabe-Ito", alpha = 0.5)
  ```
])

Use the hex values *as R prints them* — hand-typing them from memory is how
palettes get subtly wrong. The first Okabe-Ito colour is black, so drop it with
`[-1]` unless you want black as your first series.

#code([
  ```r
  # greyscale check: Rec. 601 luma, not the mean of the channels
  rgb  <- t(col2rgb(pal)) / 255
  luma <- rgb %*% c(0.299, 0.587, 0.114)
  grey <- rgb(luma, luma, luma)
  ```
])

If the greyscale version has series you cannot tell apart, colour was doing work
it should not do alone. Add a second channel: `pch`, `lty`, or direct labels.

#sect[`axis()` — drawing your own]

#row([xaxt = "n" / yaxt = "n"], [suppress the automatic axis *first*, or you draw two])
#row([axis(1, at, labels)], [1 bottom · 2 left · 3 top · 4 right])
#row([axis(1, at, labels = FALSE)], [ticks with no labels])
#row([axis(4)], [add a second, right-hand axis — usually a different unit])
#row([axis(..., las = 1)], [force horizontal labels, e.g. for dates])
#row([outer = TRUE], [draw on the figure margin, not the plot region])

Axis positions are plain numbers, so dates work by converting and formatting.

#code([
  ```r
  when <- as.Date("2026-01-01") + 0:6 * 30
  plot(when, sales, type = "b", xaxt = "n")
  axis(1, at = as.numeric(when), labels = format(when, "%b %d"), las = 1)
  ```
])

#sect[Drawing primitives]

#row([plot(x, y, type=)], [`"p"` points · `"l"` line · `"b"` both · `"o"` overplot · `"h"` histogram · `"n"` axes only])
#row([points() / lines()], [add to the *current* plot without clearing it])
#row([segments(x0,y0,x1,y1)], [straight segments: error bars, caps, reference lines])
#row([arrows(x0,y0,x1,y1)], [line with a head; args run *from* → *to*])
#row([polygon(x, y, col=)], [closed filled shape; CI bands via `c(x, rev(x))`])
#row([rect() / text()], [boxes and labels at coordinates])
#row([legend(x, y, legend)], [x/y coords, or `"topleft"`, `"bottomright"`, …])
#row([text(x, y, labels)], [labels at coordinates; `pos`, `offset`, `padj`])
#row([mtext(text, side)], [margin text; side 1–4 as for `axis()`])
#row([abline(a, b)], [reference line; also `v =`, `h =`])

#sect[State you must restore]

Every call below changes device state that outlives the call itself. If you
change it, restore it — or the next plot in the session silently inherits it.

#rowhead([call], [leaves behind])
#row([par(mfrow / mfcol)], [multi-panel layout; `layout(1)` cancels it])
#row([par(mar/oma/mgp/las/bty)], [page geometry, persists until reset])
#row([par(new = TRUE)], [a later `plot()` draws on top instead of clearing])
#row([an open device], [output goes to the wrong place; `dev.off()` it])
#row([setwd()], [inside a script, the working directory stays changed])
#row([options()], [process-wide until changed back])

#v(0.4em)
#align(center)[
  #text(size: 6.5pt, fill: faint)[
    Full explanations: Chapter 12, *Production Export & Graphical Devices* ·
    viz-base.rsquaredacademy.com
  ]
]