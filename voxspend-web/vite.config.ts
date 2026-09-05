import { defineConfig } from 'vite'
import vue from '@vitejs/plugin-vue'

export default defineConfig({
  server: {
    port: 5173,
    proxy: {
      // 浏览器开发环境转发 AI 请求（Agnes 不允许浏览器直连跨域）；APK 内走 CapacitorHttp 不经过这里
      '/api': {
        target: 'https://api.agnes-ai.cn',
        changeOrigin: true,
        rewrite: (path) => path.replace(/^\/api/, ''),
      },
    },
  },
  plugins: [vue()],
})
