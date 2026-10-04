# Minting a DOI (one-time, needs your Zenodo account)

Everything that can be prepared in advance has been. Two steps remain, and both
require you: they are account actions, not code.

## What is already in place

| File | What it does |
|:--|:--|
| `.zenodo.json` | Zenodo's metadata schema, filled in: title, creator, CC BY-NC-SA 4.0 licence, keywords, publication type `book`, and a `related_identifiers` link back to the live site. Zenodo reads this on publish. |
| `citation.bib` | The BibTeX entry for the book. `doi` is deliberately a `10.5281/zenodo.XXXXXXX` placeholder. |
| Preface, *How to cite this book* | A copy-pasteable BibTeX block with **no** `doi` field, plus a note explaining why. |
| `references.qmd` | Sources for every claim in Chapter 1, and provenance for both vendored datasets. |

## Step 1 — connect the repository on Zenodo

1. Log in at <https://zenodo.org> (a GitHub login works, and is the easy path).
2. Go to **GitHub** → **New** → pick `rsquaredacademy-education/viz-base`.
3. Zenodo reads `.zenodo.json` and pre-fills the form. Check the title and
   licence, then **Enable**.

Zenodo now snapshots the repository. The first publish creates the concept DOI
and a version DOI; every later release gets its own version DOI, and the concept
DOI always resolves to the latest.

## Step 2 — publish, then fill in the DOI

1. **Create new version**, then **Publish**. Copy the DOI from the landing page.
2. Put it in **two** places in this repo:
   - `citation.bib` — replace `10.5281/zenodo.XXXXXXX`
   - `README.md` — append the DOI to the `doi` field in the *Cite this book*
     BibTeX block
3. Then add the same DOI to the Preface BibTeX block in `index.qmd`, so the
   block on the site matches the downloadable file.

Do all three in one commit. A DOI present in one place and missing from another
is worse than no DOI, because readers will trust whichever one they find first.

## Why the placeholder is a placeholder

An unresolvable DOI looks authoritative and fails silently — a reader pastes it
into their reference list and nobody notices until a reviewer tries to follow it.
So the placeholder is inert rather than plausible-looking: `zenodo.XXXXXXX`
cannot be mistaken for a real DOI.

The Preface block has no `doi` field at all for the same reason. A citation
without a DOI is honest; a citation with a broken one is not.

## Versioning, if this is ever tagged

Zenodo tracks **Git tags**, not commits. A DOI minted now versions from the
default branch forever unless you publish a release. When you are ready for a
citable version:

```bash
git tag -a v1.0.0 -m "Version 1.0"
git push origin v1.0.0
```

Then **Create new version** on Zenodo. Book-in-progress releases are not worth
a DOI each; one versioned release plus a rolling concept DOI is the normal
pattern.