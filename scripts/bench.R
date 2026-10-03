#!/usr/bin/env Rscript
# Pre-computes the base-graphics vs ggplot2 benchmark used by Chapter 1
# ("Why Base R Graphics in 2026?").
#
# Run once by hand, on the machine whose numbers we are willing to publish:
#
#     Rscript scripts/bench.R
#
# Writes data/bench-base-vs-ggplot2.csv, which is the ONLY artefact the book
# consumes. The chapter draws its figure from that CSV with base graphics, so
# neither `bench` nor `ggplot2` is needed to knit the book -- that keeps the
# zero-dependency promise the whole book is built on.
#
# Three things this script exists to get right:
#
#   1. Both sides must actually DRAW. A bare ggplot() only builds an object and
#      measures object construction, which flatters ggplot2 and makes the
#      comparison meaningless. Every expression here ends in a real render, and
#      base renders to a null device so nothing opens a window. The
#      `ggplot2_construct` row is kept deliberately as the counter-example.
#   2. Timing and memory are measured by different means, and the same means are
#      applied to all three approaches. bench's own memory profiler (profmem)
#      cannot instrument print.ggplot(), so asking it to would have measured
#      base and the construct-only case while silently dropping the case the
#      comparison is actually about. Peak usage therefore comes from gc(),
#      which is uniform and dependency-free.
#   3. Absolute timings are machine-specific. The chapter quotes them as an
#      order of magnitude and names the machine they came from.
#
# On fairness: opening and closing pdf(NULL) costs roughly 5 ms and is charged
# to the base case on every iteration. In a real session base draws to an
# already-open device, so these numbers flatter ggplot2 slightly. The
# comparison is therefore conservative, which is the direction we want.

# Pin the locale before loading bench. Under a regional locale (this box
# defaults to English_India.utf8) profmem fails to start and bench's own
# bench_time formatting throws -- both surface as confusing errors deep inside
# the package rather than as a locale problem.
invisible(Sys.setlocale("LC_TIME", "C"))
invisible(Sys.setlocale("LC_COLLATE", "C"))

suppressPackageStartupMessages({
  library(bench)
  library(ggplot2)
})

out_csv <- file.path("data", "bench-base-vs-ggplot2.csv")
stopifnot(dir.exists(dirname(out_csv)))

sizes <- c(1e4, 1e5)

# Deterministic inputs: the same points for both engines at every size, so the
# only variable is the plotting system.
make_data <- function(n) {
  set.seed(1)
  data.frame(
    x = runif(n),
    y = runif(n),
    g = factor(sample(letters[1:4], n, replace = TRUE))
  )
}

# Render to the null device. pdf(NULL) accepts and discards output, so the
# plotting work still happens but no file or window appears.
draw_to_null <- function(expr) {
  grDevices::pdf(NULL)
  on.exit(grDevices::dev.off(), add = TRUE)
  force(expr)
}

# Peak heap usage in MB, attributable to one expression.
#
# R >= 4.5 reports gc() columns directly in MB; older R reports 8-byte units.
peak_mb <- function(expr) {
  invisible(gc(reset = TRUE, full = TRUE))
  force(expr)
  g <- gc(full = TRUE)
  col <- grep("max used", colnames(g))[1]
  vals <- sum(g[, col])
  if (grepl("Mb", colnames(g)[col], fixed = TRUE)) vals else vals * 8 / 1024^2
}

res <- list()

for (n in sizes) {
  d <- make_data(n)

  expressions <- list(
    base = function() draw_to_null(graphics::plot(d$x, d$y)),
    # Counter-example: constructs the plot object but never draws it. This is
    # what "ggplot2 is fast" usually measures, and it is why the row is here.
    ggplot2_construct = function() {
      p <- ggplot2::ggplot(d, ggplot2::aes(x = x, y = y))
      invisible(p)
    },
    ggplot2_render = function() {
      p <- ggplot2::ggplot(d, ggplot2::aes(x = x, y = y))
      draw_to_null(print(p))
    }
  )

  cat(sprintf("benchmarking n = %s\n", format(n, big.mark = ",")))

  for (approach in names(expressions)) {
    expr <- expressions[[approach]]

    # Timing: memory = FALSE so all three approaches are measured identically.
    # Note the call: mark() evaluates whatever expression it is handed, so the
    # function has to be invoked or it would only time the lookup of a closure.
    m <- mark(
      expr(),
      check = FALSE,
      iterations = 15,
      min_iterations = 5,
      memory = FALSE
    )

    # Memory: separate, uniform gc() pass over the same expression.
    mem <- peak_mb(expr())

    res[[length(res) + 1]] <- data.frame(
      n            = n,
      approach     = approach,
      # bench_time is a difftime in SECONDS; the column is milliseconds.
      median_ms    = round(as.numeric(median(m$median)) * 1000, 1),
      peak_mem_mb  = round(mem, 1),
      n_iter       = m$n_itr,
      stringsAsFactors = FALSE
    )
  }
}

out <- do.call(rbind, res)
write.csv(out, out_csv, row.names = FALSE)

cat("\n", strrep("-", 64), "\n", sep = "")
print(out, row.names = FALSE)
cat(strrep("-", 64), "\n", sep = "")

cat(sprintf(
  "\nwrote %s\n  R %s | %s | ggplot2 %s | bench %s\n",
  out_csv, getRversion(), R.version$platform,
  packageVersion("ggplot2"), packageVersion("bench")
))
cat("Absolute timings are machine-specific. Quote them as an order of\n",
    "magnitude, and name the R version and platform alongside them.\n", sep = "")