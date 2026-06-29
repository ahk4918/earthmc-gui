const { app, BrowserWindow, ipcMain, shell, session } = require('electron');
const { autoUpdater } = require('electron-updater');
const log = require('electron-log');
const path = require('path');

let mainWindow;

// Wire auto-updater to electron-log so we can see what's happening
autoUpdater.logger = log;
autoUpdater.logger.transports.file.level = 'info';

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    icon: path.join(__dirname, 'assets/icon.png'),
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      sandbox: true,
    }
  });

  // Set CSP via response headers (correct way)
  session.defaultSession.webRequest.onHeadersReceived((details, callback) => {
    callback({
      responseHeaders: {
        ...details.responseHeaders,
        'Content-Security-Policy': [
          "default-src 'self'; " +
          "script-src 'self' 'unsafe-inline'; " +
          "connect-src https://api.earthmc.net https://api.github.com; " +
          "img-src 'self' https://mc-heads.net data:; " +
          "style-src 'self' 'unsafe-inline' https://fonts.googleapis.com; " +
          "font-src https://fonts.gstatic.com;"
        ]
      }
    });
  });

  mainWindow.loadFile('renderer/index.html');

  mainWindow.webContents.on('did-finish-load', () => {
    log.info('Window loaded, checking for updates...');
    autoUpdater.checkForUpdatesAndNotify();
  });

  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }
}

app.on('ready', createWindow);

// Auto updater events
autoUpdater.on('checking-for-update', () => log.info('Checking for update...'));
autoUpdater.on('update-available', (info) => {
  log.info('Update available:', info.version);
  mainWindow.webContents.send('update-available', info.version);
});
autoUpdater.on('update-not-available', () => log.info('Already up to date.'));
autoUpdater.on('update-downloaded', (info) => {
  log.info('Update downloaded:', info.version);
  mainWindow.webContents.send('update-ready', info.version);
});
autoUpdater.on('error', (err) => {
  log.error('Auto updater error:', err);
});

// IPC
ipcMain.on('install-update', () => autoUpdater.quitAndInstall());
ipcMain.on('open-external', (_, url) => shell.openExternal(url));

app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') app.quit();
});

app.on('activate', () => {
  if (mainWindow === null) createWindow();
});