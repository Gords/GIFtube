const { app, BrowserWindow, ipcMain } = require('electron');
const path = require('path');
const fs = require('fs');
const ytdl = require('ytdl-core');
const ffmpeg = require('fluent-ffmpeg');
const ffmpegInstaller = require('@ffmpeg-installer/ffmpeg');

// Set the path for ffmpeg
ffmpeg.setFfmpegPath(ffmpegInstaller.path.replace('app.asar', 'app.asar.unpacked'));

function createWindow() {
  const mainWindow = new BrowserWindow({
    width: 800,
    height: 900,
    webPreferences: {
      preload: path.join(__dirname, 'preload.js'),
      contextIsolation: true,
      nodeIntegration: false,
    },
  });

  mainWindow.loadFile('index.html');
}

app.whenReady().then(() => {
  createWindow();

  app.on('activate', function () {
    if (BrowserWindow.getAllWindows().length === 0) createWindow();
  });
});

app.on('window-all-closed', function () {
  if (process.platform !== 'darwin') app.quit();
});

ipcMain.on('toMain', async (event, data) => {
  const {
    youtubeUrl,
    startTime,
    duration,
    resolution,
    aspectRatio,
    fps,
    quality,
    outputFilename
  } = data;

  const downloadsPath = app.getPath('downloads');
  const outputPath = path.join(downloadsPath, outputFilename);

  try {
    if (!ytdl.validateURL(youtubeUrl)) {
        throw new Error('Invalid YouTube URL');
    }

    const videoStream = ytdl(youtubeUrl, { quality: 'highestvideo' });

    const [ar_w, ar_h] = aspectRatio.split(':').map(Number);

    // Using ffmpeg's two-pass method for higher quality GIFs
    const complexFilter = `fps=${fps},scale=-1:${resolution}:flags=lanczos,crop=ih*${ar_w}/${ar_h}:ih,split[s0][s1];[s0]palettegen=stats_mode=diff[p];[s1][p]paletteuse=dither=bayer:bayer_scale=5:diff_mode=rectangle`;

    ffmpeg(videoStream)
      .setStartTime(startTime)
      .setDuration(duration)
      .videoFilter(complexFilter)
      .toFormat('gif')
      .on('end', () => {
        event.sender.send('fromMain', { success: true, filePath: outputPath });
      })
      .on('error', (err) => {
        console.error(err);
        event.sender.send('fromMain', { success: false, error: err.message });
      })
      .save(outputPath);

  } catch (error) {
    console.error(error);
    event.sender.send('fromMain', { success: false, error: error.message });
  }
});