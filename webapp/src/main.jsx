import React from 'react'
import ReactDOM from 'react-dom/client'
import { BrowserRouter as Router } from 'react-router-dom'
import { ErrorBoundary } from './components/ErrorBoundary'
import App from './App.jsx'
import './index.css'

import './api/client'
import { AuthProvider } from './context/AuthContext'

const routerFuture = { v7_startTransition: true, v7_relativeSplatPath: true }

const rootEl = document.getElementById('root')
if (!rootEl) {
  document.body.innerHTML = '<div style="padding:2rem;text-align:center;color:#333;">#root not found</div>'
} else {
  const fallback = (
    <div style={{ padding: '2rem', textAlign: 'center', color: '#333', background: '#f5f5f5', minHeight: '100vh' }}>
      <h1>Error loading the app</h1>
      <p>Open the browser console (F12) for details.</p>
      <button type="button" onClick={() => window.location.reload()} style={{ padding: '0.5rem 1rem', marginTop: '1rem', cursor: 'pointer' }}>
        Reload
      </button>
    </div>
  )
  const root = ReactDOM.createRoot(rootEl)
  root.render(
    <React.StrictMode>
      <ErrorBoundary fallback={fallback}>
        <AuthProvider>
          <Router future={routerFuture}>
            <App />
          </Router>
        </AuthProvider>
      </ErrorBoundary>
    </React.StrictMode>
  )
}
