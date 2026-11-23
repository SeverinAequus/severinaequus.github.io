---
title: Danger
noindex: true
---

<style>
.danger-warning {
  margin: 0 0 2rem;
  padding: 1rem 1.25rem;
  border: 1px solid #b9ad9d;
  border-left: 4px solid #7a1f1f;
  border-radius: 7px;
  background: #e9e0d2;
}

.danger-warning p { margin: 0.4em 0; }

.tab-media-entry {
  margin-bottom: 1.5em;
}

.tab-media-entry h3 {
  margin-bottom: 0.4em;
}

.tab-media-entry h3 a.entry-anchor {
  color: inherit;
  text-decoration: none;
}

.tab-media-entry h3 a.entry-anchor:hover {
  text-decoration: underline;
}

.tab-media-entry h3 .entry-copy {
  margin-left: 0.4em;
  padding: 0.1em 0.2em;
  border: none;
  background: none;
  color: inherit;
  opacity: 0.5;
  cursor: pointer;
  font-size: inherit;
  line-height: 1;
  vertical-align: baseline;
}

.tab-media-entry h3 .entry-copy:hover,
.tab-media-entry h3 .entry-copy:focus-visible {
  opacity: 1;
}

.tab-media-links {
  display: flex;
  gap: 1.25em;
  flex-wrap: wrap;
}
</style>

<link rel="icon" href="/favicon.ico" sizes="any">

<h1 style="text-align: center">Danger</h1>

<div class="danger-warning" role="note">
  <p><strong>Content warning.</strong></p>
  <p>
    The essays on this page are first-person accounts of severe real experiences,
    including sexual violence. They are detailed and explicit.
  </p>
  <p>
    If you need support, in the US you can call or text 988, or reach RAINN at 1-800-656-4673.
  </p>
</div>

<p>
  Web Page links will open the essay in a new tab.<br>
  PDF links will open in a new tab and attempt to invoke your browser's PDF reader extension, if configured.<br>
  TXT links will open as plain text in a new tab.
</p>

<div id="danger-list">
  <p>No essays yet.</p>
</div>

<footer class="publication-license" aria-labelledby="web-content-license">
  <hr />
  <h2 id="web-content-license" style="text-align: center">Web Content License</h2>
  <p>© 2026 Severin Aequus. All rights reserved.</p>
  <p>This page is licensed under the Creative Commons<br />
  Attribution–NonCommercial–NoDerivatives 4.0 International License.</p>
  <p>You are free to share this page with attribution.<br />
  You may not modify, remix, or use this material commercially.</p>
  <p>License details: https://creativecommons.org/licenses/by-nc-nd/4.0/</p>
</footer>

{% assign danger_files = site.static_files | where_exp: "f", "f.path contains '/danger-docs/'" %}
{% assign danger_pages = site.pages | where_exp: "p", "p.path contains 'danger-docs/'" %}
<script>
(function () {
  'use strict';

  // Filled in by Jekyll at build time from the files in danger-docs/:
  // static files (.pdf, .txt) plus the .md essays Jekyll renders as pages.
  // No GitHub release is used, so nothing about these essays appears on
  // the repo's Releases page or in the main site's API calls.
  const files = [{% for f in danger_files %}{{ f.name | jsonify }}, {% endfor %}{% for p in danger_pages %}{{ p.name | jsonify }}, {% endfor %}];

  const container = document.getElementById('danger-list');

  // One entry per basename. When several formats share a name, the
  // earliest type in this list wins: Markdown, then PDF, then TXT.
  // Jekyll renders each .md essay to a themed .html page, which is what
  // its link opens.
  const TYPES = [
    { ext: '.md',  label: '[Web Page]', href: base => `${base}.html` },
    { ext: '.pdf', label: '[PDF]' },
    { ext: '.txt', label: '[TXT]' }
  ];
  const rank = name => TYPES.findIndex(t => name.toLowerCase().endsWith(t.ext));

  const documents = new Map();
  for (const name of files) {
    if (rank(name) === -1) continue;
    const key = name.replace(/\.[^.]+$/, '').toLowerCase();
    const existing = documents.get(key);
    if (!existing || rank(name) < rank(existing)) {
      documents.set(key, name);
    }
  }

  const docs = Array.from(documents.values()).sort((a, b) =>
    displayTitle(a).localeCompare(displayTitle(b), undefined, { numeric: true, sensitivity: 'base' })
  );

  if (docs.length === 0) return;

  container.innerHTML = '';

  const COPY_ICON = '<svg viewBox="0 0 24 24" width="0.8em" height="0.8em" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><rect x="9" y="9" width="13" height="13" rx="2"/><path d="M5 15H4a2 2 0 0 1-2-2V4a2 2 0 0 1 2-2h9a2 2 0 0 1 2 2v1"/></svg>';
  const CHECK_ICON = '<svg viewBox="0 0 24 24" width="0.8em" height="0.8em" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>';

  for (const name of docs) {
    const baseName = name.replace(/\.[^.]+$/, '');

    const entry = document.createElement('div');
    entry.className = 'tab-media-entry';
    entry.id = entryId(baseName);

    const title = document.createElement('h3');
    title.appendChild(titleWithLinks(entry.id, displayTitle(name)));
    entry.appendChild(title);

    const links = document.createElement('div');
    links.className = 'tab-media-links';

    const link = document.createElement('a');
    const type = TYPES[rank(name)];
    const target = type.href ? type.href(baseName) : name;
    link.href = `/danger-docs/${encodeURIComponent(target)}`;
    link.textContent = type.label;
    link.target = '_blank';
    link.rel = 'noopener';
    links.appendChild(link);

    entry.appendChild(links);
    container.appendChild(entry);
  }

  // Entries are built after the browser's initial jump to the fragment.
  let id;
  try { id = decodeURIComponent(window.location.hash.slice(1)); } catch (_) {}
  const target = id && document.getElementById(id);
  if (target) target.scrollIntoView();

  function displayTitle(filename) {
    return filename.replace(/\.[^.]+$/, '').replace(/_/g, ' ');
  }

  // Same scheme as the main site, e.g. /danger/#danger-name-of-essay.
  function entryId(baseName) {
    const slug = baseName.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-|-$/g, '');
    let id = `danger-${slug}`;
    for (let n = 2; document.getElementById(id); n++) id = `danger-${slug}-${n}`;
    return id;
  }

  function titleWithLinks(id, text) {
    const frag = document.createDocumentFragment();

    const a = document.createElement('a');
    a.className = 'entry-anchor';
    a.href = `#${id}`;
    a.textContent = text;
    frag.appendChild(a);

    const button = document.createElement('button');
    button.type = 'button';
    button.className = 'entry-copy';
    button.title = 'Copy link to this essay';
    button.setAttribute('aria-label', `Copy link to ${text}`);
    button.innerHTML = COPY_ICON;
    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(a.href);
        button.innerHTML = CHECK_ICON;
        button.title = 'Link copied';
        setTimeout(() => {
          button.innerHTML = COPY_ICON;
          button.title = 'Copy link to this essay';
        }, 1500);
      } catch (_) {
        window.prompt('Copy this link:', a.href);
      }
    });
    frag.appendChild(button);

    return frag;
  }
})();
</script>
