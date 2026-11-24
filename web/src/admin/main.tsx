import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { HashRouter, Route, Routes } from 'react-router';
import { OverlayProvider } from './components/Overlay';
import { Shell } from './components/Shell';
import { Sprite } from './components/Sprite';
import { Login } from './views/Login';
import './styles.css';

/* Panel administrativo: rutas con # (/admin/#/propiedades) como el panel HTML, así los enlaces guardados siguen sirviendo. */
createRoot(document.getElementById('root')!).render(
  <StrictMode>
    <HashRouter>
      <Sprite />
      <OverlayProvider>
        <Routes>
          <Route path="login" element={<Login />} />
          <Route element={<Shell />}>
            <Route path="*" element={<h1 tabIndex={-1}>El panel está listo</h1>} />
          </Route>
        </Routes>
      </OverlayProvider>
    </HashRouter>
  </StrictMode>,
);
