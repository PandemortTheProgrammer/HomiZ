import { BUDGET_LIMITS } from '../components/BudgetRange';
import { useEffect, useMemo, useState, type FormEvent, type ReactNode } from 'react';
import { Link, useNavigate, useSearchParams } from 'react-router';
import { useCatalog } from '../components/CatalogProvider';
import { hasCoords, MarkersMap } from '../components/HouseMap';
import { Icon } from '../components/Icon';
import { AreaInput, MoneyInput } from '../components/NumberInput';
import { PropertyCard } from '../components/PropertyCard';
import { inPlace, placeLabel, shortPrice, type House } from '../lib/catalog';
import { PET_OPTIONS, PROPERTY_TYPES, TYPE_GROUPS, typeMatches, typePlural } from '../lib/propertyTypes';
import { usePageTitle } from '../lib/usePageTitle';

/* ==========================================================================
   Listado de propiedades: filtros en la dirección (?operacion=renta&recamaras=3…),
   orden, vista (cuadrícula, lista o mapa), páginas y mapa con la ubicación aproximada.
   ========================================================================== */
const PER_PAGE = 6;

type Option = [string, string];
const TYPES: Option[] = [['', 'Todos los tipos'], ...PROPERTY_TYPES.map((t): Option => [t.key, t.label])];
// Montos sugeridos (también se puede escribir cualquier otro)
const PRICES: Record<'renta' | 'venta', number[]> = {
  renta: [8000, 10000, 15000, 20000, 25000, 30000, 40000, 60000, 80000],
  venta: [1500000, 2500000, 3500000, 4500000, 5500000, 7000000, 10000000, 15000000],
};
const AREAS = [50, 80, 120, 180, 250, 400, 1000, 5000];
const BEDROOMS: Option[] = [['', 'Cualquiera'], ['1', '1 recámara'], ['2', '2 recámaras'], ['3', '3 recámaras'], ['4', '4 o más']];
const ATLEAST: Option[] = [['', 'Cualquiera'], ['1', '1 o más'], ['2', '2 o más'], ['3', '3 o más']];
const FURNISHED: Option[] = [['', 'Indistinto'], ['si', 'Amueblada'], ['semi', 'Semiamueblada'], ['no', 'Sin amueblar']];
const SORTS: Option[] = [['precio-asc', 'Precio: menor a mayor'], ['precio-desc', 'Precio: mayor a menor'], ['recientes', 'Más recientes']];

const FILTERS = ['tipo', 'zona', 'precio_min', 'precio_max', 'superficie', 'superficie_max', 'recamaras', 'banos', 'estacionamientos', 'mascotas', 'amueblada'] as const;
type FilterKey = (typeof FILTERS)[number];
type Filters = Record<FilterKey, string>;
/** Filtros que se escriben (montos y metros): solo dígitos */
const WRITTEN = new Set<FilterKey>(['precio_min', 'precio_max', 'superficie', 'superficie_max']);

const optionsFor = (k: FilterKey): Option[] =>
  ({ tipo: TYPES, recamaras: BEDROOMS, banos: ATLEAST, estacionamientos: ATLEAST, mascotas: PET_OPTIONS, amueblada: FURNISHED } as Partial<Record<FilterKey, Option[]>>)[k] ?? [];
const fmt = (n: string) => Number(n).toLocaleString('en-US');

/** Distancia en km entre dos puntos (fórmula del semiverseno) */
function km(a: { lat: number; lng: number }, b: { lat: number; lng: number }) {
  const r = (d: number) => (d * Math.PI) / 180;
  const h = Math.sin(r(b.lat - a.lat) / 2) ** 2 + Math.cos(r(a.lat)) * Math.cos(r(b.lat)) * Math.sin(r(b.lng - a.lng) / 2) ** 2;
  return 12742 * Math.asin(Math.sqrt(h));
}

/** Punto elegido en el mapa de la portada: casas a menos de «radio» km (las que no tienen ubicación no entran). */
export type Near = { lat: number; lng: number; radius: number; label: string } | null;

