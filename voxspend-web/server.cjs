const express = require('express');
const https = require('https');
const path = require('path');
const fs = require('fs');

// 读 .env
const envPath = path.join(__dirname, '.env');
let API_KEY = process.env.VITE_AI_API_KEY || '';
if (!API_KEY && fs.existsSync(envPath)) {
  const line = fs.readFileSync(envPath, 'utf-8').split('\n').find(l => l.startsWith('VITE_AI_API_KEY='));
  if (line) API_KEY = line.split('=').slice(1).join('=').trim();
}

const app = express();
const PORT = process.env.PORT || 3000;
const TARGET_HOST = 'token.sensenova.cn';

app.use(express.json());

// API 代理
app.post('/api/v1/chat/completions', (req, res) => {
  if (!API_KEY) {
    return res.status(500).json({ error: 'VITE_AI_API_KEY 未配置' });
  }

  const body = JSON.stringify(req.body);
  const options = {
    hostname: TARGET_HOST,
    port: 443,
    path: '/v1/chat/completions',
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      'Authorization': `Bearer ${API_KEY}`,
      'Content-Length': Buffer.byteLength(body),
    },
  };

  const proxyReq = https.request(options, (proxyRes) => {
    res.writeHead(proxyRes.statusCode, proxyRes.headers);
    proxyRes.pipe(res);
  });

  proxyReq.on('error', (e) => {
    console.error('Proxy error:', e.message);
    res.status(502).json({ error: e.message });
  });

  proxyReq.write(body);
  proxyReq.end();
});

// 静态文件（PWA）
app.use(express.static(path.join(__dirname, 'dist')));

// SPA fallback
app.get('/{*splat}', (req, res) => {
  res.sendFile(path.join(__dirname, 'dist', 'index.html'));
});

app.listen(PORT, () => {
  console.log(`VoxSpend running at http://localhost:${PORT}`);
  if (!API_KEY) console.warn('WARNING: VITE_AI_API_KEY not set');
});
