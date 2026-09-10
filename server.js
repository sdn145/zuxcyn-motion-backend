const express = require('express');
const ffmpeg = require('fluent-ffmpeg');
const path = require('path');
const app = express();

app.use(express.json());

// Endpoint untuk memproses video dengan efek (Keyframe, Shake, Glow/Color, Transition)
app.post('/api/render', (req, res) => {
  const { inputPath, outputPath, effect } = req.body;

  let command = ffmpeg(inputPath);

  // Penerapan logika efek video dasar Alight Motion
  if (effect === 'glow') {
    command.videoFilters('eq=brightness=0.1:contrast=1.3:saturation=1.5');
  } else if (effect === 'slowmo') {
    command.videoFilters('setpts=2.0*PTS');
  } else if (effect === 'blur_shake') {
    command.videoFilters('boxblur=5:1');
  }

  command
    .output(outputPath)
    .on('end', () => {
      res.json({ status: 'success', message: 'Rendering Zuxcyn Motion Selesai', file: outputPath });
    })
    .on('error', (err) => {
      res.status(500).json({ status: 'error', message: err.message });
    })
    .run();
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Server Zuxcyn Motion berjalan pada port ${PORT}`);
});
