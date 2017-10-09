import { Main } from 'Main';
import init from 'ytApi';
import 'Stylesheets';

const app = Main.fullscreen();

init('player')
    .then(function ({ player, api }) {
      let playing = null;

      player.addEventListener('onStateChange', onStateChange);

      app.ports.apiReady.send(true);

      app.ports.videoId.subscribe(function (id) {
        playing = null;

        player.loadVideoById(id);
      });

      app.ports.range.subscribe(function ({ start, end }) {
        const { video_id: id } = player.getVideoData();

        playing = { id, start, end };

        loadWithRange(playing);
      });

      function onStateChange({ data }) {
        switch (data) {
          case api.PlayerState.PLAYING:
            {
              const duration = player.getDuration();

              if (!playing) {
                app.ports.videoMeta.send({
                  duration,
                });
              }
            }
            break;

          case api.PlayerState.ENDED:
            {
              const { id, start, end } = playing;

              loadWithRange(playing);
            }
            break;
        }
      }

      function loadWithRange({ id, start, end }) {
        player.loadVideoById({
          videoId: id,
          startSeconds: start,
          endSeconds: end,
        });
      }
    });
