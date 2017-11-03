import localforage from 'localforage';

const dbName = 'yt-repeater';
const entriesKey = 'entries';
const historySize = 10;

export function initStorage() {
  return localforage.ready()
    .then(() => {
      localforage.config({
        name: dbName,
        storeName: dbName,
      });
    });
}

export function initHistory(writePort, readPort) {
  writePort.subscribe(async (newEntry) => {
    const { videoId } = newEntry;
    const entries = await localforage.getItem(entriesKey) || [];
    const currentIndex = entries.findIndex(entry => entry.videoId === videoId);

    if (currentIndex !== -1) {
      entries.splice(currentIndex, 1);
    }

    entries.unshift(newEntry);
    entries.splice(historySize);

    localforage.setItem(entriesKey, entries);

    readPort.send(entries);
  });
}
