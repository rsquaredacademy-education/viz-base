#!/usr/bin/env Rscript
# Pre-computes the container image sizes used by Chapter 1
# ("Why Base R Graphics in 2026?").
#
# Run once by hand:
#
#     Rscript scripts/docker-sizes.R
#
# Writes data/docker-sizes.csv, which is the ONLY artefact the book consumes.
#
# The point being measured. A reader who ships R in production usually ships it
# in a container, so "no dependencies" has a concrete meaning there: the image
# is whatever base R costs and nothing more. Two images from the same publisher
# make that measurable, because rocker/tidyverse is built ON TOP OF rocker/r-ver
# -- the same R, the same base system, plus the package layer. The difference
# between them is therefore the cost of the tidyverse layer and nothing else,
# which is a cleaner comparison than diffing two unrelated images.
#
# Everything here is a published number read over HTTP, not a local build. No
# Docker daemon is involved, which is why this can run anywhere. The cost is
# that we cannot control the comparison, so the caveats are recorded in the CSV
# rather than left to the chapter:
#
#   * These are Docker Hub's reported sizes for the whole tag, which is the sum
#     of its compressed layers. That is a real number a real user downloads, so
#     it is the honest one to quote -- but it is not the on-disk unpacked size,
#     and the ratio between two tags is only as fair as the fact that they were
#     built at the same time by the same publisher.
#   * Tags are pinned, never "latest", so the row can be re-fetched later and
#     compared. An unpinned tag would silently become a different image.
#
# Sizes are MB of download, not MB of RAM, and not install time. The chapter
# must not slide them into either of those.

out_csv <- file.path("data", "docker-sizes.csv")
stopifnot(dir.exists(dirname(out_csv)))

# rocker/r-ver is R with the recommended packages and no CRAN layer.
# rocker/tidyverse is the same base plus the tidyverse stack.
# Tags are pinned to the R version rather than floating on latest.
images <- data.frame(
  image = c(
    "rocker/r-ver",
    "rocker/r-ver",
    "rocker/tidyverse",
    "rocker/tidyverse"
  ),
  tag = c("4.5.2", "latest", "4.5.2", "latest"),
  layer = c("R only", "R only", "R + tidyverse", "R + tidyverse"),
  stringsAsFactors = FALSE
)

# Docker Hub's v2 API. readLines() is enough -- no httr, no jsonlite, because
# this script has to stay base R like everything else the book runs.
hub_json <- function(image, tag) {
  url <- sprintf("https://hub.docker.com/v2/repositories/%s/tags/%s",
                 image, tag)
  lines <- readLines(url, warn = FALSE)
  txt <- paste(lines, collapse = "")
  stopifnot(startsWith(txt, "{"))

  # Pull out the two fields we need without a JSON parser. Both are plain
  # numbers at the top level of the tag object.
  num <- function(field) {
    m <- regmatches(txt, regexpr(sprintf('"%s"\\s*:\\s*[0-9]+', field), txt))
    if (!length(m)) stop("field '", field, "' not found for ", image, ":", tag)
    as.numeric(sub(sprintf('"%s"\\s*:\\s*', field), "", m))
  }
  txt_date <- function(field) {
    m <- regmatches(txt, regexpr(sprintf('"%s"\\s*:\\s*"[^"]*"', field), txt))
    if (!length(m)) return(NA_character_)
    sub(sprintf('"%s"\\s*:\\s*"', field), "", sub('"$', "", m))
  }

  list(size_bytes = num("full_size"),
       last_updated = txt_date("last_updated"))
}

MB <- 1024^2

res <- list()
for (i in seq_len(nrow(images))) {
  img <- images$image[i]
  tag <- images$tag[i]
  cat(sprintf("fetching %s:%s ...\n", img, tag))

  got <- hub_json(img, tag)

  res[[length(res) + 1]] <- data.frame(
    image = img,
    tag = tag,
    layer = images$layer[i],
    size_mb = round(got$size_bytes / MB, 1),
    size_bytes = got$size_bytes,
    last_updated = got$last_updated,
    stringsAsFactors = FALSE
  )
}

out <- do.call(rbind, res)

# The layer cost, computed here rather than in the chapter. Only the pinned tags
# are differenced: subtracting "latest" from a pinned tag would mix two
# different R versions and produce a number that means nothing.
base_mb <- out$size_mb[out$image == "rocker/r-ver" & out$tag == "4.5.2"]
tdy_mb <- out$size_mb[out$image == "rocker/tidyverse" & out$tag == "4.5.2"]
stopifnot(!is.na(base_mb), !is.na(tdy_mb))

out$extra_layer_mb <- round(tdy_mb - base_mb, 1)
out$extra_layer_x <- round(tdy_mb / base_mb, 2)
out$retrieved_on <- format(Sys.Date(), "%Y-%m-%d")
out$source <- "Docker Hub v2 API (compressed layer total)"

write.csv(out, out_csv, row.names = FALSE)

cat("\n", strrep("-", 88), "\n", sep = "")
print(out[, c("image", "tag", "layer", "size_mb", "extra_layer_mb",
              "extra_layer_x")], row.names = FALSE)
cat(strrep("-", 88), "\n")

cat(sprintf(
  "\nwrote %s\n  tidyverse layer costs %s MB on top of R (%sx) as of %s\n",
  out_csv, format(tdy_mb - base_mb, big.mark = ","),
  format(round(tdy_mb / base_mb, 1), nsmall = 1), out$retrieved_on[1]))
cat("Download sizes from published metadata, not a local build. Re-fetch\n",
    "before quoting them; image tags get rebuilt and sizes move.\n", sep = "")