/* Avisos de la app web Homiz con la pestaña cerrada (Firebase Cloud Messaging, proyecto homiz-413ff).
   Los mismos datos públicos que lib/core/push/firebase_options.dart. Al tocar el aviso se abre la app
   en la cita (si el aviso es de una cita) o en la bandeja de notificaciones. */
self.addEventListener('notificationclick', function (e) {
  e.notification.close();
  var datos = (e.notification.data && (e.notification.data.FCM_MSG || e.notification.data)) || {};
  var d = datos.data || datos;
  var ruta = d.entity === 'appointment' && d.entityId ? '#/appointments/' + d.entityId : '#/notifications';
  var destino = self.registration.scope + ruta;
  e.waitUntil(self.clients.matchAll({ type: 'window', includeUncontrolled: true }).then(function (ventanas) {
    for (var i = 0; i < ventanas.length; i++) {
      if (ventanas[i].url.indexOf(self.registration.scope) === 0) return ventanas[i].navigate(destino).then(function (v) { return v && v.focus(); });
    }
    return self.clients.openWindow(destino);
  }));
});

importScripts('https://www.gstatic.com/firebasejs/10.14.1/firebase-app-compat.js', 'https://www.gstatic.com/firebasejs/10.14.1/firebase-messaging-compat.js');
firebase.initializeApp({
  apiKey: 'AIzaSyBx7pt0_zgMJBrK0MoFiM91-7tOmRLtX1E',
  authDomain: 'homiz-413ff.firebaseapp.com',
  projectId: 'homiz-413ff',
  storageBucket: 'homiz-413ff.firebasestorage.app',
  messagingSenderId: '781670117568',
  appId: '1:781670117568:web:ce01ba2a927343e7c57d25'
});
firebase.messaging();
