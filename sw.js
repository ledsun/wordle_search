// Bump APP_VERSION whenever local application files change.
const APP_VERSION = 'v2';
const APP_CACHE = `wordle-search-app-${APP_VERSION}`;
const DEPENDENCY_CACHE = 'wordle-search-dependencies-v1';
const RUBY_BASE = 'https://cdn.jsdelivr.net/npm/@ruby/head-wasm-wasi@2.10.1/dist/';
const DEPENDENCIES = [
  `${RUBY_BASE}browser.script.iife.js`,
  `${RUBY_BASE}ruby+stdlib.wasm`,
  'https://cdn.jsdelivr.net/npm/@tailwindcss/browser@4.3.3',
  'https://cdn.jsdelivr.net/gh/ledsun/orbital_ring@1.0.0/orbital_ring.rb',
];
const APP_FILES = [
  './', './index.html', './main.rb', './wordle_search.rb', './pwa.js',
  './manifest.webmanifest', './icons/icon.svg', './icons/icon-192.png', './icons/icon-512.png',
];
const FONT_STYLES = [
  'https://fonts.googleapis.com/css2?family=Poppins:wght@400;700&display=swap',
  'https://fonts.googleapis.com/css2?family=Noto+Sans+Mono:wght@500&display=swap',
];

self.addEventListener('install', (event) => {
  event.waitUntil((async () => {
    const dependencies = await caches.open(DEPENDENCY_CACHE);
    // Reuse immutable dependencies across app releases, especially the large WASM file.
    await Promise.all(DEPENDENCIES.map(async (url) => {
      if (!await dependencies.match(url)) await dependencies.add(url);
    }));
    // Fonts are optional: failure must not prevent offline search from being installed.
    try {
      for (const url of FONT_STYLES) {
        const response = await fetch(url);
        if (!response.ok) throw new Error('Font stylesheet unavailable');
        const css = await response.clone().text();
        await dependencies.put(url, response);
        const urls = [...css.matchAll(/url\((https:\/\/fonts\.gstatic\.com\/[^)]+)\)/g)].map((match) => match[1]);
        await Promise.all(urls.map(async (font) => {
          if (!await dependencies.match(font)) await dependencies.add(font);
        }));
      }
    } catch (error) {
      console.warn('Using fallback fonts offline:', error);
    }
    const app = await caches.open(APP_CACHE);
    await app.addAll(APP_FILES.map((url) => new Request(url, { cache: 'reload' })));
    // Keep the default waiting lifecycle so running pages keep a consistent release.
  })());
});

self.addEventListener('activate', (event) => {
  event.waitUntil((async () => {
    const keys = await caches.keys();
    await Promise.all(keys.filter((key) => key.startsWith('wordle-search-app-') && key !== APP_CACHE)
      .map((key) => caches.delete(key)));
    await self.clients.claim();
  })());
});

self.addEventListener('fetch', (event) => {
  const request = event.request;
  if (request.method !== 'GET') return;
  const url = new URL(request.url);
  const local = url.origin === self.location.origin;
  const dependency = DEPENDENCIES.includes(request.url) || FONT_STYLES.includes(request.url)
    || url.origin === 'https://fonts.gstatic.com';
  if (!local && !dependency) return;
  event.respondWith((async () => {
    const cache = await caches.open(local ? APP_CACHE : DEPENDENCY_CACHE);
    const cached = await cache.match(request);
    if (cached) return cached;
    if (request.mode === 'navigate') return cache.match('./index.html');
    const response = await fetch(request);
    if (dependency && response.ok) await cache.put(request, response.clone());
    return response;
  })());
});
