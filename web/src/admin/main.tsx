import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { HashRouter, Navigate, Route, Routes } from 'react-router';
import { OverlayProvider } from './components/Overlay';
import { Shell } from './components/Shell';
import { Sprite } from './components/Sprite';
import { Brokers } from './views/Brokers';
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
            <Route index element={<Navigate to="/brokers" replace />} />
            <Route path="brokers" element={<Brokers />} />
            <Route path="*" element={<Navigate to="/brokers" replace />} />
          </Route>
        </Routes>
      </OverlayProvider>
    </HashRouter>
  </StrictMode>,
);
