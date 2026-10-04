# Citing this book, and minting the next DOI

**Current version:** 1.0.0, released 2026-10-04
**Version DOI:** [`10.5281/zenodo.23138733`](https://doi.org/10.5281/zenodo.23138733)
**Concept DOI:** `10.5281/zenodo.23138732` — always resolves to the latest version

## Which DOI to use

Zenodo issues two, and the difference matters.

| | Value | Behaviour |
|:--|:--|:--|
| **Version DOI** | `10.5281/zenodo.23138733` | Pinned to v1.0.0 forever. A citation to it keeps resolving to this exact content after v1.1 exists. |
| **Concept DOI** | `10.5281/zenodo.23138732` | Always resolves to whichever version is current. |

The published citation uses the **version DOI**, because the citation also
carries `version = {1.0}` and a reader who cites "Version 1.0" should get
Version 1.0, not whatever comes next.

Use the **concept DOI** instead if you are citing the book as a living work and
want readers to land on the latest edition — which is the convention most
journals prefer for anything that gets revised.

Whichever you pick, keep the two consistent. A book whose README cites the
concept DOI and whose Preface cites the version DOI is citing itself two
different ways.

## What is where

The DOI now appears in four places. They are hand-maintained; nothing generates
them.

| File | What it holds |
|:--|:--|
| `citation.bib` | The BibTeX entry, with `doi` and `version` fields |
| `index.qmd` | *How to cite this book*, in the Preface — the block a reader copies |
| `README.md` | The same block, plus a rendered link to the DOI |
| Release notes | Attached to the GitHub release for the matching tag |

` HOW-TO-CITE.md ` (this file) and `.zenodo.json` carry no DOI. The former
explains, the latter is the input Zenodo reads.

## Why `.zenodo.json` exists

Zenodo's GitHub integration pre-fills the deposition form from `.zenodo.json`, so
title, creator, licence, publication type and keywords are declared once in the
repository rather than retyped into a web form each release. Verified against the
minted record: title, `version`, `Book`, `cc-by-nc-sa-4.0` and the creator all came
through unchanged.

Change the metadata there, not in the Zenodo form, or the two drift.

## Releasing v1.1

The order matters and it is the reverse of what the first release needed.

1. Land the content changes on `master`. Let CI finish — it rebuilds `docs/`,
   the PDF, the ePub and the cheatsheet, and asserts the cheatsheet is still one
   page.
2. **Publish the GitHub release first.** Push the annotated tag, then create the
   release with the PDF, ePub and cheatsheet attached:
   ```bash
   git tag -a v1.1.0 -m "Version 1.1"
   git push origin v1.1.0
   gh release create v1.1.0 \
     --title "Data Visualization with R: Base Graphics — v1.1" \
     --notes-file release-notes.md \
     docs/Data-Visualization-with-R.pdf \
     docs/Data-Visualization-with-R.epub \
     docs/base-par-cheatsheet.pdf
   ```
3. **Then** publish the new Zenodo version and copy its **version** DOI.
4. Update all four places from the table above, in **one commit**.

Releasing before minting is what makes the mapping unambiguous: the GitHub
release for `v1.1.0` is demonstrably the artifact Zenodo archived. Doing it the
other way round leaves you reasoning about which commit was current at the moment
someone clicked a button.

### On automatic versioning

If Zenodo offers to version automatically on new GitHub releases, **decline**.
Every tag would mint a DOI, and a book gets a lot of tags — a typo fix, a
dependency bump, a CI pin. Manual publishing keeps one DOI per deliberate
release.

## What not to do

**Do not put a placeholder DOI in a citation.** It was avoided for the whole
period before minting, and the reason still holds: `10.5281/zenodo.XXXXXXX` looks
exactly like a real DOI and resolves to nothing. A reader pastes it into their
reference list and the first person to find out is a reviewer a year later. An
absent `doi` field is honest; a broken one is not.

**Do not trust the DOI without resolving it.** Before publishing a new one:

```bash
curl -s https://zenodo.org/api/records/<id> | head -c 400
```

Check that `metadata.version`, `metadata.resource_type.title` and
`metadata.license.id` match what you intended to publish. A DOI that resolves to
the wrong version is worse than one that is missing.