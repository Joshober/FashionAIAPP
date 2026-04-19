import axios from 'axios'

/** Base URL for API and uploads (e.g. https://your-backend.onrender.com). Empty = same origin (local dev). */
export const API_BASE_URL = (import.meta.env.VITE_API_BASE_URL || '').replace(/\/$/, '')

const TOKEN_STORAGE_KEY = 'fashionai_access_token'

/** @type {string|null} */
let accessToken = null
try {
  accessToken = localStorage.getItem(TOKEN_STORAGE_KEY)
} catch {
  /* ignore */
}

/**
 * Persist HS256 access token from POST /api/auth/signin|signup.
 * Clears Authorization for API calls when null.
 */
export function setAccessToken(token) {
  accessToken = token && String(token).trim() ? String(token).trim() : null
  try {
    if (accessToken) localStorage.setItem(TOKEN_STORAGE_KEY, accessToken)
    else localStorage.removeItem(TOKEN_STORAGE_KEY)
  } catch {
    /* ignore */
  }
}

/** @deprecated use setAccessToken — kept for any stray imports */
export function setAuthTokenGetter(_getter) {
  /* no-op */
}

axios.interceptors.request.use((config) => {
  const url = config.url || ''
  const isApi = url.startsWith('/api') || url.startsWith('/uploads')
  if (API_BASE_URL && isApi) {
    config.url = API_BASE_URL + url
  }
  if (isApi && accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`
  }
  return config
})

export { axios }
export default axios
