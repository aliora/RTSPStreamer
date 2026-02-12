const express = require('express');
const { spawn } = require('child_process');
const fs = require('fs');
const path = require('path');

const app = express();
const PORT = 3000;

// Aktif akışları takip et
const activeStreams = new Map();
const streamConfigs = [];

app.use(express.json());
app.use(express.static('public'));
app.use('/streams', express.static('streams'));

// RTSP akışı ekle
app.post('/api/streams', (req, res) => {
    const { rtspUrl, name } = req.body;
    
    if (!rtspUrl) {
        return res.status(400).json({ error: 'RTSP URL gerekli' });
    }

    if (streamConfigs.length >= 4) {
        return res.status(400).json({ error: 'Maksimum 4 akış eklenebilir' });
    }

    const streamId = `stream_${Date.now()}`;
    const streamDir = path.join(__dirname, 'streams', streamId);

    // Akış dizini oluştur
    if (!fs.existsSync(streamDir)) {
        fs.mkdirSync(streamDir, { recursive: true });
    }

    const streamConfig = {
        id: streamId,
        name: name || `Akış ${streamConfigs.length + 1}`,
        rtspUrl,
        hlsUrl: `/streams/${streamId}/playlist.m3u8`,
        active: false
    };

    streamConfigs.push(streamConfig);
    startStream(streamConfig);

    res.json(streamConfig);
});

// Akışları listele
app.get('/api/streams', (req, res) => {
    res.json(streamConfigs);
});

// Akışı sil
app.delete('/api/streams/:id', (req, res) => {
    const { id } = req.params;
    const index = streamConfigs.findIndex(s => s.id === id);

    if (index === -1) {
        return res.status(404).json({ error: 'Akış bulunamadı' });
    }

    stopStream(id);
    streamConfigs.splice(index, 1);

    // Akış dizinini temizle
    const streamDir = path.join(__dirname, 'streams', id);
    if (fs.existsSync(streamDir)) {
        fs.rmSync(streamDir, { recursive: true, force: true });
    }

    res.json({ success: true });
});

// RTSP akışını HLS'e dönüştür
function startStream(config) {
    const streamDir = path.join(__dirname, 'streams', config.id);
    const playlistPath = path.join(streamDir, 'playlist.m3u8');

    // FFmpeg ile RTSP'den HLS'e dönüştür
    const ffmpeg = spawn('ffmpeg', [
        '-rtsp_transport', 'tcp',
        '-i', config.rtspUrl,
        '-c:v', 'copy',
        '-c:a', 'aac',
        '-f', 'hls',
        '-hls_time', '2',
        '-hls_list_size', '3',
        '-hls_flags', 'delete_segments+append_list',
        '-hls_segment_filename', path.join(streamDir, 'segment_%03d.ts'),
        playlistPath
    ]);

    ffmpeg.stderr.on('data', (data) => {
        console.log(`[${config.id}] ${data}`);
    });

    ffmpeg.on('close', (code) => {
        console.log(`[${config.id}] FFmpeg kapatıldı. Kod: ${code}`);
        config.active = false;
        activeStreams.delete(config.id);
    });

    ffmpeg.on('error', (err) => {
        console.error(`[${config.id}] FFmpeg hatası:`, err);
        config.active = false;
    });

    activeStreams.set(config.id, ffmpeg);
    config.active = true;
}

// Akışı durdur
function stopStream(streamId) {
    const ffmpeg = activeStreams.get(streamId);
    if (ffmpeg) {
        ffmpeg.kill('SIGTERM');
        activeStreams.delete(streamId);
    }
}

// Uygulama kapanırken tüm akışları durdur
process.on('SIGINT', () => {
    console.log('Sunucu kapatılıyor...');
    activeStreams.forEach((ffmpeg, id) => {
        ffmpeg.kill('SIGTERM');
    });
    process.exit(0);
});

app.listen(PORT, () => {
    console.log(`RTSP Web Viewer sunucusu http://localhost:${PORT} adresinde çalışıyor`);
});
