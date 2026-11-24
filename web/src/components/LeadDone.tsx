import { useEffect, useRef, useState } from 'react';
import { ChangeMyData, type Contact } from './ChangeMyData';
import { AppQr } from './AppQr';
import { Link } from 'react-router';
import { appAccountLink, downloadLink } from '../lib/appLink';
import { fichaOf, inPlace, photoOf, priceUnit, type House } from '../lib/catalog';
import { money } from '../lib/format';
import { Icon } from './Icon';

/** Lo que busca la persona (rentar o comprar): sirve para proponerle casas del inventario. */
export interface Wish {
  op: 'renta' | 'venta';
  min: number | null;
  max: number | null;
  rec: string;
  pets: boolean;
  zone?: string;
  /** Casa que ya eligió (no se vuelve a proponer) */
  slug?: string;
}

/**
 * Casas del inventario que encajan: misma operación, dentro del presupuesto (hasta +15 % del máximo),
 * recámaras, mascotas y, si la escribió, la zona. Las más cercanas al presupuesto primero.
 */
export function matchHouses(houses: House[], w: Wish, max = 3): House[] {
  const rec = Number(w.rec) || 0;
  const target = w.max ?? w.min ?? 0;
  const pick = (useZone: boolean) =>
    houses.filter((h) => h.op === w.op && h.slug !== w.slug && (!w.max || h.price <= w.max * 1.15) && (!w.min || h.price >= w.min * 0.85) &&
      h.rec >= rec && (!w.pets || h.pets) && (!useZone || !w.zone || inPlace(h, w.zone)));
  // Si en esa zona no hay ninguna, se proponen las que encajan en lo demás
  const list = pick(true).length ? pick(true) : pick(false);
  return list.sort((a, b) => Math.abs(a.price - target) - Math.abs(b.price - target)).slice(0, max);
}

/** Tarjeta compacta de una casa sugerida: foto, precio, datos y enlace a su ficha. */
function MatchCard({ h }: { h: House }) {
  return (
    <Link className="match-card" to={fichaOf(h)}>
      <span className="match-card__photo"><img src={photoOf(h)} alt="" loading="lazy" /></span>
      <span className="match-card__body">
        <span className="match-card__price"><strong>{money(h.price)}</strong> {priceUnit(h)}</span>
        <span className="match-card__name">{h.name}</span>
        <span className="match-card__meta">{h.zona} · {h.rec} rec. · {h.banos} baño{h.banos === 1 ? '' : 's'}{h.m2 ? ` · ${h.m2} m²` : ''}</span>
        <span className="match-card__meta">{h.pets ? 'Acepta mascotas' : 'Sin mascotas'}</span>
        <span className="match-card__cta">Ver la casa <Icon id="arrow" size="sm" /></span>
      </span>
    </Link>
  );
}

/**
 * Confirmación centrada después de enviar una solicitud: folio, la cuenta de la app (se crea sola:
 * le llega una contraseña temporal), casas que encajan y, si no hay ninguna, «te la conseguimos».
 */
export function LeadDone({ title, text, folio, houses, wish, email: sentEmail, account: sentAccount, onReset, editToken, name = '', phone = '' }: {
  title: string; text: string; folio: string; houses: House[]; wish?: Wish; email: string; account: 'created' | 'existing' | null; onReset: () => void;
  /** Permiso para «Cambiar mis datos» (2 horas) */
  editToken?: string | null; name?: string; phone?: string;
}) {
  const ref = useRef<HTMLDivElement>(null);
  useEffect(() => ref.current?.focus(), []);
  const matches = wish ? matchHouses(houses, wish) : [];
  // Después de «Cambiar mis datos» se muestran el correo y la cuenta corregidos
  const [contact, setContact] = useState<Contact | null>(editToken ? { folio, token: editToken, name, email: sentEmail, phone } : null);
  const [account, setAccount] = useState(sentAccount);
  const [changed, setChanged] = useState('');
  const email = contact?.email ?? sentEmail;
  return (
    <div className="lead-done">
      <div className="alert alert-success" role="status" tabIndex={-1} ref={ref}>
        <Icon id="check-c" />
        <div><strong>{title}</strong>{text} Tu folio es <b>{folio}</b>.</div>
      </div>

      <section className="lead-done__account" aria-labelledby="cuenta-titulo">
        <span className="lead-done__icon" aria-hidden="true"><Icon id="phone" /></span>
        <h3 id="cuenta-titulo">{account === 'existing' ? 'Sigue tu solicitud en tu app Homiz' : 'Ya tienes tu cuenta en la app Homiz'}</h3>
        <p>
          {account === 'existing'
            ? <>Entra con <b>{email}</b>: en «Mis solicitudes» tu asesor te contesta, te propone casas y agendas tus visitas.</>
            : <>La creamos con <b>{email}</b> y los datos que escribiste. Te enviamos por correo una <b>contraseña temporal</b>: entra con ella, crea la tuya y verás tu solicitud y lo que te proponga tu asesor.</>}
        </p>
        <a className="btn btn--lg" href={downloadLink()} target="_blank" rel="noopener"><Icon id="download" />Descarga nuestra app</a>
        <AppQr href={appAccountLink(email)} title="¿Estás en la computadora? Escanéalo con tu celular"
          text={`Abre la app con tu correo ${email} ya escrito; entra con la contraseña temporal que te enviamos y sigue todo ahí.`} />
        {changed && <p className="alert alert-success is-visible" role="status" style={{ marginTop: '1rem' }}>{changed}</p>}
        {contact && <ChangeMyData contact={contact} onChanged={(c, msg) => { setContact(c); setChanged(msg); setAccount(/temporal nueva/.test(msg) ? 'created' : 'existing'); }} />}
      </section>

      {wish && (matches.length ? (
        <section className="lead-done__matches" aria-labelledby="encajan-titulo">
          <h3 id="encajan-titulo">Mientras tanto, estas casas encajan con lo que buscas</h3>
          <div className="lead-done__cards">{matches.map((h) => <MatchCard key={h.slug} h={h} />)}</div>
        </section>
      ) : (
        <div className="alert alert-info lead-done__none">
          <Icon id="search" />
          <div><strong>Hoy no tenemos una casa así en nuestro inventario, pero te la conseguimos.</strong>Buscaremos entre propietarios y nuestra red una opción con lo que nos pediste y te la propondremos en la app.</div>
        </div>
      ))}

      <div className="lead-done__again">
        <button className="btn btn--secondary btn--lg" type="button" onClick={onReset}>Enviar otra solicitud</button>
        <p className="form-note">Puedes enviar las solicitudes que necesites. La cita de una misma casa solo se agenda una vez; para cambiarla, usa la app.</p>
      </div>
    </div>
  );
}
