import { Main } from 'Main';
import init from 'ytApi';
import 'Stylesheets';

const app = Main.embed(document.querySelector('#controls'));

init('player')
    .then(function ({ player, api }) {
      player.addEventListener('onStateChange',
          onStateChange.bind(null, player, api));

      app.ports.apiReady.send(true);

      app.ports.videoId.subscribe(function (id) {
        player.loadVideoById(id);
      });
    });


function onStateChange(player, api, { data }) {
  switch (data) {
    case api.PlayerState.PLAYING:
      {
        const duration = player.getDuration();

        app.ports.videoMeta.send({
          duration,
        });
      }
      break;
  }
}
