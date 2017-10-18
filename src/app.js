import 'Stylesheets';
import polyfill from 'webcomponents';
import thunk from 'youtubeEmbed';
import { Main } from 'Main';

polyfill()
  .then(function () {
    customElements.define('youtube-embed', thunk());

    Main.fullscreen();
  });
