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

    const { addToHistory, readHistory, clearHistory } = Main.fullscreen().ports;

    initHistory(addToHistory, readHistory, clearHistory);
  });
