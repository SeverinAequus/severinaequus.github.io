# TODO

Improvements we've tabled. Not published to the site.

## Content

- **Subpages from Quora answers.** Build subpages from the downloaded Quora answer history, grouped by topic (philosophy, relationships, science, …).
- **Bring the Medium essays home.** Check which Medium essays aren't on this site yet and add them.
- **Bio in `deploy.ps1`.** The script only knows the `media` and `extra` writing folders.
- **The Wounded Angel v2 text.** `_bio/The_Wounded_Angel_v2.pdf` is byte-identical to `_bio/The_Wounded_Angel.pdf`, so the v2 entry shows the v1 text. The only distinct v2 text is `The_Wounded_Angel_v2.txt` in the `bio` release, a compilation of "Boys are from Room 103…", "How To Sleep With a Woman…", and an expanded "The Wounded Angel". Make a real v2 document.

## Finding things

- **Site-wide search.** One search box that covers every subpage.
- **Essay contents search.** Search the text of the essays, not just their titles. This needs a search index built from the documents.
- **Hashtags.** Tag list entries with hashtags, with a navigable tag cloud somewhere.

## Plumbing

- **Release manifest at deploy time.** Have `deploy.ps1` write the release's file list into the repo (for example `_data/<name>.json`), so list pages know their video and podcast links when the site is built, with no GitHub API call in the browser. That API allows 60 requests per hour per visitor.

## Home page

- **Social links.** LinkTree's social icons (Instagram, Facebook, YouTube, TikTok, X, LinkedIn, GitHub, Signal, email, payment, …) aren't on the home page yet. We need their URLs.
