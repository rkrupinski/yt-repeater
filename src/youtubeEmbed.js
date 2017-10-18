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

    connectedCallback() {
      const { playerDefer } = embedData.get(this);

      const shadow = this.attachShadow({ mode: 'closed' });
      const container = document.createElement('div');

      playerDefer.promise.then(({ player, api }) => {
        this.dispatchEvent(new CustomEvent('yt-api-ready', {
          bubbles: true,
        }));

        player.addEventListener('onStateChange',
            this._onStateChange.bind(this));
      });

      shadow.appendChild(container);

      init(container).then(playerDefer.resolve);
    }

    attributeChangedCallback(name, _, newValue) {
      const { playerDefer } = embedData.get(this);

      playerDefer.promise.then(({ player, api }) => {
        switch (name) {
          case 'video-id':
            if (newValue) {
              embedData.get(this).video = null;

              player.loadVideoById(newValue);
            }
            break;

          case 'range':
            if (newValue) {
              const [startSeconds, endSeconds] = newValue.split('-');
              const { video_id: videoId } = player.getVideoData();
              const video = { videoId, startSeconds, endSeconds };

              embedData.get(this).video = video;

              player.loadVideoById(video);
            }
            break;
        }
      });
    }

    _onStateChange({ data }) {
      const { playerDefer , video } = embedData.get(this);

      playerDefer.promise.then(({ player, api }) => {
        switch (data) {
          case api.PlayerState.PLAYING:
            if (!video) {
              this.dispatchEvent(new CustomEvent('video-meta', {
                bubbles: true,
                detail: player.getDuration(),
              }));
            }
            break;

          case api.PlayerState.ENDED:
            player.loadVideoById(video);
            break;
        }
      });
    }
  };
}
