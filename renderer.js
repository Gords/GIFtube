const form = document.getElementById('conversion-form');
const statusElement = document.getElementById('status');
const resultGifElement = document.getElementById('result-gif');

form.addEventListener('submit', (event) => {
  event.preventDefault();

  const formData = new FormData(form);
  const data = {
    youtubeUrl: formData.get('youtube-url'),
    startTime: formData.get('start-time'),
    duration: formData.get('duration'),
    resolution: formData.get('resolution'),
    aspectRatio: formData.get('aspect-ratio'),
    fps: formData.get('fps'),
    quality: formData.get('quality'),
    outputFilename: formData.get('output-filename'),
  };

  statusElement.textContent = 'Conversion in progress...';
  resultGifElement.style.display = 'none';
  window.electronAPI.send('toMain', data);
});

window.electronAPI.receive('fromMain', (data) => {
    if (data.success) {
        statusElement.textContent = `Conversion successful! GIF saved to: ${data.filePath}`;
        // Add a cache-busting query string to the image URL
        resultGifElement.src = `${data.filePath}?t=${new Date().getTime()}`;
        resultGifElement.style.display = 'block';
    } else {
        statusElement.textContent = `Conversion failed: ${data.error}`;
    }
});