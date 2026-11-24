import { useState } from 'react';
import { Link } from 'react-router';
import { ChangeMyData, type Contact } from '../components/ChangeMyData';
import { useCatalog } from '../components/CatalogProvider';
import { LAST_CONTACT_KEY } from '../components/HouseVisitForm';
import { Icon } from '../components/Icon';
import { appAccountLink, downloadLink } from '../lib/appLink';
import { AppQr } from '../components/AppQr';
import { fichaOf, IMG, photoOf, priceUnit } from '../lib/catalog';
import { money, t12 } from '../lib/format';
import { usePageTitle } from '../lib/usePageTitle';

interface LastContact {
  nombre?: string;
  motivo?: string;
  folio?: string;
  fecha?: string;
  hora?: string;
  asesor?: string;
  slug?: string;
  correo?: string;
  telefono?: string;
  editToken?: string | null;
}

function lastContact(): LastContact {
  try {
    return JSON.parse(sessionStorage.getItem(LAST_CONTACT_KEY) || '{}');
  } catch {
    return {};
  }
}

/** Confirmación después de solicitar una visita desde la ficha de una casa. */
export function Thanks() {
  usePageTitle('¡Gracias! | Zugar Inmobiliaria');
  const { bySlug } = useCatalog();
  const [last, setLast] = useState<LastContact>(lastContact);
  const [changed, setChanged] = useState('');
  const onChanged = (c: Contact, msg: string) => {
    const next = { ...last, nombre: c.name, correo: c.email, telefono: c.phone, editToken: c.token };
    setLast(next);
    setChanged(msg);
    try { sessionStorage.setItem(LAST_CONTACT_KEY, JSON.stringify(next)); } catch { /* sin almacenamiento */ }
  };
  const house = bySlug[last.slug || 'casa-huayacan'];
  const advisor = last.asesor || house?.asesor || 'Mariana Solís';
  const first = advisor.split(' ')[0];
  const name = last.nombre?.split(' ')[0];

  const lead =
    name && last.motivo === 'visita' && last.fecha
      ? `Gracias, ${name}. Tu solicitud para visitar la casa el ${last.fecha.toLowerCase()}${last.hora ? ` a las ${t12(last.hora)}` : ''} fue enviada a ${advisor}. Te escribirá para confirmarla.${last.folio ? ` Tu folio es ${last.folio}.` : ''}`
      : `${name ? `Gracias, ${name}. ` : ''}Tu mensaje fue enviado a ${advisor}. Te contactará al correo o teléfono que compartiste para ayudarte con esta casa.`;

  return (
    <div className="thanks">
      <div className="wrap">
        <div className="thanks__card">
          <span className="thanks__icon"><Icon id="check" /></span>
          <h1>¡Tu próximo hogar está más cerca!</h1>
          <p>{lead}</p>
          {last.correo && <p className="small">Tu cuenta de la app Homiz es <b>{last.correo}</b>: ahí te llegó tu contraseña temporal y verás tu cita.</p>}
          {last.correo && (
            <AppQr href={appAccountLink(last.correo)} title="Tu cita ya está en la app: escanéalo con tu celular"
              text="Entra con tu correo y la contraseña temporal que te enviamos; ahí verás cuándo se confirme tu cita y la ubicación exacta." />
          )}
          {changed && <p className="alert alert-success is-visible" role="status">{changed}</p>}
          {last.editToken && last.folio && last.correo && (
            <ChangeMyData contact={{ folio: last.folio, token: last.editToken, name: last.nombre ?? '', email: last.correo, phone: last.telefono ?? '' }} onChanged={onChanged} />
          )}
          {house && (
            <div className="mini-home">
              <div className="photo"><img src={photoOf(house)} alt={`${house.name} en ${house.zona}, Cancún`} loading="lazy" /></div>
              <div>
                <strong>{house.name}</strong>
                <span>Cancún, Quintana Roo{house.code ? ` · Clave ${house.code}` : ''}</span>
                <p className="mini-price">{money(house.price)} {priceUnit(house)}</p>
              </div>
            </div>
          )}
          <div className="agent">
            <div className="photo photo--portrait">
              {/^Mariana/.test(advisor) && <img src={IMG + 'asesora-mariana-solis.jpg'} alt={`Fotografía de ${advisor}, asesora inmobiliaria`} loading="lazy" />}
            </div>
            <div>
              <strong>{advisor}</strong>
              <span>Asesora · Zugar Inmobiliaria</span>
              <span className="verified"><Icon id="check-c" size="sm" />Asesora certificada</span>
            </div>
          </div>
          <div className="next-box">
            <strong>¿Qué sigue?</strong>
            <p>Ten a la mano tus horarios disponibles para coordinar una visita. Así suele ser el proceso:</p>
            <ol>
              <li>{first} te escribe en menos de un día hábil.</li>
              <li>Acuerdan día y hora para conocer la casa.</li>
              <li>Resuelven juntos dudas de precio, crédito y documentos.</li>
            </ol>
          </div>
          <div className="thanks__actions">
            <Link className="btn btn--lg" to={house ? fichaOf(house) : '/propiedades'}><Icon id="left" />Volver a la propiedad</Link>
            <a className="btn btn--secondary btn--lg" href={downloadLink(house?.slug)} target="_blank" rel="noopener"><Icon id="download" />Descarga nuestra app</a>
          </div>
          <p className="thanks__foot">¿No recibiste respuesta? Llámanos al <a href="tel:+529985550142">+52 998 555 0142</a>.</p>
        </div>
      </div>
    </div>
  );
}
