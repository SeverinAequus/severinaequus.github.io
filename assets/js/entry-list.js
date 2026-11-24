// Browser-side behavior for pages built with _layouts/list.html. The entries
// themselves are already in the page; this adds the filter box, the copy-link
// buttons, and video/podcast links from the page's GitHub release.
(function () {
  'use strict';

  const list = document.querySelector('.entry-list');
  if (!list) return;

  const entries = Array.from(list.querySelectorAll('.entry'));
  const empty = list.querySelector('.entry-empty');
  const filterBox = document.querySelector('.entry-filter');
  const input = document.getElementById('entry-filter-input');
  const status = filterBox.querySelector('.entry-filter-status');

  //
  // Title filter: every word typed must appear somewhere in the title.
  //

  const titles = new Map(entries.map(entry =>
    [entry, entry.querySelector('.entry-anchor').textContent.toLowerCase()]));

  function applyFilter() {
    const words = input.value.toLowerCase().split(/\s+/).filter(Boolean);
    let shown = 0;
    for (const entry of entries) {
      const match = words.every(word => titles.get(entry).includes(word));
      entry.hidden = !match;
      if (match) shown++;
    }
    empty.hidden = shown !== 0;
    status.textContent = words.length ? `Showing ${shown} of ${entries.length}` : '';
  }

  filterBox.hidden = false;
  input.addEventListener('input', applyFilter);
  applyFilter();

  //
  // Direct links (#slug). The browser scrolls to the entry on its own; if the
  // filter is hiding it, clear the filter first.
  //

  function linkedEntry() {
    let id;
    try { id = decodeURIComponent(window.location.hash.slice(1)); }
    catch (_) { return null; }
    const target = id && document.getElementById(id);
    return target && list.contains(target) ? target : null;
  }

  window.addEventListener('hashchange', () => {
    const target = linkedEntry();
    if (target && target.hidden) {
      input.value = '';
      applyFilter();
      target.scrollIntoView();
    }
  });

  //
  // Copy-link buttons.
  //

  const CHECK_ICON = '<svg viewBox="0 0 24 24" width="0.8em" height="0.8em" aria-hidden="true" fill="none" stroke="currentColor" stroke-width="2" stroke-linecap="round" stroke-linejoin="round"><path d="M20 6 9 17l-5-5"/></svg>';

  for (const entry of entries) {
    const anchor = entry.querySelector('.entry-anchor');
    const button = entry.querySelector('.entry-copy');
    const copyIcon = button.innerHTML;
    button.hidden = false;
    button.addEventListener('click', async () => {
      try {
        await navigator.clipboard.writeText(anchor.href);
        button.innerHTML = CHECK_ICON;
        button.title = 'Link copied';
        setTimeout(() => {
          button.innerHTML = copyIcon;
          button.title = 'Copy link to this essay';
        }, 1500);
      } catch (_) {
        window.prompt('Copy this link:', anchor.href);
      }
    });
  }

  //
  // Video and podcast links: the release tagged with this page's collection
  // name holds .mp4 (video) and .m4a (podcast) files named like the entry.
  //

  const { repo, release } = list.dataset;
  if (!repo || !release) return;

  fetch(`https://api.github.com/repos/${repo}/releases/tags/${encodeURIComponent(release)}`)
    .then(response => {
      if (response.status === 404) return null; // No release: no media.
      if (!response.ok) throw new Error(`GitHub API returned ${response.status}`);
      return response.json();
    })
    .then(data => {
      if (!data) return;

      const assets = new Map();
      for (const asset of data.assets) assets.set(asset.name.toLowerCase(), asset);

      const target = linkedEntry();
      const keepInView = target &&
        Math.abs(target.getBoundingClientRect().top) < window.innerHeight;

      for (const entry of entries) {
        const base = entry.dataset.base.toLowerCase();
        const title = entry.querySelector('.entry-anchor').textContent;
        const links = entry.querySelector('.entry-links');
        const video = assets.get(`${base}.mp4`);
        const audio = assets.get(`${base}.m4a`);
        if (video) addPlayerLink(links, '[Explainer Video]', video, 'video', title);
        if (audio) addPlayerLink(links, '[Deep Dive Podcast]', audio, 'audio', title);
      }

      // New links can wrap lines and push the linked entry down the page.
      if (keepInView) target.scrollIntoView();
    })
    .catch(error => {
      console.error(error);
      const note = document.createElement('p');
      note.className = 'entry-media-error';
      note.textContent = 'Video and podcast links could not be loaded right now. Try again later.';
      filterBox.after(note);
    });

  function addPlayerLink(parent, text, asset, type, title) {
    const link = document.createElement('a');
    link.href = '/player.html' +
      `?type=${type}` +
      `&src=${encodeURIComponent(asset.browser_download_url)}` +
      `&title=${encodeURIComponent(title)}`;
    link.textContent = text;
    link.target = '_blank';
    link.rel = 'noopener';
    parent.appendChild(link);
  }
})();
