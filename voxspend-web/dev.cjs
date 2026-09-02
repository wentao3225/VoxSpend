const { spawn } = require('child_process');

const server = spawn('node', ['server.cjs'], { stdio: 'inherit' });
const vite = spawn('npx', ['vite'], { stdio: 'inherit' });

server.on('close', () => process.exit());
vite.on('close', () => process.exit());

process.on('SIGINT', () => {
  server.kill();
  vite.kill();
  process.exit();
});
