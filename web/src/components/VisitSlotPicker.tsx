import { useEffect, useMemo, useRef, useState, type PointerEvent } from 'react';
import { request } from '../lib/api';
import { longDate, t12 } from '../lib/format';
import { Icon } from './Icon';

/* ==========================================================================
   «¿Te gustaría agendar una cita?»: calendario y reloj siempre visibles.
   - Calendario del mes: cualquier día, desde hoy y hasta 60 días.
   - Hora de 1 a 12 con a.m./p.m. en el horario de la inmobiliaria (7:00 a.m. a 11:00 p.m.) y minutos en
     bloques de 15 (:00, :15, :30, :45); la visita dura 15 min. Hoy, solo desde una hora después de ahora. El valor sigue siendo «HH:MM» de 24 h.
   - Con `slug`, se piden al servidor las horas que el broker ya tiene ocupadas ese día.
   - El reloj muestra la hora elegida.
   ========================================================================== */
const DAYS = ['L', 'M', 'M', 'J', 'V', 'S', 'D'];
const MAX_DAYS = 60;

const iso = (d: Date) => `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, '0')}-${String(d.getDate()).padStart(2, '0')}`;
const atNoon = (s: string) => new Date(s + 'T12:00:00');

/** Hora de Cancún ahora (para no ofrecer horas que ya pasaron) */
function cancunNow() {
  const p = Object.fromEntries(new Intl.DateTimeFormat('en-CA', { timeZone: 'America/Cancun', year: 'numeric', month: '2-digit', day: '2-digit', hour: '2-digit', minute: '2-digit', hour12: false })
    .formatToParts(new Date()).map((x) => [x.type, x.value]));
  return { date: `${p.year}-${p.month}-${p.day}`, minutes: (+p.hour % 24) * 60 + +p.minute };
}

/** Bloques de 15 minutos del horario de visitas: de 7:00 a.m. a 10:45 p.m. (termina a las 11:00 p.m.) */
export function slotsFor(date: string): string[] {
  const now = cancunNow();
  const out: string[] = [];
  for (let m = 7 * 60; m < 23 * 60; m += 15) {
    if (date === now.date && m < now.minutes + 60) continue;
    out.push(`${String(Math.floor(m / 60)).padStart(2, '0')}:${String(m % 60).padStart(2, '0')}`);
  }
  return out;
}

/** Reloj que gira, como el de Android: se toca o se arrastra sobre la hora y después sobre los minutos. */
function DialClock({ mode, value, options, onPick, onDone }: {
  mode: 'hour' | 'minute'; value: number | null; options: { value: number; label: string; off: boolean; name: string }[];
  onPick: (value: number) => void; onDone: () => void;
}) {
  const box = useRef<HTMLDivElement>(null);
  const turns = mode === 'hour' ? 12 : 60;
  const fromPointer = (e: PointerEvent<HTMLDivElement>) => {
    const r = box.current!.getBoundingClientRect();
    const angle = (Math.atan2(e.clientX - r.left - r.width / 2, r.top + r.height / 2 - e.clientY) * 180) / Math.PI;
    const at = (angle + 360) % 360;
    // La opción libre más cercana a donde está el dedo
    const near = options.filter((o) => !o.off).map((o) => { const d = Math.abs(((o.value % turns) * 360) / turns - at); return { o, d: Math.min(d, 360 - d) }; }).sort((x, y) => x.d - y.d)[0];
    if (near && near.o.value !== value) onPick(near.o.value);
  };
  return (
    <div className="dial" ref={box} role="group" aria-label={mode === 'hour' ? 'Reloj: elige la hora' : 'Reloj: elige los minutos'}
      onPointerDown={fromPointer} onPointerMove={(e) => { if (e.buttons) fromPointer(e); }} onPointerUp={onDone}>
      {value !== null && <span className="dial__hand" style={{ transform: `rotate(${((value % turns) * 360) / turns}deg)` }} aria-hidden="true" />}
      <span className="dial__pin" aria-hidden="true" />
      {options.map((o) => {
        const rad = (((o.value % turns) * 360) / turns - 90) * (Math.PI / 180);
        return (
          <button key={o.value} type="button" className="dial__n" disabled={o.off} aria-pressed={o.value === value} aria-label={o.name}
            style={{ left: `${50 + 40 * Math.cos(rad)}%`, top: `${50 + 40 * Math.sin(rad)}%` }} onClick={() => { onPick(o.value); onDone(); }}>{o.label}</button>
        );
      })}
    </div>
  );
}

interface Props {
  /** Prefijo de los id (para enlazar errores y etiquetas) */
  id: string;
  date: string;
  time: string;
  onChange: (date: string, time: string) => void;
  /** Propiedad: se consultan las horas ocupadas de su broker */
  slug?: string;
  dateError?: string;
  timeError?: string;
}

