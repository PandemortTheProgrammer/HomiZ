import { StrictMode } from 'react';
import { createRoot } from 'react-dom/client';
import { HashRouter, Navigate, Route, Routes } from 'react-router';
import { OverlayProvider } from './components/Overlay';
import { Shell } from './components/Shell';
import { Sprite } from './components/Sprite';
import { Appointments } from './views/Appointments';
import { Brokers } from './views/Brokers';
import { Login } from './views/Login';
import { PaymentsPage } from './views/Payments';
import { RentalsPage } from './views/Rentals';
import { People } from './views/People';
import { PropertiesList, PropertyDetail } from './views/Properties';
import { PropertyForm } from './views/PropertyForm';
import { RequestsPage } from './views/Requests';
import { Summary } from './views/Summary';
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
            <Route index element={<Navigate to="/resumen" replace />} />
            <Route path="resumen" element={<Summary />} />
            <Route path="propiedades" element={<PropertiesList />} />
            <Route path="propiedades/nueva" element={<PropertyForm />} />
            <Route path="propiedades/:id" element={<PropertyDetail />} />
            <Route path="propiedades/:id/editar" element={<PropertyForm />} />
            <Route path="personas" element={<People />} />
            <Route path="brokers" element={<Brokers />} />
            <Route path="citas" element={<Appointments />} />
            <Route path="rentas" element={<RentalsPage />} />
            <Route path="pagos" element={<PaymentsPage />} />
            <Route path="solicitudes" element={<RequestsPage />} />
            <Route path="*" element={<Navigate to="/resumen" replace />} />
          </Route>
        </Routes>
      </OverlayProvider>
    </HashRouter>
  </StrictMode>,
);
