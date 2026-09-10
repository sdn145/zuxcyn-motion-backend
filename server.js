const express = require('express');
const ffmpeg = require('fluent-ffmpeg');
const app = express();

app.use(express.json());

app.post('/api/render', (req, res) => {
  const { inputPath, outputPath, effect } = req.body;

  if (!inputPath || !outputPath) {
    return res.status(400).json({ status: 'error', message: 'inputPath dan outputPath wajib diisi' });
  }

  let command = ffmpeg(inputPath);

  // Preset Efek Zuxcyn Motion
  switch (effect) {
    case 'shake':
      // Kinetic Shake effect
      command.videoFilters('crop=in_w*0.9:in_h*0.9,scale=iw:ih,rotate=0.05*sin(2*PI*t*5):ow=iw:oh=ih');
      break;
    case 'velocity':
      // Smooth speed ramps
      command.videoFilters('setpts=0.5*PTS');
      break;
    case 'tvrood_cc':
      // High-contrast, sharp color grading & deep saturation
      command.videoFilters('eq=contrast=1.35:brightness=-0.05:saturation=1.6,unsharp=5:5:1.5:5:5:0.0');
      break;
    case 'glow':
      // Soft glow / highlight boost
      command.videoFilters('eq=brightness=0.08:contrast=1.25:saturation=1.3');
      break;
    case 'flash':
      // White flash intro effect
      command.videoFilters("drawbox=y=0:color=white@'if(lt(t,0.15),1-t/0.15,0)':t=fill");
      break;
    default:
      break;
  }

  command
    .output(outputPath)
    .on('end', () => {
      res.json({ status: 'success', message: `Render efek '${effect || 'none'}' selesai`, file: outputPath });
    })
    .on('error', (err) => {
      res.status(500).json({ status: 'error', message: err.message });
    })
    .run();
});

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => {
  console.log(`Zuxcyn Motion Backend aktif di port ${PORT}`);
});
