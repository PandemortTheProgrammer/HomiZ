import { createContext, useCallback, useContext, useEffect, useMemo, useState, type ReactNode } from 'react';
import { fetchCatalog, type ApiError } from '../lib/api';
import type { House } from '../lib/catalog';

/* Catálogo de casas: siempre el de la API (GET /public/properties). Si no responde, se avisa y se puede reintentar;
   nunca se muestran casas inventadas. */
interface CatalogState {
  houses: House[];
  bySlug: Record<string, House>;
  /** true mientras se espera la primera respuesta de la API */
  loading: boolean;
  /** Mensaje si la API no respondió (null = sin error) */
  error: string | null;
  /** Vuelve a pedir el catálogo */
  retry: () => void;
}

const CatalogContext = createContext<CatalogState | null>(null);

const index = (houses: House[]) => Object.fromEntries(houses.map((h) => [h.slug, h]));

export function CatalogProvider({ children }: { children: ReactNode }) {
  const [houses, setHouses] = useState<House[] | null>(null);
  const [error, setError] = useState<string | null>(null);
  const [attempt, setAttempt] = useState(0);
  const retry = useCallback(() => setAttempt((n) => n + 1), []);
  useEffect(() => {
    let alive = true;
    setHouses(null);
    setError(null);
    fetchCatalog().then(
      (list) => alive && setHouses(list),
      (e: ApiError) => {
        if (!alive) return;
        setHouses([]);
        setError(e?.sinConexion ? 'No hay conexión con el servidor de Zugar.' : e?.mensaje || 'El servidor no pudo enviar el catálogo.');
      },
    );
    return () => {
      alive = false;
    };
  }, [attempt]);

  const value = useMemo<CatalogState>(() => {
    const loading = houses === null;
    // Solo lo publicado: una casa rentada o pausada no sale en la portada ni en los formularios
    const list = houses ?? [];
    return { houses: list, bySlug: index(list), loading, error, retry };
  }, [houses, error, retry]);

  return (
    <CatalogContext.Provider value={value}>
      {error && (
        <div className="api-alert" role="alert">
          <div className="wrap api-alert__inner">
            <p><strong>No pudimos cargar las casas.</strong> {error} Revisa tu internet e inténtalo de nuevo.</p>
            <button className="btn" type="button" onClick={retry}>Reintentar</button>
          </div>
        </div>
      )}
      {children}
    </CatalogContext.Provider>
  );
}

export function useCatalog(): CatalogState {
  const ctx = useContext(CatalogContext);
  if (!ctx) throw new Error('useCatalog fuera de CatalogProvider');
  return ctx;
}