export function VisitSlotPicker({ id, date, time, onChange, slug, dateError, timeError }: Props) {
  const today = cancunNow().date;
  const last = iso(new Date(atNoon(today).getTime() + MAX_DAYS * 864e5));
  const [month, setMonth] = useState(() => (date || today).slice(0, 7));
  const [busy, setBusy] = useState<string[]>([]);

  useEffect(() => {
    setBusy([]);
    if (!slug || !date) return;
    let alive = true;
    request<{ busy: string[] }>(`/public/properties/${encodeURIComponent(slug)}/busy?fecha=${date}`)
      .then((r) => alive && setBusy(r.busy || []), () => {});
    return () => { alive = false; };
  }, [slug, date]);

  const cells = useMemo(() => {
    const first = atNoon(month + '-01');
    const offset = (first.getDay() + 6) % 7; // lunes primero
    const days = new Date(first.getFullYear(), first.getMonth() + 1, 0).getDate();
    return [...Array(offset).fill(null), ...Array.from({ length: days }, (_, i) => `${month}-${String(i + 1).padStart(2, '0')}`)];
  }, [month]);

  const shift = (n: number) => {
    const d = atNoon(month + '-01');
    d.setMonth(d.getMonth() + n);
    setMonth(iso(d).slice(0, 7));
  };
  const monthLabel = atNoon(month + '-01').toLocaleDateString('es-MX', { month: 'long', year: 'numeric' });
  const slots = date ? slotsFor(date) : [];
  const free = slots.filter((s) => !busy.includes(s));
  const pick = (d: string) => onChange(d, slotsFor(d).includes(time) ? time : '');
  // Hora y minutos se escriben en sus casillas (1 a 12) y se elige a.m. o p.m.; la hora solo vale si está libre
  const parts = (t: string) => (t ? { h: String(+t.slice(0, 2) % 12 || 12), m: t.slice(3, 5), ap: (+t.slice(0, 2) >= 12 ? 'pm' : 'am') as 'am' | 'pm' } : null);
  const [hh, setHh] = useState(parts(time)?.h ?? '');
  const [mm, setMm] = useState(parts(time)?.m ?? '00');
  const [ap, setAp] = useState<'am' | 'pm'>(parts(time)?.ap ?? 'am');
  const [problem, setProblem] = useState('');
  useEffect(() => { const p = parts(time); if (p) { setHh(p.h); setMm(p.m); setAp(p.ap); } }, [time]);
  // Si ya no quedan horas en la mañana (hoy), se abre en p.m.
  useEffect(() => { if (!time && date && !free.some((s) => +s.slice(0, 2) < 12)) setAp('pm'); }, [date]); // eslint-disable-line react-hooks/exhaustive-deps
  const commit = (h: string, m: string, a: 'am' | 'pm') => {
    const n = +h;
    if (!n) { setProblem(''); return onChange(date, ''); }
    if (n > 12) { setProblem('Escribe una hora de 1 a 12.'); return onChange(date, ''); }
    const t = `${String((n % 12) + (a === 'pm' ? 12 : 0)).padStart(2, '0')}:${m.padStart(2, '0')}`;
    const inHours = t >= '07:00' && t <= '22:45';
    setProblem(free.includes(t) ? '' : !inHours ? 'Las visitas son de 7:00 a.m. a 11:00 p.m.' : busy.includes(t) ? 'Esa hora ya está ocupada. Elige otra.' : 'Esa hora ya pasó. Elige otra.');
    onChange(date, free.includes(t) ? t : '');
  };
  const [dial, setDial] = useState<'hour' | 'minute'>('hour');
  // Al soltar el reloj la hora elegida aún no llega al estado: se consulta aquí para pasar a los minutos
  const hourChosen = useRef('');
  const to24 = (h: number, a: 'am' | 'pm') => String((h % 12) + (a === 'pm' ? 12 : 0)).padStart(2, '0');
  const pickHour = (h: number) => {
    const hour = to24(h, ap);
    // Si esos minutos no están libres en esa hora, se toma el primer horario libre
    const m = free.includes(`${hour}:${mm}`) ? mm : free.find((x) => x.startsWith(hour + ':'))?.slice(3) ?? mm;
    hourChosen.current = String(h);
    setHh(String(h)); setMm(m); commit(String(h), m, ap);
  };
  const pickMinute = (m: number) => { const v = String(m).padStart(2, '0'); setMm(v); commit(hh, v, ap); };

  return (
    <div className="slot-picker">
      <div className={'slot-cal' + (dateError ? ' is-error' : '')} id={`${id}-fecha`} tabIndex={-1} role="group" aria-labelledby={`${id}-fecha-label`}>
        <p className="slot-picker__label" id={`${id}-fecha-label`}><Icon id="cal" size="sm" />Fecha *</p>
        <div className="slot-cal__head">
          <button type="button" className="slot-cal__nav" onClick={() => shift(-1)} disabled={month <= today.slice(0, 7)} aria-label="Mes anterior"><Icon id="left" size="sm" /></button>
          <strong aria-live="polite">{monthLabel.charAt(0).toUpperCase() + monthLabel.slice(1)}</strong>
          <button type="button" className="slot-cal__nav" onClick={() => shift(1)} disabled={month >= last.slice(0, 7)} aria-label="Mes siguiente"><Icon id="right" size="sm" /></button>
        </div>
        <div className="slot-cal__grid">
          {DAYS.map((d, i) => <span key={i} className="slot-cal__dow" aria-hidden="true">{d}</span>)}
          {cells.map((d, i) => {
            if (!d) return <span key={'x' + i} />;
            const off = d < today || d > last || !slotsFor(d).length;
            return (
              <button key={d} type="button" className={'slot-cal__day' + (d === today ? ' is-today' : '')} aria-pressed={date === d} disabled={off}
                aria-label={longDate(d)} onClick={() => pick(d)}>
                {+d.slice(8)}
              </button>
            );
          })}
        </div>
        {dateError && <p className="field__error flex"><Icon id="alert" size="sm" />{dateError}</p>}
      </div>

      <div className={'slot-time' + (timeError ? ' is-error' : '')} id={`${id}-horario`} tabIndex={-1} role="group" aria-labelledby={`${id}-horario-label`}>
        <div className="slot-time__head">
          <div>
            <p className="slot-picker__label" id={`${id}-horario-label`}><Icon id="clock" size="sm" />Hora *</p>
            <p className="slot-time__chosen" aria-live="polite">
              {date ? (time ? `${longDate(date)} · ${t12(time)}` : longDate(date)) : 'Primero elige el día en el calendario'}
            </p>
            <p className="small muted">Gira el reloj: primero la hora y luego los minutos. Horario de visitas: 7:00 a.m. a 11:00 p.m.</p>
          </div>
        </div>
        {date && (free.length ? (
          <>
            <div className="slot-ap" role="group" aria-label="a.m. o p.m.">
              {(['am', 'pm'] as const).map((v) => {
                const open = free.some((s) => (+s.slice(0, 2) < 12) === (v === 'am'));
                return (
                  <button key={v} type="button" className="slot" aria-pressed={ap === v} disabled={!open} onClick={() => { setAp(v); setDial('hour'); commit(hh, mm, v); }}>
                    {v === 'am' ? 'a.m. · mañana' : 'p.m. · tarde y noche'}
                  </button>
                );
              })}
            </div>
            <div className="dial-read" aria-live="polite">
              <button type="button" className="dial-read__part" aria-pressed={dial === 'hour'} onClick={() => setDial('hour')}>{hh || '--'}</button>
              <span aria-hidden="true">:</span>
              <button type="button" className="dial-read__part" aria-pressed={dial === 'minute'} disabled={!hh} onClick={() => setDial('minute')}>{mm}</button>
              <span className="dial-read__ap">{ap === 'am' ? 'a.m.' : 'p.m.'}</span>
            </div>
            {dial === 'hour' ? (
              <DialClock mode="hour" value={hh ? +hh % 12 || 12 : null} onPick={pickHour} onDone={() => { if (hh || hourChosen.current) setDial('minute'); }}
                options={Array.from({ length: 12 }, (_, i) => { const h = i + 1, open = free.some((x) => x.startsWith(to24(h, ap) + ':')); return { value: h, label: String(h), off: !open, name: `${h} ${ap === 'am' ? 'a.m.' : 'p.m.'}${open ? '' : ', no disponible'}` }; })} />
            ) : (
              <DialClock mode="minute" value={+mm} onPick={pickMinute} onDone={() => {}}
                options={[0, 15, 30, 45].map((m) => { const t = `${to24(+hh || 12, ap)}:${String(m).padStart(2, '0')}`; return { value: m, label: String(m).padStart(2, '0'), off: !free.includes(t), name: t12(t) }; })} />
            )}
            {problem && <p className="field__error flex" role="alert"><Icon id="alert" size="sm" />{problem}</p>}
          </>
        ) : (
          <p className="small muted">Ya no quedan horarios este día. Elige otro.</p>
        ))}
        {timeError && <p className="field__error flex"><Icon id="alert" size="sm" />{timeError}</p>}
      </div>
    </div>
  );
}