function matches(c: House, op: string, q: Filters, near: Near) {
  const min = +q.precio_min || 0, max = +q.precio_max || 0;
  // Sin operación elegida, los montos de millones se entienden como venta y los demás como renta
  const opOk = !op || c.op === op;
  const opFromPrice = op || !max ? true : (max >= 1e6) === (c.op === 'venta');
  return (
    opOk && opFromPrice &&
    typeMatches(q.tipo, c.tipo) &&
    inPlace(c, q.zona) &&
    (!near || (hasCoords(c) && km(near, c) <= near.radius)) &&
    (!min || c.price >= min) &&
    (!max || c.price <= max) &&
    (!q.superficie || c.m2 >= +q.superficie) &&
    (!q.superficie_max || (c.m2 > 0 && c.m2 <= +q.superficie_max)) &&
    (!q.recamaras || (q.recamaras === '4' ? c.rec >= 4 : c.rec === +q.recamaras)) &&
    (!q.banos || c.banos >= +q.banos) &&
    (!q.estacionamientos || c.est >= +q.estacionamientos) &&
    (!q.mascotas || c.pets === (q.mascotas === 'si')) &&
    (!q.amueblada || c.amueblada === q.amueblada)
  );
}

export function Listing() {
  const { houses, loading } = useCatalog();
  const [params, setParams] = useSearchParams();
  const navigate = useNavigate();
  const [panelOpen, setPanelOpen] = useState(false);
  const [selected, setSelected] = useState<string | null>(null);

  const op = params.get('operacion') === 'renta' || params.get('operacion') === 'venta' ? params.get('operacion')! : '';
  const sort = params.get('orden') || 'precio-asc';
  const view = params.get('vista') || 'cuadricula';
  // Valores de la dirección; los que no existen en las listas se ignoran
  const q = Object.fromEntries(
    FILTERS.map((k) => {
      const v = params.get(k) ?? (k === 'precio_max' ? params.get('presupuesto') ?? '' : '');
      if (k === 'zona') return [k, v.trim().slice(0, 80)]; // texto libre
      if (WRITTEN.has(k)) return [k, /^\d{1,12}$/.test(v) && +v > 0 ? String(+v) : ''];
      return [k, optionsFor(k).some(([o]) => o === v) ? v : ''];
    }),
  ) as Filters;
  const [draft, setDraft] = useState<Filters>(q);
  const [draftOp, setDraftOp] = useState(op);
  useEffect(() => { setDraft(q); setDraftOp(op); }, [params.toString()]); // al cambiar la dirección, el formulario muestra los filtros aplicados

  /** Dirección con cambios (null o '' quitan el parámetro) */
  const urlWith = (changes: Record<string, string | number | null>) => {
    const u = new URLSearchParams(params);
    Object.entries(changes).forEach(([k, v]) => (v === null || v === '' ? u.delete(k) : u.set(k, String(v))));
    if (changes.precio_max === null) u.delete('presupuesto');
    const s = u.toString();
    return '/propiedades' + (s ? '?' + s : '');
  };

  // Lugar elegido en el mapa de la portada (?lat=&lng=&radio=&lugar=) y presupuesto mínimo (?precio_min=)
  const near: Near = useMemo(() => {
    const lat = Number(params.get('lat')), lng = Number(params.get('lng')), radius = Number(params.get('radio')) || 10;
    return params.get('lat') && Number.isFinite(lat) && Number.isFinite(lng) && Math.abs(lat) <= 90 && Math.abs(lng) <= 180
      ? { lat, lng, radius: Math.min(Math.max(radius, 1), 200), label: (params.get('lugar') || 'el punto elegido').slice(0, 80) }
      : null;
  }, [params.toString()]);
  const results = useMemo(
    () => houses.filter((c) => matches(c, op, q, near)).sort((a, b) => (sort === 'precio-desc' ? b.price - a.price : sort === 'recientes' ? b.orden - a.orden : a.price - b.price)),
    [houses, op, sort, JSON.stringify(q), near],
  );
  // Sugerencias para «Ubicación»: las zonas de las casas publicadas (se puede escribir cualquier otra)
  const places = useMemo(() => [...new Set(houses.map((h) => h.zona))].sort(), [houses]);
  const total = results.length;
  const pages = Math.max(1, Math.ceil(total / PER_PAGE));
  const page = Math.min(pages, Math.max(1, parseInt(params.get('pagina') || '1', 10) || 1));
  const from = (page - 1) * PER_PAGE;
  const pageItems = results.slice(from, from + PER_PAGE);

  const recTxt = q.recamaras ? (q.recamaras === '4' ? ' de 4 o más recámaras' : ` de ${q.recamaras} recámara${q.recamaras === '1' ? '' : 's'}`) : '';
  const opTxt = op === 'renta' ? ' en renta' : op === 'venta' ? ' en venta' : ' en renta y venta';
  const title = typePlural(q.tipo) + recTxt + opTxt + (near ? ' cerca de ' + near.label.split(',')[0] : ' en ' + (q.zona ? placeLabel(q.zona) : 'Cancún'));
  usePageTitle(title + ' | Zugar Inmobiliaria');

  const chips: [string, Record<string, null>][] = [];
  if (op) chips.push([op === 'renta' ? 'En renta' : 'En venta', { operacion: null }]);
  if (near) chips.push([`A ${near.radius} km de ${near.label.split(',')[0]}`, { lat: null, lng: null, radio: null, lugar: null }]);
  FILTERS.forEach((k) => {
    if (!q[k]) return;
    const text = {
      zona: 'Ubicación: ' + placeLabel(q.zona),
      precio_min: `Desde $${fmt(q.precio_min)}`,
      precio_max: `Hasta $${fmt(q.precio_max)}`,
      superficie: `Desde ${fmt(q.superficie)} m²`,
      superficie_max: `Hasta ${fmt(q.superficie_max)} m²`,
    }[k as string] ?? optionsFor(k).find(([v]) => v === q[k])![1];
    const prefix = ({ banos: 'Baños: ', estacionamientos: 'Estacionamientos: ' } as Record<string, string>)[k] ?? '';
    chips.push([prefix + text, { [k]: null }]);
  });
  chips.forEach(([, c]) => (c.pagina = null));

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === 'Escape' && setPanelOpen(false);
    document.addEventListener('keydown', onKey);
    return () => document.removeEventListener('keydown', onKey);
  }, []);
  useEffect(() => setSelected(null), [params.toString()]);

  // El máximo nunca puede quedar por debajo del mínimo
  const lowest = BUDGET_LIMITS[draftOp === 'venta' ? 'compra' : 'renta'][0];
  const tooLow = (v: string) => (v && +v < lowest ? `Escribe al menos $${lowest.toLocaleString('en-US')}.` : '');
  const priceMinError = tooLow(draft.precio_min);
  const priceError = tooLow(draft.precio_max) || (draft.precio_min && draft.precio_max && +draft.precio_min > +draft.precio_max ? 'El máximo no puede ser menor que el mínimo.' : '');
  const areaError = draft.superficie && draft.superficie_max && +draft.superficie > +draft.superficie_max ? 'El máximo no puede ser menor que el mínimo.' : '';

  const onFilter = (e: FormEvent) => {
    e.preventDefault();
    if (priceMinError || priceError || areaError) return document.getElementById(priceMinError ? 'f-precio-min' : priceError ? 'f-precio-max' : 'f-superficie-max')?.focus();
    setPanelOpen(false);
    const u = new URLSearchParams();
    if (draftOp) u.set('operacion', draftOp);
    const d = { ...draft };
    FILTERS.forEach((k) => d[k] && u.set(k, d[k]));
    // Se conserva el lugar elegido en el mapa de la portada
    ['lat', 'lng', 'radio', 'lugar'].forEach((k) => params.get(k) && u.set(k, params.get(k)!));
    if (sort !== 'precio-asc') u.set('orden', sort);
    if (view !== 'cuadricula') u.set('vista', view);
    setParams(u);
  };


  const cell = (n: number, label: string, content: ReactNode, current = false) =>
    n < 1 || n > pages ? (
      <li key={label + n}><span className="is-disabled" aria-label={`${label} (no disponible)`}>{content}</span></li>
    ) : (
      <li key={label + n}><Link to={urlWith({ pagina: n === 1 ? null : n })} aria-current={current ? 'page' : undefined} aria-label={label || undefined}>{content}</Link></li>
    );

  return (
    <>
      <div className="wrap">
        <nav className="breadcrumb" aria-label="Ruta de navegación">
          <ol>
            <li><Link to="/">Inicio</Link></li>
            {op ? (
              <li><Link to={`/propiedades?operacion=${op}`} aria-current={recTxt ? undefined : 'page'}>{op === 'renta' ? 'Rentas' : 'Ventas'} en Cancún</Link></li>
            ) : (
              <li><span aria-current="page">Propiedades</span></li>
            )}
            {op && recTxt && <li><span aria-current="page">{recTxt.replace(/^ de /, '').replace(/^./, (m) => m.toUpperCase())}</span></li>}
          </ol>
        </nav>
        <div className="listing-head">
          <div>
            <span className="eyebrow">Un lugar para tu siguiente capítulo</span>
            <h1>{title}</h1>
            <p>
              {total} propiedad{total === 1 ? '' : 'es'} disponible{total === 1 ? '' : 's'} · {op === 'renta' ? 'Rentas a largo plazo' : op === 'venta' ? 'Contado, crédito bancario o Infonavit' : 'Renta y venta'} · Precios en MXN
            </p>
          </div>
          <Link className="btn btn--secondary btn--lg" to="/contacto?motivo=alerta-busqueda"><Icon id="bookmark" />Guardar búsqueda</Link>
        </div>
      </div>

      {/* Filtros */}
      <section className="filters" aria-label="Filtros de búsqueda">
        <div className="wrap">
          <input type="checkbox" id="filtros-toggle" className="filters__toggle-input" aria-label="Mostrar filtros" checked={panelOpen} onChange={(e) => setPanelOpen(e.target.checked)} />
          <label htmlFor="filtros-toggle" className="btn btn--secondary btn--lg btn--block filters__open"><Icon id="sliders" />Filtros{chips.length ? ` (${chips.length})` : ''}</label>
          <div className="filters__panel">
            <div className="filters__panel-head">
              <h2>Filtros</h2>
              <label htmlFor="filtros-toggle" aria-label="Cerrar filtros"><Icon id="x" size="lg" /></label>
            </div>
            <form id="filtros" onSubmit={onFilter}>
              <div className="filters__grid">
                {/* Renta o venta: lo primero que se elige al buscar */}
                <div className="field field--full">
                  <span className="field__label" id="f-op-label">Operación</span>
                  <div className="choice-group" role="radiogroup" aria-labelledby="f-op-label">
                    {([['', 'Renta y venta'], ['renta', 'Renta'], ['venta', 'Venta']] as const).map(([v, t]) => (
                      <label key={v} className="choice">
                        <input type="radio" name="f-op" value={v} checked={draftOp === v}
                          onChange={() => { setDraftOp(v); setDraft((d) => ({ ...d, precio_min: '', precio_max: '' })); }} />
                        <span>{t}</span>
                      </label>
                    ))}
                  </div>
                </div>
                {FILTERS.map((k) => {
                  const priceWord = draftOp === 'renta' ? 'Renta mensual' : draftOp === 'venta' ? 'Precio de venta' : 'Precio';
                  const labels: Record<FilterKey, string> = {
                    tipo: 'Tipo de inmueble', zona: 'Ubicación', precio_min: priceWord + ' desde', precio_max: priceWord + ' hasta',
                    superficie: 'Superficie desde', superficie_max: 'Superficie hasta',
                    recamaras: 'Recámaras', banos: 'Baños', estacionamientos: 'Estacionamientos', mascotas: 'Mascotas', amueblada: 'Amueblado',
                  };
                  const id = 'f-' + k.replace('_', '-');
                  const set = (v: string) => setDraft({ ...draft, [k]: v });
                  if (k === 'zona') {
                    return (
                      <div key={k} className="field field--full">
                        <label className="field__label" htmlFor={id}>{labels[k]}</label>
                        <input className="input" id={id} type="search" list="ubicaciones" maxLength={80} placeholder="Colonia, ciudad o país" value={draft.zona} onChange={(e) => set(e.target.value)} />
                        <datalist id="ubicaciones">{places.map((z) => <option key={z} value={z} />)}</datalist>
                      </div>
                    );
                  }
                  if (k === 'precio_min' || k === 'precio_max') {
                    const list = draftOp === 'renta' || draftOp === 'venta' ? PRICES[draftOp] : [...PRICES.renta, ...PRICES.venta];
                    return (
                      <div key={k} className="field">
                        <label className="field__label" htmlFor={id}>{labels[k]}</label>
                        <MoneyInput id={id} placeholder={k === 'precio_min' ? '$0' : 'Sin límite'} value={draft[k]} onChange={set} suggestions={list} aria-invalid={!!(k === 'precio_max' ? priceError : priceMinError)} />
                        {(k === 'precio_max' ? priceError : priceMinError) && <p className="field__error flex" role="alert"><Icon id="alert" size="sm" />{k === 'precio_max' ? priceError : priceMinError}</p>}
                      </div>
                    );
                  }
                  if (k === 'superficie' || k === 'superficie_max') {
                    return (
                      <div key={k} className="field">
                        <label className="field__label" htmlFor={id}>{labels[k]}</label>
                        <AreaInput id={id} placeholder={k === 'superficie' ? '0' : 'Sin límite'} value={draft[k]} onChange={set} suggestions={AREAS} aria-invalid={k === 'superficie_max' && !!areaError} />
                        {k === 'superficie_max' && areaError && <p className="field__error flex" role="alert"><Icon id="alert" size="sm" />{areaError}</p>}
                      </div>
                    );
                  }
                  return (
                    <div key={k} className={`field${k === 'tipo' ? ' field--full' : ''}`}>
                      <label className="field__label" htmlFor={id}>{labels[k]}</label>
                      <select className="select" id={id} value={draft[k]} onChange={(e) => set(e.target.value)}>
                        {k === 'tipo' ? (
                          <>
                            <option value="">Todos los tipos</option>
                            {TYPE_GROUPS.map((g) => (
                              <optgroup key={g} label={g}>{PROPERTY_TYPES.filter((t) => t.group === g).map((t) => <option key={t.key} value={t.key}>{t.label}</option>)}</optgroup>
                            ))}
                          </>
                        ) : (
                          optionsFor(k).map(([v, t]) => <option key={v} value={v}>{t}</option>)
                        )}
                      </select>
                    </div>
                  );
                })}
                <div className="filters__submit">
                  <button className="btn btn--lg btn--block" type="submit"><Icon id="search" />Buscar propiedades</button>
                </div>
                <div className="filters__mobile-only">
                  <Link className="btn btn--secondary btn--lg btn--block" to="/propiedades" onClick={() => setPanelOpen(false)}>Limpiar filtros</Link>
                </div>
              </div>
            </form>
          </div>
          {chips.length > 0 && (
            <div className="active-filters" aria-label="Filtros activos">
              {chips.map(([text, change]) => (
                <Link key={text} className="chip" to={urlWith(change)} aria-label={`Quitar filtro: ${text}`}>{text}<Icon id="x" size="sm" /></Link>
              ))}
              <Link className="clear" to="/propiedades">Limpiar filtros</Link>
            </div>
          )}
        </div>
      </section>

      <div className="wrap">
        <div className="toolbar">
          <div className="toolbar__sort">
            <div className="field">
              <label className="field__label" htmlFor="orden">Ordenar por precio o recientes</label>
              <select className="select" id="orden" value={sort} onChange={(e) => navigate(urlWith({ orden: e.target.value === 'precio-asc' ? null : e.target.value, pagina: null }))}>
                {SORTS.map(([v, t]) => <option key={v} value={v}>{t}</option>)}
              </select>
            </div>
            <p className="toolbar__count">{total ? `Mostrando ${from + 1}–${from + pageItems.length} de ${total} propiedad${total === 1 ? '' : 'es'}` : loading ? 'Cargando propiedades…' : 'Sin resultados'}</p>
          </div>
          <nav className="segmented" aria-label="Tipo de vista">
            {([['lista', 'list', 'Lista'], ['cuadricula', 'grid', 'Cuadrícula'], ['mapa', 'map', 'Mapa']] as const).map(([v, icon, label]) => (
              <Link key={v} to={urlWith({ vista: v === 'cuadricula' ? null : v })} aria-current={view === v ? 'true' : undefined}><Icon id={icon} size="sm" />{label}</Link>
            ))}
          </nav>
        </div>

        <div className={`listing-layout${view === 'mapa' ? ' is-map-view' : ''}`}>
          <section aria-labelledby="resultados-titulo">
            <h2 id="resultados-titulo" className="sr-only">Resultados</h2>
            <div className={`cards cards--2${view === 'lista' ? ' cards--list' : ''}`}>
              {pageItems.length ? (
                pageItems.map((c) => <PropertyCard key={c.slug} house={c} />)
              ) : (
                !loading && (
                  <div className="listing-empty">
                    <h3>No encontramos propiedades con esos filtros</h3>
                    <p>Prueba con otra zona o un presupuesto distinto. También podemos buscar por ti.</p>
                    <p className="listing-empty__actions">
                      <Link className="btn btn--secondary" to="/propiedades">Limpiar filtros</Link>
                      <Link className="btn" to="/contacto?motivo=alerta-busqueda">Avísenme cuando haya opciones</Link>
                    </p>
                  </div>
                )
              )}
            </div>
            {total > 0 && (
              <nav className="pagination" aria-label="Paginación de resultados">
                <ul>
                  {cell(page - 1, 'Página anterior', <Icon id="left" size="sm" />)}
                  {Array.from({ length: pages }, (_, i) => cell(i + 1, '', String(i + 1), i + 1 === page))}
                  {cell(page + 1, 'Página siguiente', <Icon id="right" size="sm" />)}
                </ul>
              </nav>
            )}
          </section>

          <aside className="listing-aside" aria-label="Mapa y ayuda">
            <div className="map map--listing">
              {/* Solo las propiedades disponibles que coinciden con la búsqueda, cada una como una zona aproximada */}
              <MarkersMap houses={results} selected={selected} label="Mapa con la zona aproximada de las propiedades disponibles" />
            </div>
            <div className="map-places">
              <p className="map-places__title">Zona aproximada de cada propiedad</p>
              <ul id="map-places">
                {pageItems.length ? (
                  pageItems.map((c) => (
                    <li key={c.slug}>
                      <button type="button" aria-pressed={selected === c.slug} onClick={() => setSelected(c.slug)}>
                        <Icon id="pin" /><span>{c.name} · {shortPrice(c)} · {c.zona.replace(/^Residencial /, '')}</span>
                      </button>
                    </li>
                  ))
                ) : (
                  <li className="muted small">Sin propiedades para mostrar en el mapa.</li>
                )}
              </ul>
              <p className="muted small">Por seguridad mostramos la zona, no la dirección. La ubicación exacta te llega en la app al confirmar tu cita.</p>
            </div>
            <div className="zone-card">
              <span className="eyebrow">Conocemos Cancún</span>
              <h2>La zona también hace hogar.</h2>
              <p>Te ayudamos a elegir según tu rutina, tus tiempos de traslado, escuelas cercanas y lo que más importa para tu familia.</p>
              <Link className="btn btn--secondary" to="/contacto?motivo=asesoria-zona"><Icon id="arrow" />Ayúdame a elegir</Link>
            </div>
          </aside>
        </div>
      </div>
    </>
  );
}
