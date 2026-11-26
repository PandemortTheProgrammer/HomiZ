import type { useOverlay } from '../components/Overlay';
import { TenantForm } from './Appointments';

/* Temporal: la fase 8 reemplaza este archivo por el módulo de rentas. */
export function openRental(open: ReturnType<typeof useOverlay>['open'], onDone: (m: string) => void, pre: { property?: string; person?: string } = {}) {
  open((close) => <TenantForm a={pre} close={close} onDone={onDone} />, { wide: true });
}
