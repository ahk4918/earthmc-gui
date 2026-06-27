const { contextBridge, ipcRenderer } = require('electron');

contextBridge.exposeInMainWorld('api', {
  // EarthMC API
  fetchData: (endpoint, options) => {
    return fetch(`https://api.earthmc.net/v4/${endpoint}`, options)
      .then(r => {
        if (!r.ok) throw new Error(`HTTP error! status: ${r.status}`);
        return r.json();
      });
  },

  // Auto updater
  onUpdateAvailable: (cb) => ipcRenderer.on('update-available', (_, version) => cb(version)),
  onUpdateReady:     (cb) => ipcRenderer.on('update-ready',     (_, version) => cb(version)),
  installUpdate: () => ipcRenderer.send('install-update'),

  // Shell
  openExternal: (url) => ipcRenderer.send('open-external', url),
});