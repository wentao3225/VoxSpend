import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  server: {
    port: 5173,
    proxy: {
      // 浏览器开发环境转发 AI 请求（商汤不支持 CORS）；APK 内走 CapacitorHttp 不经过这里
      '/api': {
        target: 'https://token.sensenova.cn',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
  plugins: [vue()],
})
