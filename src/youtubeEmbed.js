import init from 'ytApi';
import { deferred } from 'utils';

const embedData = new WeakMap();

export default function thunk() {
  return class YouTubeEmbed extends HTMLElement {
    static get observedAttributes() {
      return [
        'video-id',
        'range',
      ];
    }

    constructor() {
      super();

      embedData.set(this, {
        playerDefer: deferred(),
        video: null,
      });
    }

    async connectedCallback() {
      const data = embedData.get(this);
      const shadow = this.attachShadow({ mode: 'closed' });
      const container = document.createElement('div');

      shadow.appendChild(container);

      const  { player, api } = await init(container);

      this._fire('yt-api-ready');

      player.addEventListener('onStateChange',
          this._onStateChange.bind(this));

      data.playerDefer.resolve({ player, api });
    }

    async attributeChangedCallback(name, _, newValue) {
      const data = embedData.get(this);
      const { player } = await data.playerDefer.promise;

      switch (name) {
        case 'video-id':
          if (newValue) {
            data.video = null;

            player.loadVideoById(newValue);
          }
          break;

        case 'range':
          if (newValue) {
            const [startSeconds, endSeconds] = newValue.split('-');
            const { video_id: videoId } = player.getVideoData();
            const video = { videoId, startSeconds, endSeconds };

            data.video = video;

            player.loadVideoById(video);
          }
          break;
      }
    }

    async _onStateChange({ data: playerState }) {
      const data = embedData.get(this);
      const { player, api } = await data.playerDefer.promise;

      switch (playerState) {
        case api.PlayerState.PLAYING:
          if (!data.video) {
            this._fire('video-meta', {
              detail: player.getDuration(),
            });
          }
          break;

        case api.PlayerState.ENDED:
          player.loadVideoById(data.video);
          break;
      }
    }

    _fire(evt, data) {
      this.dispatchEvent(new CustomEvent(evt, Object.assign({
        bubbles: true,
      }, data)));
    }
  };
}
