import { Routes, Route, Navigate, useNavigate } from 'react-router-dom'
import { Suspense, lazy } from 'react'
import { TubelightNavbar } from './components/ui/tubelight-navbar'
import { useAuth } from './context/AuthContext'

const Dashboard = lazy(() => import('./pages/Dashboard'))
const Wardrobe = lazy(() => import('./pages/Wardrobe'))
const WardrobeOutfits = lazy(() => import('./pages/WardrobeOutfits'))
const PrendaDetail = lazy(() => import('./pages/PrendaDetail'))
const OutfitDetail = lazy(() => import('./pages/OutfitDetail'))
const MisOutfits = lazy(() => import('./pages/MisOutfits'))
const GenerateOutfitDetail = lazy(() => import('./pages/GenerateOutfitDetail'))
const ModelExamples = lazy(() => import('./pages/ModelExamples'))
const Mirror = lazy(() => import('./pages/Mirror'))
const MirrorContext = lazy(() => import('./pages/MirrorContext'))
const WardrobeChat = lazy(() => import('./pages/WardrobeChat'))
const Settings = lazy(() => import('./pages/Settings'))
const Login = lazy(() => import('./pages/Login'))

function AppRoutes() {
  const navigate = useNavigate()
  const { isAuthenticated } = useAuth()

  return (
    <>
      <div
        className="min-h-dvh overflow-x-hidden app-shell"
        style={{ background: 'var(--sw-white, #F5F4F0)' }}
      >
        <TubelightNavbar isAuthenticated={isAuthenticated} onLogin={() => navigate('/login')} />
        <div className="pb-[max(5.75rem,calc(4.75rem+env(safe-area-inset-bottom,0px)))]">
          <Suspense
            fallback={
              <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8 py-16">
                <div className="sw-card rounded-2xl border border-[#D0CEC8] p-10 text-center">
                  <p className="sw-label text-[#888]">LOADING…</p>
                </div>
              </div>
            }
          >
            <Routes>
              <Route path="/login" element={<Login />} />
              <Route path="/" element={<Dashboard />} />
              <Route path="/wardrobe" element={<Wardrobe />} />
              <Route path="/wardrobe/outfits" element={<WardrobeOutfits />} />
              <Route path="/wardrobe/prenda/:id" element={<PrendaDetail />} />
              <Route path="/wardrobe/outfit/:id" element={<OutfitDetail />} />
              <Route path="/prendas" element={<Navigate to="/wardrobe" replace />} />
              <Route path="/generate" element={<MisOutfits />} />
              <Route path="/generate/outfit" element={<GenerateOutfitDetail />} />
              <Route path="/outfits" element={<Navigate to="/generate" replace />} />
              <Route path="/modelo/ejemplos" element={<ModelExamples />} />
              <Route path="/mirror" element={<Mirror />} />
              <Route path="/mirror/context" element={<MirrorContext />} />
              <Route path="/chat" element={<WardrobeChat />} />
              <Route path="/settings" element={<Settings />} />
            </Routes>
          </Suspense>
        </div>
      </div>
    </>
  )
}

function App() {
  return <AppRoutes />
}

export default App
