import { StrictMode } from 'react'
import { createRoot } from 'react-dom/client'
// Imported before App so tokens and base styles land ahead of every component
// stylesheet in the bundle — component rules must be able to win on order alone.
import './styles/global.css'
import App from './App.tsx'

createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <App />
  </StrictMode>,
)
