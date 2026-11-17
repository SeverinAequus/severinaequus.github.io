# severinaequus.github.io

Source for [scientific-illuminism.org](https://scientific-illuminism.org/), the publications site of Severin Aequus. It's a GitHub Pages site built with Jekyll and the `jekyll-theme-minimal` theme.

## Layout

| Path | What it is |
| --- | --- |
| `index.md` | The site's home page: the tab strip (Books, Media, Bio, Additional Content), its styles, and the JavaScript that builds the essay lists. |
| `player.html` | Stand-alone page that plays an essay's video or audio (`?type=video\|audio&src=…&title=…`). |
| `media-docs/`, `bio-docs/`, `extra-docs/` | The PDF/TXT files that essay links open. |
| `_includes/head-custom.html` | Extra `<head>` content added to the theme. |
| `assets/css/` | Theme stylesheet overrides. |
| `deploy.ps1` | Uploads an essay's files to its GitHub release (see below). Not published to the site. |

## How the essay lists work

The Media, Bio, and Additional Content tabs aren't written by hand. When the page loads, each tab asks the GitHub API for the assets on a release in this repo:

| Tab | Release tag | Document folder |
| --- | --- | --- |
| Media | `media` | `media-docs/` |
| Bio | `bio` | `bio-docs/` |
| Additional Content | `extra` | `extra-docs/` |

Each `.pdf` (or, on Additional Content, `.txt`) asset becomes one entry. If the PDF and TXT share a name, the PDF wins. An `.mp4` or `.m4a` with the same base name adds an "Explainer Video" or "Deep Dive Podcast" link. Underscores in filenames are shown as spaces in titles.

To publish an essay, copy its document into the matching `*-docs/` folder and upload its files to the matching release. `deploy.ps1` handles the release upload for `media` and `extra`:

```powershell
./deploy.ps1 "Name Of Essay"
```

## Linking to a single essay

Every entry gets a URL fragment built from its tab and filename:

```
https://scientific-illuminism.org/#extra-name-of-essay
```

Opening that link switches to the right tab and scrolls to the essay. The copy icon next to each title copies that link.

Because the link comes from the filename, **renaming a file breaks any links already shared to it.**
