function appendScript() {
  const script = document.createElement('script');
  const firstScript = document.querySelectorAll('script')[0];

  script.src = 'https://cdnjs.cloudflare.com/ajax/libs/webcomponentsjs/1.0.14/webcomponents-sd-ce.js';
  firstScript.parentNode.insertBefore(script, firstScript);
}

export default function polyfill() {
  return new Promise((resolve) => { // eslint-disable-line consistent-return
    if ('registerElement' in document) {
      return resolve();
    }

    window.addEventListener('WebComponentsReady', resolve);

    appendScript();
  });
}
