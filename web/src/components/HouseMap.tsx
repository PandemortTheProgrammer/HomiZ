import { useEffect, useRef } from 'react';
import { useNavigate } from 'react-router';
import L from 'leaflet';
import 'leaflet/dist/leaflet.css';
import { fichaOf, photoOf, shortPrice, type House } from '../lib/catalog';

/* ==========================================================================
   Mapas con Leaflet + OpenStreetMap (sin enlaces a Google Maps).
   - Listado: una zona por propiedad disponible, con ventana (foto, nombre, zona, precio y «Ver la propiedad»).
   - Ficha: el círculo de la zona.
   La ubicación es aproximada a propósito: la API manda un punto movido y un radio de ≈ 1.5 km;
   la dirección exacta solo se ve en la app cuando la cita está confirmada.
   ========================================================================== */
const AREA = 1500;
export const hasCoords = (c?: House | null): c is House & { lat: number; lng: number } =>
  !!c && typeof c.lat === 'number' && typeof c.lng === 'number' && isFinite(c.lat) && isFinite(c.lng);

const esc = (s: string) => s.replace(/[&<>"']/g, (ch) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[ch]!);

function baseMap(el: HTMLElement) {
  const map = L.map(el, { scrollWheelZoom: false });
  L.tileLayer('https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png', {
    maxZoom: 19,
    attribution: '&copy; <a href="https://www.openstreetmap.org/copyright">OpenStreetMap</a>',
  }).addTo(map);
  return map;
}

interface MarkersMapProps {
  houses: House[];
  /** Casa elegida en la lista: el mapa vuela a su marcador y abre su ventana */
  selected?: string | null;
  label: string;
}

/** Mapa del listado: una zona aproximada por propiedad */
export function MarkersMap({ houses, selected, label }: MarkersMapProps) {
  const el = useRef<HTMLDivElement>(null);
  const map = useRef<L.Map | null>(null);
  const areas = useRef<Record<string, L.Circle>>({});
  const navigate = useNavigate();
  const located = houses.filter(hasCoords);
  const key = located.map((h) => h.slug).join(',');

  useEffect(() => {
    if (!el.current) return;
    const m = (map.current = baseMap(el.current));
    areas.current = {};
    m.setView([21.1405, -86.8574], 12); // Cancún; con propiedades se ajusta a sus zonas
    const bounds = L.latLngBounds([]);
    located.forEach((c) => {
      const area = L.circle([c.lat, c.lng], { radius: c.areaMeters || AREA, className: 'map-area' })
        .bindTooltip(c.name, { direction: 'top' })
        .bindPopup(
          `<a class="map-popup" href="${esc(fichaOf(c))}">` +
            `<img src="${esc(photoOf(c))}" alt="" loading="lazy" onerror="this.remove()">` +
            `<strong>${esc(c.name)}</strong><span>${esc(c.zona)} · zona aproximada</span>` +
            `<span class="map-popup__price">${shortPrice(c)}${c.op === 'renta' ? ' al mes' : ''}</span>` +
            `<span class="map-popup__more">Ver la propiedad</span></a>`,
          { minWidth: 200, maxWidth: 240 },
        )
        .addTo(m);
      areas.current[c.slug] = area;
      bounds.extend(L.latLng(c.lat, c.lng).toBounds((c.areaMeters || AREA) * 2));
    });
    if (located.length) m.fitBounds(bounds, { padding: [24, 24], maxZoom: 14 });
    return () => {
      m.remove();
      map.current = null;
    };
  }, [key]); // se redibuja solo si cambian las propiedades

  useEffect(() => {
    const area = selected ? areas.current[selected] : null;
    if (area && map.current) {
      map.current.flyToBounds(area.getLatLng().toBounds(area.getRadius() * 2), { duration: 0.8, maxZoom: 14 });
      area.openPopup();
    }
  }, [selected]);

  return (
    <div
      ref={el}
      className="map__leaflet"
      role="region"
      aria-label={label}
      // La ventana del marcador abre la ficha sin recargar la página
      onClick={(e) => {
        const a = (e.target as HTMLElement).closest('a.map-popup');
        if (a) {
          e.preventDefault();
          navigate(a.getAttribute('href')!);
        }
      }}
    />
  );
}

/** Mapa de la ficha: el círculo de la zona aproximada (≈ 3 km) */
export function ZoneMap({ house, label }: { house: House & { lat: number; lng: number }; label: string }) {
  const el = useRef<HTMLDivElement>(null);
  useEffect(() => {
    if (!el.current) return;
    const m = baseMap(el.current);
    const radius = house.areaMeters || AREA;
    m.fitBounds(L.latLng(house.lat, house.lng).toBounds(radius * 2), { padding: [12, 12] });
    L.circle([house.lat, house.lng], { radius, className: 'map-area' }).addTo(m);
    return () => {
      m.remove();
    };
  }, [house.lat, house.lng, house.areaMeters]);
  return <div ref={el} className="map__leaflet" role="region" aria-label={label} />;
}
