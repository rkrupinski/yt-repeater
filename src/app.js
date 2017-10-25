import 'Stylesheets';
import polyfill from 'webcomponents';
import thunk from 'youtubeEmbed';
import { Main } from 'Main';

polyfill()
  .then(() => {
    customElements.define('youtube-embed', thunk());

    Main.fullscreen();
  });
