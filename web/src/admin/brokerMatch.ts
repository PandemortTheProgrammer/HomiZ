import type { Lead } from './api';
import { D, norm, Z, type Broker, type Property } from './store';

/* ==========================================================================
   Brokers recomendados para una solicitud: quién tiene casas disponibles que encajan con
   la operación, el presupuesto (hasta +15 %, igual que las sugerencias del sitio), las
   recámaras, los baños y las mascotas. La zona y el tipo suben a la casa en la lista.
   ========================================================================== */
export interface HouseMatch { house: Property; why: string[]; zone: boolean }
export interface BrokerMatch { broker: Broker; houses: HouseMatch[]; requested: boolean; visits: number }

const num = (v: unknown) => { const n = Number(v); return Number.isFinite(n) && n > 0 ? n : 0; };

/** Operación que busca la persona; null si la solicitud no es para rentar o comprar */
function operation(l: Lead): 'renta' | 'venta' | null {
  if (l.reason === 'comprar' || l.payload.operacion === 'compra') return 'venta';
  if (l.reason === 'rentar' || l.payload.operacion === 'renta') return 'renta';
  if (l.reason === 'visita' && l.property) return D.properties.find((p) => p.id === l.property!.code)?.op ?? null;
  return null;
}

function matches(l: Lead, op: 'renta' | 'venta', h: Property): HouseMatch | null {
  const p = l.payload;
  const max = num(p.presupuesto_max), min = num(p.presupuesto_min), rec = num(p.recamaras), baths = num(p.banos);
  const pets = p.mascotas === 'si', zone = norm(String(p.zona ?? '')), type = norm(String(p.tipo_inmueble ?? ''));
  if (h.op !== op || (max && h.price > max * 1.15) || (min && h.price < min * 0.85) || h.rec < rec || h.banos < baths) return null;
  if (pets && !h.amenities.includes('Se aceptan mascotas')) return null;
  const inZone = !!zone && norm(h.zone + ' ' + h.city).includes(zone);
  const why = [
    max ? (h.price <= max ? 'dentro del presupuesto' : 'poco arriba del presupuesto') : '',
    rec ? h.rec + ' rec.' : '',
    pets ? 'acepta mascotas' : '',
    inZone ? 'en su zona' : '',
    type && norm(h.type) === type ? 'del tipo que busca' : '',
  ].filter(Boolean);
  return { house: h, why, zone: inZone };
}

/** Brokers con casas que encajan: primero quien atiende la casa que pidió, luego más casas y menos citas pendientes. */
export function brokerMatches(l: Lead): BrokerMatch[] | null {
  const op = operation(l);
  if (!op) return null;
  const free = D.properties.filter((h) => h.visibility === 'publicada' && (h.status === 'disponible' || h.status === 'reservada'));
  const visits = (id: string) => D.appointments.filter((a) => a.broker === id && (a.status === 'por-confirmar' || a.status === 'confirmada') && a.date >= Z.TODAY).length;
  return D.brokers
    .map((broker) => {
      const mine = free.filter((h) => h.broker === broker.id);
      const houses = mine.map((h) => matches(l, op, h)).filter((m): m is HouseMatch => !!m).sort((a, b) => Number(b.zone) - Number(a.zone) || a.house.price - b.house.price);
      return { broker, houses, requested: !!l.property && mine.some((h) => h.id === l.property!.code), visits: visits(broker.id) };
    })
    .filter((m) => m.houses.length || m.requested)
    .sort((a, b) => Number(b.requested) - Number(a.requested) || b.houses.length - a.houses.length || a.visits - b.visits);
}
