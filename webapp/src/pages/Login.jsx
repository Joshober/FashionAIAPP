import { useState } from 'react'
import { Link, useLocation, useNavigate } from 'react-router-dom'
import { useAuth } from '../context/AuthContext'

export default function Login() {
  const navigate = useNavigate()
  const location = useLocation()
  const { signIn, signUp } = useAuth()
  const [mode, setMode] = useState('signin')
  const [email, setEmail] = useState('')
  const [password, setPassword] = useState('')
  const [confirm, setConfirm] = useState('')
  const [busy, setBusy] = useState(false)
  const [error, setError] = useState(null)

  const from = location.state?.from?.pathname || '/'

  const submit = async (e) => {
    e.preventDefault()
    setError(null)
    const em = email.trim()
    if (!em || !password) {
      setError('Email and password are required.')
      return
    }
    if (mode === 'signup') {
      if (password !== confirm) {
        setError('Passwords do not match.')
        return
      }
      if (password.length < 6) {
        setError('Password must be at least 6 characters.')
        return
      }
    }
    setBusy(true)
    try {
      if (mode === 'signup') await signUp(em, password)
      else await signIn(em, password)
      navigate(from, { replace: true })
    } catch (err) {
      const msg =
        err.response?.data?.error ||
        err.response?.data?.detail ||
        err.message ||
        (mode === 'signup' ? 'Sign-up failed' : 'Sign-in failed')
      setError(msg)
    } finally {
      setBusy(false)
    }
  }

  return (
    <div className="min-h-dvh sw-light flex items-center justify-center px-4" style={{ background: 'var(--sw-white)' }}>
      <div className="w-full max-w-md">
        <div className="sw-card rounded-2xl border border-[#D0CEC8] p-8 shadow-sm">
          <p className="sw-label text-[#FF3B00] mb-2">— ACCOUNT</p>
          <h1 className="sw-display text-2xl mb-6">{mode === 'signup' ? 'Create account' : 'Sign in'}</h1>

          <div className="flex rounded-xl border border-[#D0CEC8] overflow-hidden mb-6">
            <button
              type="button"
              className={`flex-1 py-2.5 text-xs font-bold tracking-wide ${
                mode === 'signin' ? 'bg-[#0D0D0D] text-white' : 'bg-[#fafaf9] text-[#888]'
              }`}
              onClick={() => {
                setMode('signin')
                setError(null)
              }}
            >
              SIGN IN
            </button>
            <button
              type="button"
              className={`flex-1 py-2.5 text-xs font-bold tracking-wide ${
                mode === 'signup' ? 'bg-[#0D0D0D] text-white' : 'bg-[#fafaf9] text-[#888]'
              }`}
              onClick={() => {
                setMode('signup')
                setError(null)
              }}
            >
              SIGN UP
            </button>
          </div>

          <form onSubmit={submit} className="space-y-4">
            <div>
              <label className="block text-xs font-semibold text-[#888] mb-1">Email</label>
              <input
                type="email"
                autoComplete="email"
                value={email}
                onChange={(ev) => setEmail(ev.target.value)}
                className="w-full rounded-lg border border-[#D0CEC8] px-3 py-2.5 text-sm"
              />
            </div>
            <div>
              <label className="block text-xs font-semibold text-[#888] mb-1">Password</label>
              <input
                type="password"
                autoComplete={mode === 'signup' ? 'new-password' : 'current-password'}
                value={password}
                onChange={(ev) => setPassword(ev.target.value)}
                className="w-full rounded-lg border border-[#D0CEC8] px-3 py-2.5 text-sm"
              />
            </div>
            {mode === 'signup' && (
              <div>
                <label className="block text-xs font-semibold text-[#888] mb-1">Confirm password</label>
                <input
                  type="password"
                  autoComplete="new-password"
                  value={confirm}
                  onChange={(ev) => setConfirm(ev.target.value)}
                  className="w-full rounded-lg border border-[#D0CEC8] px-3 py-2.5 text-sm"
                />
              </div>
            )}
            {error && (
              <p className="text-sm text-red-700 font-medium" role="alert">
                {error}
              </p>
            )}
            <button
              type="submit"
              disabled={busy}
              className="sw-btn sw-btn-primary sw-btn-lg w-full justify-center disabled:opacity-50"
            >
              {busy ? 'Please wait…' : mode === 'signup' ? 'Create account' : 'Sign in'}
            </button>
          </form>

          <p className="mt-6 text-center text-sm text-[#888]">
            <Link to="/" className="text-[#FF3B00] font-semibold underline underline-offset-2">
              Back to app
            </Link>
          </p>
        </div>
      </div>
    </div>
  )
}
