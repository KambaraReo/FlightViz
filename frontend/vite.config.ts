import { defineConfig } from 'vite'
import react from '@vitejs/plugin-react'

// https://vite.dev/config/
export default defineConfig({
  plugins: [react()],
  // localhost:5173 に外部（Dockerホスト）からアクセスできる状態にするために以下を追加
  server: {
    host: '0.0.0.0',
    port: 5173,
    proxy: {
      '/api/v1': {
        target: 'http://backend:3000', // backend は docker-compose のサービス名
        changeOrigin: true,
        secure: false,
      },
    },
  },
})
