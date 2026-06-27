const { app, BrowserWindow, ipcMain, shell } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');

let mainWindow;

app.on('ready', () => {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false
    }
  });

  mainWindow.loadFile('renderer/index.html');

  // Check for updates after window loads
  mainWindow.webContents.on('did-finish-load', () => {
    autoUpdater.checkForUpdatesAndNotify();
  });
});

// Auto updater events
autoUpdater.on('update-available', (info) => {
  mainWindow.webContents.send('update-available', info.version);
});

autoUpdater.on('update-downloaded', (info) => {
  mainWindow.webContents.send('update-ready', info.version);
});

autoUpdater.on('error', (err) => {
  console.error('Auto updater error:', err);
});

// IPC handlers
ipcMain.on('install-update', () => {
  autoUpdater.quitAndInstall();
});

ipcMain.on('open-external', (_, url) => {
  shell.openExternal(url);
});

app.on('window-all-closed', () => app.quit());