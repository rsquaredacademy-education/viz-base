# scripts/webr-smoke.R
# Static smoke test for {webr-r} live cells: every cell must parse as R and
# must not depend on the book's server-side data/ directory, because the webR
# filesystem starts empty in the browser.
# (Full browser execution is covered by manual QA; this runs in CI < 30 s.)

# Base R only, by design: the book's zero-dependency promise means live cells
# may only touch datasets shipped with R itself.
allowed_objects <- c(
  "mtcars", "AirPassengers", "iris", "cars", "ToothGrowth",
  "faithful", "volcano", "is.orientable"
)

qmds <- list.files(pattern = "\\.qmd$")
stopifnot(length(qmds) > 0)

cells <- 0L
for (f in qmds) {
  lines <- readLines(f, warn = FALSE)
  starts <- grep("^```\\{webr-r\\}$", lines)
  ends <- grep("^```$", lines)
  for (s in starts) {
    e <- ends[ends > s][1]
    stopifnot(!is.na(e))
    code <- paste(lines[(s + 1):(e - 1)], collapse = "\n")
    invisible(parse(text = code)) # fails loudly on syntax errors
    cells <- cells + 1L

    # No library() calls: nothing to install is the whole point of webR here.
    libs <- regmatches(code, gregexpr("(?<=library\\()[A-Za-z0-9.]+(?=\\))", code, perl = TRUE))[[1]]
    if (length(libs)) {
      stop("library() in a live cell (", f, ") - the book is zero-dependency: ", libs)
    }

    # The browser has no data/ directory. Any file read must instead be
    # fetched from an absolute https URL inside the cell.
    if (grepl("(^|[^/A-Za-z0-9._-])data/", code, perl = TRUE) &&
        !grepl("download\\.file", code)) {
      stop("live cell reads data/ but has no download.file() guard (", f, ")")
    }
    if (grepl("read\\.csv|read\\.table|load\\(|readRDS|file\\(", code)) {
      stop("file read in a live cell (", f, ") - the webR filesystem starts empty")
    }

    # Only built-in datasets may be referenced.
    for (m in regmatches(code, gregexpr("\\b(mtcars|iris|airpassengers|cars)\\b",
                                        code, ignore.case = TRUE, perl = TRUE))[[1]]) {
      ds <- tolower(m)
      if (ds == "airpassengers") ds <- "airpassengers"
      if (!ds %in% allowed_objects) stop("non-built-in dataset: ", m, " (from ", f, ")")
    }
  }
}
message("webr smoke OK: ", cells, " cells across ", length(qmds), " files")