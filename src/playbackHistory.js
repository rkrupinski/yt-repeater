import localforage from 'localforage';

const dbName = 'YT_REPEATER_HISTORY';
const entriesKey = 'ENTRIES';
const historySize = 10;

export function initStorage() {
  return localforage.ready();
}

export function initHistory(writePort, readPort) {
  localforage.config({ name: dbName });

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
