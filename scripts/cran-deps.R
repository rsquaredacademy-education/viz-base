#!/usr/bin/env Rscript
# Pre-computes the CRAN dependency table used by Chapter 1
# ("Why Base R Graphics in 2026?").
#
# Run once by hand:
#
#     Rscript scripts/cran-deps.R
#
# Writes data/cran-deps.csv, which is the ONLY artefact the book consumes.
#
# Why this script exists at all. Chapter 1 wants to claim that base graphics
# cost a reader nothing to install, and the obvious way to support that is to
# assert it. An assertion is worth nothing in a book whose whole pitch is
# authority, so this measures it against CRAN's own metadata instead: for each
# package, how many declared dependencies are NOT part of base R, and does it
# pull in a graphics system beyond the one that ships with R.
#
# Reading the numbers honestly matters more than making them look good, and two
# of the rows are unflattering:
#
#   * The author's own packages (olsrr, rfm, blorr, descriptr) all declare
#     ggplot2. Chapter 1 says so explicitly rather than implying the author's
#     CRAN work is base-graphics-based. It is not, and a reader who checked
#     would find out.
#   * Hmisc declares ggplot2 too, so it sits on the "mixed" side despite being
#     a veteran base-graphics package.
#
# What the table cannot tell you. Declared metadata says what a package needs,
# not what it plots with. Whether a given package actually draws with base
# graphics has to be read out of its source; the chapter cites the specific
# files it checked, with a date, rather than inferring plotting style from
# dependency metadata. That is why there is no graphics_system column here --
# an inferred one would be a guess wearing a table's clothes.
#
# Absolute numbers are CRAN state at the retrieval date and will drift. The
# retrieved_on column exists so a stale row is visibly stale.

out_csv <- file.path("data", "cran-deps.csv")
stopifnot(dir.exists(dirname(out_csv)))

repos <- "https://cloud.r-project.org"

# Base and recommended packages ship with R itself, so depending on them costs
# the reader nothing.
#
# Two traps here. installed.packages(priority = "base+recommended") does NOT
# work -- it silently returns only the 14 base packages, which would make every
# recommended dependency (lattice, nlme, foreign, MASS, ...) look like an extra
# install. The two calls have to be unioned by hand.
#
# And "R" is not a package. CRAN metadata uses it in Depends purely as a version
# constraint ("R (>= 4.1.0)"), so counting it would add a phantom dependency to
# every single row and make the table look uniformly worse than reality.
#
# priority() is gone as of R 4.5, hence installed.packages() below.
shipped <- c(
  rownames(utils::installed.packages(priority = "base")),
  rownames(utils::installed.packages(priority = "recommended"))
)
stopifnot(all(c("graphics", "stats", "utils", "lattice", "nlme") %in% shipped))
stopifnot(length(shipped) > 20)  # guards the "base+recommended" trap above

# The packages the chapter discusses, with the claim each one is there to test.
# `role` is carried into the CSV so a stale row is still interpretable later.
targets <- data.frame(
  package = c(
    # Base-graphics-heavy or base-only, i.e. the "no extra install" end.
    "plotrix", "TeachingDemos", "faraway", "gplots", "psych", "effects",
    # Veteran base-graphics package that has since taken on ggplot2 too.
    "Hmisc",
    # The author's own CRAN packages. Kept in the table on purpose.
    "olsrr", "rfm", "blorr", "descriptr"
  ),
  role = c(
    "base-graphics add-on", "base-graphics add-on", "base-graphics add-on",
    "base-graphics add-on", "base-graphics add-on", "base + grid",
    "mixed", "author package", "author package", "author package",
    "author package"
  ),
  stringsAsFactors = FALSE
)

cat("reading CRAN metadata from", repos, "\n")
ap <- utils::available.packages(repos = repos)
cat(sprintf("%d packages indexed\n", nrow(ap)))

# Depends/Imports/LinkingTo are comma-separated and may be NA for "none".
split_deps <- function(x) {
  if (is.na(x) || !nzchar(trimws(x))) return(character(0))
  parts <- strsplit(x, ",", fixed = TRUE)[[1]]
  # Each entry can carry a version constraint and extra fields, as in
  # "pbkrtest (>= 0.4-4)" or "lme4 (>= 1.1-27.1)". Keep the name only.
  parts <- trimws(sub("\\(.*$", "", parts))
  parts <- parts[nzchar(parts)]
  unique(parts)
}

missing <- setdiff(targets$package, rownames(ap))
if (length(missing)) {
  stop("not on CRAN, fix the target list: ", paste(missing, collapse = ", "))
}

res <- list()
for (i in seq_len(nrow(targets))) {
  pkg <- targets$package[i]
  cat("  ", pkg, "\n")

  depends <- split_deps(ap[pkg, "Depends"])
  imports <- split_deps(ap[pkg, "Imports"])
  links <- split_deps(ap[pkg, "LinkingTo"])

  all_deps <- unique(c(depends, imports, links))
  non_base <- setdiff(all_deps, c(shipped, "R"))

  res[[length(res) + 1]] <- data.frame(
    package = pkg,
    role = targets$role[i],
    version = ap[pkg, "Version"],
    n_nonbase = length(non_base),
    nonbase_deps = paste(sort(non_base), collapse = " "),
    imports_ggplot2 = "ggplot2" %in% all_deps,
    depends = paste(sort(depends), collapse = " "),
    imports = paste(sort(imports), collapse = " "),
    linkingto = paste(sort(links), collapse = " "),
    stringsAsFactors = FALSE
  )
}

out <- do.call(rbind, res)
# Baseline row: what the base-graphics path actually costs. `graphics` is a
# base package and so is not on CRAN at all, which is precisely the point --
# there is nothing to download and nothing to declare.
#
# Added before the provenance columns below, so every row ends up with the same
# shape.
out <- rbind(
  data.frame(
    package = "graphics", role = "base R (baseline)",
    version = as.character(getRversion()),
    n_nonbase = 0L, nonbase_deps = "",
    imports_ggplot2 = FALSE,
    depends = "", imports = "", linkingto = "",
    stringsAsFactors = FALSE
  ),
  out
)

out$retrieved_on <- format(Sys.Date(), "%Y-%m-%d")
out$r_version <- getRversion()

write.csv(out, out_csv, row.names = FALSE)

cat("\n", strrep("-", 92), "\n", sep = "")
print(out[, c("package", "role", "version", "n_nonbase", "imports_ggplot2")],
      row.names = FALSE)
cat(strrep("-", 92), "\n")

cat(sprintf("\nwrote %s\n  retrieved from %s on %s\n",
            out_csv, repos, out$retrieved_on[1]))
cat("These are CRAN's numbers on the retrieval date and they will drift.\n",
    "Re-run the script rather than editing the CSV by hand.\n", sep = "")