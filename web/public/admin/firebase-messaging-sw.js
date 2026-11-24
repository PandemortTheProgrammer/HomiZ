/* Avisos del panel con la pestaña cerrada o en segundo plano (Firebase Cloud Messaging).
   Firebase muestra la notificación; al tocarla se abre (o se enfoca) el panel en la sección del aviso. */
importScripts('js/firebase-config.js');

var SECCIONES = { appointment: '#/citas', property: '#/propiedades', client: '#/personas', lead: '#/personas' };

self.addEventListener('notificationclick', function (e) {
  e.notification.close();
  var datos = (e.notification.data && (e.notification.data.FCM_MSG || e.notification.data)) || {};
  var entity = (datos.data && datos.data.entity) || datos.entity || '';
  var destino = self.registration.scope + 'index.html' + (SECCIONES[entity] || '#/resumen');
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (ventanas) {
    for (var i = 0; i < ventanas.length; i++) {
      if (ventanas[i].url.indexOf(self.registration.scope) === 0) return ventanas[i].navigate(destino).then(function (v) { return v && v.focus(); });
    }
    return self.clients.openWindow(destino);
  }));
});

importScripts(self.ZUGAR_FIREBASE.sdk + 'firebase-app-compat.js', self.ZUGAR_FIREBASE.sdk + 'firebase-messaging-compat.js');
firebase.initializeApp(self.ZUGAR_FIREBASE.config);
firebase.messaging();
