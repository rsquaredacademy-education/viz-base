#!/usr/bin/env Rscript
# Pre-computes the startup-latency figures used by Chapter 1
# ("Why Base R Graphics in 2026?").
#
# Run once by hand, on the machine whose numbers we are willing to publish:
#
#     Rscript scripts/startup.R
#
# Writes data/startup-latency.csv, which is the ONLY artefact the book consumes.
# Same rule as scripts/bench.R: nothing here runs at knit time, so the book
# keeps its zero-dependency promise.
#
# What is being claimed, and what is not. The book's argument is that base
# graphics cost a reader nothing to install and almost nothing to start. This
# script measures the second half of that: what it costs to bring a plotting
# session up.
#
#   approach = "vanilla"    Rscript --vanilla, no packages. The floor: what
#                           starting R itself costs.
#   approach = "graphics"   + library(graphics). graphics ships with R, so this
#                           is the honest cost of the base-graphics path.
#   approach = "ggplot2"    + library(ggplot2), which loads its own tree.
#
# The headline metric is WALL CLOCK around a whole child process, not the time
# the child spends inside library(). That distinction decides whether this
# script reports anything at all: loading a base package takes well under a
# millisecond, so an in-process timer rounds it to 0 and the base-graphics row
# looks like a missing measurement. The wall clock cannot do that -- it always
# includes R's own startup, which is what a reader actually waits for. The
# in-process time is still reported, as load_ms, because wall - vanilla is
# exactly the package-loading cost and load_ms says where inside the child it
# went.
#
# Two further traps this script exists to avoid:
#
#   1. Timing one run measures disk cache, not code. Each approach runs n_iter
#      times and the MEDIAN is reported, so a cold first run cannot masquerade
#      as the typical case. One untimed warm-up run per approach comes first,
#      so paying for reading Rscript off disk never becomes the median.
#   2. Timing Rscript from inside R would fold this script's own startup into
#      every measurement and inflate all three equally. Each measurement
#      therefore launches a fresh child with system2() and the parent clocks it.
#
# Absolute timings are machine-specific and Windows is a bad showing for either
# engine (filesystem and DLL scanning dominate). The chapter quotes them as an
# order of magnitude, names the machine, and rests the argument on the RATIO
# between the rows rather than on any single number.

n_iter <- 15L

out_csv <- file.path("data", "startup-latency.csv")
stopifnot(dir.exists(dirname(out_csv)))

# Child process: load the requested package and report how long that took plus
# how many namespaces ended up loaded. The approach name arrives as the first
# trailing argument so one identical script serves all three cases.
child <- tempfile(fileext = ".R")
writeLines(c(
  'args <- commandArgs(trailingOnly = TRUE)',
  'approach <- args[1]',
  't0 <- proc.time()[["elapsed"]]',
  'if (approach == "graphics") library(graphics)',
  'if (approach == "ggplot2") library(ggplot2)',
  't1 <- proc.time()[["elapsed"]]',
  'cat(sprintf("%.6f|%d", t1 - t0, length(loadedNamespaces())))'
), child)

run_once <- function(approach) {
  t0 <- proc.time()[["elapsed"]]
  out <- suppressWarnings(system2(
    file.path(R.home("bin"), "Rscript"),
    c("--vanilla", shQuote(child), shQuote(approach)),
    stdout = TRUE, stderr = FALSE
  ))
  wall <- 1000 * (proc.time()[["elapsed"]] - t0)

  if (!length(out)) stop("child process produced no output for ", approach)
  parts <- strsplit(tolower(trimws(out[length(out)])), "|", fixed = TRUE)[[1]]
  c(wall_ms = wall,
    load_ms = 1000 * as.numeric(parts[1]),
    namespaces = as.integer(parts[2]))
}

res <- list()
for (approach in c("vanilla", "graphics", "ggplot2")) {
  cat(sprintf("timing %s ...\n", approach))

  invisible(run_once(approach))  # warm-up, discarded

  wall_ms <- numeric(n_iter)
  load_ms <- numeric(n_iter)
  namespaces <- integer(n_iter)
  for (i in seq_len(n_iter)) {
    r <- run_once(approach)
    wall_ms[i] <- r[["wall_ms"]]
    load_ms[i] <- r[["load_ms"]]
    namespaces[i] <- r[["namespaces"]]
  }

  res[[length(res) + 1]] <- data.frame(
    approach   = approach,
    wall_ms    = round(median(wall_ms), 1),
    wall_min_ms = round(min(wall_ms), 1),
    wall_max_ms = round(max(wall_ms), 1),
    load_ms    = round(median(load_ms), 1),
    namespaces = max(namespaces),
    n_iter     = n_iter,
    stringsAsFactors = FALSE
  )
}

out <- do.call(rbind, res)

# The number the chapter actually argues from: what loading the package cost on
# top of the unavoidable floor of starting R. Deriving it here rather than in
# the chapter keeps the subtraction honest and reproducible.
#
# overhead_ms can come out negative, and that is not a bug. library(graphics)
# is a no-op -- graphics is one of the packages R attaches at startup, so the
# session gains no namespaces and the wall clock difference between "vanilla"
# and "graphics" is smaller than the run-to-run spread. spread_ms carries that
# spread so a reader can see the claim is below the noise floor rather than
# having to take it on trust.
baseline <- out$wall_ms[out$approach == "vanilla"]
out$overhead_ms <- round(out$wall_ms - baseline, 1)
out$spread_ms <- round(out$wall_max_ms - out$wall_min_ms, 1)

out$measured_on <- format(Sys.Date(), "%Y-%m-%d")
out$r_version <- getRversion()
out$platform <- R.version$platform
out$ggplot2 <- as.character(utils::packageVersion("ggplot2"))

write.csv(out, out_csv, row.names = FALSE)

cat("\n", strrep("-", 84), "\n", sep = "")
print(out[, c("approach", "wall_ms", "wall_min_ms", "wall_max_ms",
              "spread_ms", "overhead_ms", "load_ms", "namespaces")],
      row.names = FALSE)
cat(strrep("-", 84), "\n")

cat(sprintf(
  "\nwrote %s\n  R %s | %s | ggplot2 %s\n",
  out_csv, getRversion(), R.version$platform, out$ggplot2[1]
))
cat("Absolute timings are machine-specific. Quote them as an order of\n",
    "magnitude, and name the R version and platform alongside them.\n", sep = "")