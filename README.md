# severinaequus.github.io

Source for [scientific-illuminism.org](https://scientific-illuminism.org/), the publications site of Severin Aequus. It's a GitHub Pages site built with Jekyll and the `jekyll-theme-minimal` theme.

## Layout

| Path | What it is |
| --- | --- |
| `index.md` | The site's home page: the tab strip (Books, Media, Bio, Additional Content), its styles, and the JavaScript that builds the essay lists. |
| `player.html` | Stand-alone page that plays an essay's video or audio (`?type=video\|audio&src=…&title=…`). |
| `media-docs/`, `bio-docs/`, `extra-docs/` | The PDF/TXT files that essay links open. |
| `danger/index.md`, `danger-docs/` | The unlisted Danger page and its essays (see below). |
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

## The Danger page

[scientific-illuminism.org/danger/](https://scientific-illuminism.org/danger/) lists essays with very heavy, explicit content. Nothing on the main site links to it, and it carries a `noindex` tag so search engines leave it out of their results. It is unlisted, not private: anyone with the URL can open it, and the files are in this public repo.

The Danger page and its Markdown essay pages also ask for a password (`_includes/danger-gate.html`). It's a speed bump, not security: the check runs in the browser, the content is public in this repo, and PDF/TXT files can't be gated at all. A visitor's browser remembers the password once it's entered. To change it, put the SHA-256 of the new password in `GATE_HASH`:

```
printf '%s' 'new-password' | sha256sum
```

Unlike the other tabs, it doesn't use a GitHub release. Jekyll builds the list from the files in `danger-docs/` when the site is published, so to add an essay, commit its `.md`, `.pdf` or `.txt` there and push. Underscores show as spaces. If several formats share a name, only one is listed: Markdown first, then PDF, then TXT.

Jekyll renders a `.md` essay as a page in the site's theme (`Name.md` is published as `Name.html`), and the list links to that page as `[Web Page]`. Every page under `danger-docs/` gets the same `noindex` tag as the Danger page (set in `_config.yml`). Because Jekyll runs Liquid on Markdown files, text like `{{` or `{%` in an essay will be read as template code. Wrap any such passage in `{% raw %}` … `{% endraw %}`. There are no video or podcast links on this page.

Each entry links to itself as `https://scientific-illuminism.org/danger/#danger-name-of-essay`.
