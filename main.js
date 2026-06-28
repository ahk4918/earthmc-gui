const { app, BrowserWindow, ipcMain, shell } = require('electron');
const { autoUpdater } = require('electron-updater');
const path = require('path');

let mainWindow;

function createWindow() {
  mainWindow = new BrowserWindow({
    width: 1200,
    height: 800,
    icon: path.join(__dirname, 'assets/icon.png'), // Default icon (PNG)
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      nodeIntegration: false,
      contextIsolation: true,
      enableRemoteModule: false,
      sandbox: true,
      contentSecurityPolicy: `
        default-src 'self';
        script-src 'self' 'unsafe-inline';
        connect-src https://api.earthmc.net;
        img-src 'self' https://mc-heads.net;
        style-src 'self' 'unsafe-inline' https://fonts.googleapis.com;
        font-src https://fonts.gstatic.com;
      `
    }
  });

  mainWindow.loadFile('renderer/index.html');

  // Check for updates after window loads
  mainWindow.webContents.on('did-finish-load', () => {
    autoUpdater.checkForUpdatesAndNotify();
  });

  // Open DevTools in development
  if (process.env.NODE_ENV === 'development') {
    mainWindow.webContents.openDevTools();
  }
}

app.on('ready', createWindow);

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

// Window lifecycle
app.on('window-all-closed', () => {
  if (process.platform !== 'darwin') {
    app.quit();
  }
});

app.on('activate', () => {
  if (mainWindow === null) {
    createWindow();
  }
});