import localforage from 'localforage';

const DB_NAME = 'YT_REPEATER';
const STORE_NAME = 'HISTORY';
const ENTRIES_KEY = 'ENTRIES';
const HISTORY_SIZE = 10;

async function getEntries() {
  const entries = await localforage.getItem(ENTRIES_KEY);

  return entries || [];
}

export function initStorage() {
  localforage.config({
    name: DB_NAME,
    storeName: STORE_NAME,
  });

  return localforage.ready();
}

export async function initHistory(writePort, readPort, clearPort) {
  readPort.send(await getEntries());

  writePort.subscribe(async (newEntry) => {
    const { videoId } = newEntry;
    const entries = await getEntries();
    const currentIndex = entries.findIndex(entry => entry.videoId === videoId);

    if (currentIndex !== -1) {
      entries.splice(currentIndex, 1);
    }

    entries.unshift(newEntry);
    entries.splice(HISTORY_SIZE);

    await localforage.setItem(ENTRIES_KEY, entries);

    readPort.send(await getEntries());
  });

  clearPort.subscribe(async () => {
    await localforage.setItem(ENTRIES_KEY, []);

    readPort.send(await getEntries());
  });
}
