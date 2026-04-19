import { createContext, useCallback, useContext, useEffect, useMemo, useState } from 'react'
import axios, { setAccessToken } from '../api/client'

const AuthContext = createContext(null)

const EMAIL_STORAGE_KEY = 'fashionai_user_email'

export function AuthProvider({ children }) {
  const [token, setToken] = useState(() => {
    try {
      return localStorage.getItem('fashionai_access_token')
    } catch {
      return null
    }
  })
  const [email, setEmail] = useState(() => {
    try {
      return localStorage.getItem(EMAIL_STORAGE_KEY) || ''
    } catch {
      return ''
    }
  })

  useEffect(() => {
    setAccessToken(token)
  }, [token])

  const persistEmail = useCallback((value) => {
    const e = (value || '').trim()
    setEmail(e)
    try {
      if (e) localStorage.setItem(EMAIL_STORAGE_KEY, e)
      else localStorage.removeItem(EMAIL_STORAGE_KEY)
    } catch {
      /* ignore */
    }
  }, [])

  const signIn = useCallback(
    async (emailIn, password) => {
      setToken(null)
      setAccessToken(null)
      const { data } = await axios.post('/api/auth/signin', {
        email: emailIn.trim(),
        password,
      })
      const access_token = data?.access_token
      if (!access_token) throw new Error('No access_token in response')
      setToken(access_token)
      persistEmail(emailIn)
    },
    [persistEmail]
  )

  const signUp = useCallback(
    async (emailIn, password) => {
      setToken(null)
      setAccessToken(null)
      const { data } = await axios.post('/api/auth/signup', {
        email: emailIn.trim(),
        password,
      })
      const access_token = data?.access_token
      if (!access_token) throw new Error('No access_token in response')
      setToken(access_token)
      persistEmail(emailIn)
    },
    [persistEmail]
  )

  const signOut = useCallback(() => {
    setToken(null)
    persistEmail('')
  }, [persistEmail])

  const value = useMemo(
    () => ({
      token,
      email,
      isAuthenticated: Boolean(token),
      signIn,
      signUp,
      signOut,
    }),
    [token, email, signIn, signUp, signOut]
  )

  return <AuthContext.Provider value={value}>{children}</AuthContext.Provider>
}

export function useAuth() {
  const ctx = useContext(AuthContext)
  if (!ctx) throw new Error('useAuth must be used within AuthProvider')
  return ctx
}
