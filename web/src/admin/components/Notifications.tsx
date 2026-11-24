import { useCallback, useEffect, useRef, useState } from 'react';
import { useNavigate } from 'react-router';
import { apiActive, request } from '../api';
import { useOverlay } from './Overlay';
import { Icon } from './ui';

/* ==========================================================================
   Campana de avisos del panel: los mismos avisos que llegan a la app (citas, pagos,
   mantenimiento, solicitudes del sitio). Se actualiza al instante con el tiempo real (live.ts),
   cada minuto como respaldo y al llegar un aviso push; los nuevos salen como mensaje emergente.
   ========================================================================== */
interface Notice { id: string; type: string; title: string; message: string; entity: string | null; entityId: string | null; read: boolean; sentAt: string }

const EVERY_MS = 60_000;
/** Sección del panel que corresponde al aviso */
const ROUTE: Record<string, string> = { appointment: '/citas', promissory_note: '/pagos', payment: '/pagos', lead: '/solicitudes', client: '/personas', property: '/propiedades' };

function ago(iso: string) {
  const min = Math.round((Date.now() - Date.parse(iso)) / 60000);
  if (min < 1) return 'Ahora';
  if (min < 60) return `Hace ${min} min`;
  const h = Math.round(min / 60);
  if (h < 24) return `Hace ${h} h`;
  const d = Math.round(h / 24);
  return d === 1 ? 'Ayer' : `Hace ${d} días`;
}

/** Recarga de avisos desde fuera (p. ej. cuando llega un push) */
export const noticesRefresh = { now: () => {} };

export function NotificationsBell() {
  const [list, setList] = useState<Notice[]>([]);
  const [unread, setUnread] = useState(0);
  const [open, setOpen] = useState(false);
  const btn = useRef<HTMLButtonElement>(null);
  const navigate = useNavigate();

  const { toast } = useOverlay();
  // Avisos ya vistos: los nuevos sin leer salen además como mensaje emergente (no en la primera carga)
  const known = useRef<Set<string> | null>(null);
  const load = useCallback(() => {
    if (!apiActive()) return;
    request<{ data: Notice[]; unreadCount: number }>('GET', '/notifications?limit=20')
      .then((r) => {
        const data = r.data || [];
        if (known.current) data.filter((n) => !n.read && !known.current!.has(n.id)).slice(0, 2).forEach((n) => toast(`${n.title}: ${n.message}`));
        known.current = new Set(data.map((n) => n.id));
        setList(data);
        setUnread(r.unreadCount || 0);
      })
      .catch(() => {});
  }, [toast]);
  noticesRefresh.now = load;

  useEffect(() => {
    load();
    const t = setInterval(load, EVERY_MS);
    return () => clearInterval(t);
  }, [load]);

  // Se cierra con Escape o al hacer clic fuera
  useEffect(() => {
    if (!open) return;
    const onClick = (e: MouseEvent) => !(e.target as HTMLElement).closest('.notices') && setOpen(false);
    const onKey = (e: KeyboardEvent) => { if (e.key === 'Escape') { setOpen(false); btn.current?.focus(); } };
    document.addEventListener('click', onClick);
    document.addEventListener('keydown', onKey);
    return () => { document.removeEventListener('click', onClick); document.removeEventListener('keydown', onKey); };
  }, [open]);

  if (!apiActive()) return null;

  const readAll = () => request('POST', '/notifications/read-all').then(load, () => {});
  const choose = (n: Notice) => {
    if (!n.read) request('PATCH', `/notifications/${n.id}/read`).then(load, () => {});
    setOpen(false);
    const to = n.entity ? ROUTE[n.entity] : undefined;
    if (to) navigate(n.entity === 'lead' && n.entityId ? `${to}?id=${n.entityId}` : to);
  };

  return (
    <div className="notices">
      <button ref={btn} className="notices__btn" type="button" aria-expanded={open} aria-controls="notices-menu"
        aria-label={unread ? `Avisos: ${unread} sin leer` : 'Avisos'} title="Avisos" onClick={(e) => { e.stopPropagation(); setOpen(!open); if (!open) load(); }}>
        <Icon id="bell" />
        {unread > 0 && <span className="notices__count" aria-hidden="true">{unread > 9 ? '9+' : unread}</span>}
      </button>
      <div className="notices__menu" id="notices-menu" hidden={!open}>
        <div className="notices__head">
          <strong>Avisos</strong>
          {unread > 0 && <button className="link" type="button" onClick={readAll}>Marcar todos como leídos</button>}
        </div>
        {list.length ? (
          <ul className="notices__list">
            {list.map((n) => (
              <li key={n.id}>
                <button type="button" className={'notices__item' + (n.read ? '' : ' is-unread')} onClick={() => choose(n)}>
                  <strong>{n.title}</strong>
                  <span>{n.message}</span>
                  <time dateTime={n.sentAt}>{ago(n.sentAt)}</time>
                </button>
              </li>
            ))}
          </ul>
        ) : <p className="notices__empty">No tienes avisos por ahora.</p>}
      </div>
    </div>
  );
}
