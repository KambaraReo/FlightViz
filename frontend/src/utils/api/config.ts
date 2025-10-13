// API設定
const API_BASE_URL = import.meta.env.VITE_API_BASE_URL || "/api";

// 開発時のデバッグ情報
if (import.meta.env.DEV) {
  console.log("API_BASE_URL:", API_BASE_URL);
  console.log("Environment:", import.meta.env.MODE);
}

export { API_BASE_URL };
