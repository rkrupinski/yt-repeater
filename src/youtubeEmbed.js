import init from 'ytApi';
import { deferred } from 'utils';
import debounce from 'lodash.debounce';

const embedData = new WeakMap();

export default function thunk() {
  return class YouTubeEmbed extends HTMLElement {
    static get observedAttributes() {
      return [
        'v',
        'start',
        'end',
      ];
    }

    constructor() {
      super();

      embedData.set(this, {
        playerDefer: deferred(),
        playing: null,
        metaSent: false,
      });

      this.loadVideo = debounce(this.loadVideo, 100);
    }

    async connectedCallback() {
      const data = embedData.get(this);
      const shadow = this.attachShadow({ mode: 'closed' });
      const container = document.createElement('div');

      shadow.appendChild(container);

      const { player, api } = await init(container);

      this.fire('yt-api-ready');

      player.addEventListener(
        'onStateChange',
        this.onStateChange.bind(this),
      );

      data.playerDefer.resolve({ player, api });
    }

    attributeChangedCallback(name, _, newValue) {
      if (!newValue) {
        return;
      }

      const data = embedData.get(this);

      switch (name) {
        case 'v':
          data.playing = {
            videoId: newValue,
          };

          data.metaSent = false;
          break;

        case 'start':
        case 'end':
          {
            const num = Number(newValue);

            if (Number.isNaN(num)) {
              return;
            }

            data.playing = Object.assign({}, data.playing, {
              [`${name}Seconds`]: num,
            });
          }
          break;

        default:
          break;
      }

      this.loadVideo();
    }

    async onStateChange({ data: playerState }) {
      const data = embedData.get(this);
      const { player, api } = await data.playerDefer.promise;

      switch (playerState) {
        case api.PlayerState.PLAYING:
          if (!data.metaSent) {
            const { title } = player.getVideoData();
            const duration = Math.round(player.getDuration());

            this.fire('video-meta', {
              detail: {
                title,
                duration,
              },
            });

            data.metaSent = true;
          }
          break;

        case api.PlayerState.ENDED:
          this.repeat();
          break;

        default:
          break;
      }
    }

    async loadVideo() {
      const data = embedData.get(this);
      const { player } = await data.playerDefer.promise;

      player.loadVideoById(data.playing);
    }

    async repeat() {
      const data = embedData.get(this);
      const { player } = await data.playerDefer.promise;

      player.seekTo(data.playing.startSeconds || 0);
    }

    fire(evt, data) {
      this.dispatchEvent(new CustomEvent(evt, Object.assign({
        bubbles: true,
      }, data)));
    }
  };
}
