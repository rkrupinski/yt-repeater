function appendScript() {
  const script = document.createElement('script');
  const firstScript = document.querySelectorAll('script')[0];

  script.src = 'https://www.youtube.com/iframe_api';
  firstScript.parentNode.insertBefore(script, firstScript);
}

export default function init(container, {
  width = 640,
  height = 480,
} = {}) {
  return new Promise(function (resolve, reject) {
    window.onYouTubeIframeAPIReady = function () {
      new YT.Player(container, {
        width,
        height,
        playerVars: {
          autoplay: 1,
          controls: 1,
        },
        events: {
          onReady: function (e) {
            resolve({
              player: e.target,
              api: window.YT,
            });
          },
          onError: function (e) {
            reject(e.data);
          },
        },
      });
    };

    appendScript();
  });
}