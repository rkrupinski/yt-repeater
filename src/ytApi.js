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
  return new Promise((resolve, reject) => {
    window.onYouTubeIframeAPIReady = function onYouTubeIframeAPIReady() {
      return new YT.Player(container, {
        width,
        height,
        playerVars: {
          autoplay: 1,
          controls: 1,
        },
        events: {
          onReady(e) {
            resolve({
              player: e.target,
              api: window.YT,
            });
          },
          onError(e) {
            reject(e.data);
          },
        },
      });
    };

    appendScript();
  });
}
