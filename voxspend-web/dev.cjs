const { spawn } = require('child_process');
const path = require('path');

const viteBin = path.join(__dirname, 'node_modules', '.bin', 'vite');
const server = spawn('node', ['server.cjs'], { stdio: 'inherit', cwd: __dirname });
const vite = spawn(viteBin, [], { stdio: 'inherit', cwd: __dirname, shell: true });

server.on('close', () => process.exit());
vite.on('close', () => process.exit());

process.on('SIGINT', () => {
  server.kill();
  vite.kill();
  process.exit();
});
