import { Link } from 'react-router';
import { downloadLink } from '../lib/appLink';
import { fichaOf, photoOf, priceUnit, type House } from '../lib/catalog';
import { money } from '../lib/format';
import { useFavorites } from '../lib/favorites';
import { hasRooms, typeLabel } from '../lib/propertyTypes';
import { Icon } from './Icon';

/** Tarjeta de casa (inicio, listado y casas similares) */
export function PropertyCard({ house: c, alt }: { house: House; alt?: string }) {
  const { isFavorite, toggle } = useFavorites();
  return (
    <article className="card">
      <div className="card__media">
        <div className="photo">
          <img src={photoOf(c)} alt={alt || `${c.name} en ${c.zona}, Cancún`} loading="lazy" />
        </div>
        <span className="badge badge--light">{typeLabel(c.tipo)} · {c.op === 'renta' ? 'En renta' : 'En venta'}</span>
        <label className="fav">
          <input type="checkbox" aria-label={`Guardar ${c.name} en favoritos`} checked={isFavorite(c.name)} onChange={(e) => toggle(c.name, e.target.checked)} />
          <Icon id="heart" />
        </label>
      </div>
      <div className="card__price">
        <strong>{money(c.price)}</strong>
        <span>{priceUnit(c)}</span>
      </div>
      <div className="card__body">
        <h3 className="card__title">
          <Link className="card__link" to={fichaOf(c)}>{c.name}</Link>
        </h3>
        <p className="card__loc">{c.zona}, Cancún</p>
        <ul className="card__specs">
          {hasRooms(c.tipo) && <li><Icon id="bed" />{c.rec} rec.</li>}
          {(hasRooms(c.tipo) || c.banos > 0) && <li><Icon id="bath" />{c.banos} baño{c.banos === 1 ? '' : 's'}</li>}
          {(c.m2 || c.terreno) ? <li><Icon id="area" />{(c.m2 || c.terreno || 0).toLocaleString('en-US')} m²</li> : null}
        </ul>
        {hasRooms(c.tipo) && <p className="card__pets"><Icon id="paw" />{c.pets ? 'Acepta mascotas' : 'No acepta mascotas'}</p>}
        <div className="card__actions">
          <Link className="btn" to={fichaOf(c) + '#contactar'}>Contactar</Link>
          {/* La app recibe la casa: la persona se registra y agenda la visita ahí */}
          <a className="btn btn--secondary" href={downloadLink(c.slug)} target="_blank" rel="noopener">
            <Icon id="download" />
            Descargar la app
          </a>
        </div>
      </div>
    </article>
  );
}
