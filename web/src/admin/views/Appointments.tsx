/* Temporal: la fase 6 reemplaza este archivo por la agenda completa. */
export function suggestHouse(_personId: string): { id: string; why: string } | null {
  return null;
}

export function TenantForm({ close }: { a: { property?: string; person?: string }; close: () => void; onDone: (msg: string) => void }) {
  return (
    <>
      <h2 id="dialog-title">Rentar una casa</h2>
      <p className="lead">Este formulario se construye en la fase 6.</p>
      <div className="dialog__actions"><button className="btn" type="button" onClick={close}>Entendido</button></div>
    </>
  );
}
