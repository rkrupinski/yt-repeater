import 'Stylesheets';
import polyfill from 'webcomponents';
import lazy from 'youtubeEmbed';
import { initStorage, initHistory } from 'playbackHistory';
import { Main } from 'Main';

Promise.all([
  polyfill(),
  initStorage(),
])
  .then(() => {
    customElements.define('youtube-embed', lazy());

    const { amendHistory, readHistory, clearHistory } = Main.fullscreen({
      baseUrl: window.location.pathname
        .replace(/^\//, '')
        .replace(/\/$/, ''),
    }).ports;

    initHistory(amendHistory, readHistory, clearHistory);
  });
