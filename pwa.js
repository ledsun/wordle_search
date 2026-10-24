if ('serviceWorker' in navigator) {
  const status = document.getElementById('offline-status');
  status.textContent = 'Preparing offline search…';
  navigator.serviceWorker.register('./sw.js', { updateViaCache: 'none' })
    .then(async (registration) => {
      const showUpdate = () => {
        status.textContent = 'Update ready. Close all Wordle Search windows and reopen to update.';
      };
      if (registration.waiting) showUpdate();
      const watchInstallation = (worker) => {
        worker.addEventListener('statechange', () => {
          if (worker.state === 'installed' && registration.waiting) showUpdate();
          if (worker.state === 'redundant' && !registration.active) {
            status.textContent = 'Offline setup failed. Reopen while online to retry.';
          }
        });
      };
      if (registration.installing) watchInstallation(registration.installing);
      registration.addEventListener('updatefound', () => {
        watchInstallation(registration.installing);
      });
      await navigator.serviceWorker.ready;
      if (registration.waiting) showUpdate();
      else status.textContent = 'Ready for offline search';
    })
    .catch((error) => {
      status.textContent = 'Offline setup failed. Reopen while online to retry.';
      console.error('Service worker registration failed:', error);
    });
}
