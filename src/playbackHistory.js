import localforage from 'localforage';

const DB_NAME = 'YT_REPEATER';
const STORE_NAME = 'HISTORY';
const ENTRIES_KEY = 'ENTRIES';
const HISTORY_SIZE = 10;

export function initStorage() {
  localforage.config({
    name: DB_NAME,
    storeName: STORE_NAME,
  });

  return localforage.ready();
}

export function initHistory(writePort, readPort) {
  writePort.subscribe(async (newEntry) => {
    const { videoId } = newEntry;
    const entries = await localforage.getItem(ENTRIES_KEY) || [];
    const currentIndex = entries.findIndex(entry => entry.videoId === videoId);

    if (currentIndex !== -1) {
      entries.splice(currentIndex, 1);
    }

    entries.unshift(newEntry);
    entries.splice(HISTORY_SIZE);

    localforage.setItem(ENTRIES_KEY, entries);

    readPort.send(entries);
  });
}
