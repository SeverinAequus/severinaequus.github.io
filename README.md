# severinaequus.github.io

Source for [scientific-illuminism.org](https://scientific-illuminism.org/), the publications site of Severin Aequus. It's a GitHub Pages site built with Jekyll. GitHub runs the build every time `main` is pushed.

## Layout

| Path | What it is |
| --- | --- |
| `_home/`, `_books/`, `_media/`, `_bio/`, `_extra/` | The subpages. Each one is a Jekyll collection: a directory named `_<name>` with an `index.html`, published at `/<name>/` (the home page at `/`). |
| `_layouts/default.html` | The frame around every page: the navigation (a fixed pane on wide screens, a Menu button on narrow ones) and the license footer. |
| `_layouts/list.html` | The shared layout for list subpages (Media, Bio, Additional Content). |
| `assets/js/entry-list.js` | Browser-side behavior for list subpages: the filter box, copy-link buttons, and video/podcast links. |
| `assets/css/style.css` | The look of the page: fonts, colors, and the "book page" panel. |
| `assets/css/site.css` | The navigation, list entries, and the other shared page parts. |
| `player.html` | Stand-alone page that plays an essay's video or audio (`?type=video\|audio&src=…&title=…`). |
| `deploy.ps1` | Copies an essay's documents into its subpage directory and uploads its media to that subpage's GitHub release (see below). Not published to the site. |
| `TODO.md` | Improvements we've tabled. Not published to the site. |

## Subpages

Each subpage's `index.html` starts with front matter like this:

```yaml
---
title: Excerpts and Media   # page title
nav_title: Media            # menu label (defaults to title)
nav_order: 3                # position in the menu; leave out to keep the page out of the menu
permalink: /media/          # URL
layout: list                # only for list subpages
summary: Excerpts from …    # one line shown under "On This Site" on the home page
---
```

To add a subpage, create its `_<name>/index.html` and add `<name>` under `collections:` in `_config.yml`. Jekyll has no way to discover collections on its own.

## List subpages

A subpage with `layout: list` lists every `.md`, `.pdf`, and `.txt` file in its directory. The list is built and sorted by title when the site is built, so it is plain HTML in the published page.

- Files that share a base name make one entry, which links only the best format: `.md` first (shown as `[Web Page]`; Jekyll renders it as a page), then `.pdf`, then `.txt`. Essays start as `.txt` and get converted later, so the older formats can stay in the directory without cluttering the list.
- Underscores in a file name show as spaces in the title.
- In the browser, the page asks the GitHub API for the release whose tag is the directory name without the `_` (`_media` → `media`). Any `.mp4` or `.m4a` in it with the same base name as an entry (ignoring case) adds an "Explainer Video" or "Deep Dive Podcast" link. A subpage with no matching release simply has no video or podcast links.
- The filter box at the top matches titles. Every word typed must appear in the title.

### File naming

Use underscores, not spaces, in file names. An essay's document in the repo and its `.mp4`/`.m4a` in the release must have the same base name. A media file whose name doesn't match any document never appears.

### Publishing an essay

1. Put its document in the subpage's directory, for example `_extra/Name_Of_Essay.pdf`.
2. Upload its `.mp4` and/or `.m4a` to the release with the same tag (`extra`). Releases hold only media. Documents live in the repo.
3. Commit and push.

`deploy.ps1` does steps 1 and 2 for `media` and `extra`. It finds the essay's files in the writing folders and changes spaces to underscores. It copies the documents into the subpage's directory and uploads the media to the release. You still commit and push.

```powershell
./deploy.ps1 "Name Of Essay"
```

## Linking to a single essay

Every entry gets a URL fragment built from its file name:

```
https://scientific-illuminism.org/extra/#name-of-essay
```

Opening that link scrolls to the essay, clearing the filter if it was hiding it. The copy icon next to each title copies that link.

Because the link comes from the file name, **renaming a file breaks any links already shared to it.**
