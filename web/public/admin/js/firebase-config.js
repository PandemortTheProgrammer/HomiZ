/* Firebase Cloud Messaging (proyecto homiz-413ff). Estos datos son públicos: identifican la app web, no dan acceso.
   La llave privada del servidor vive solo en backend/firebase-key.json (no se sube al repositorio).
   Lo usan push.js (página) y firebase-messaging-sw.js (avisos con la pestaña cerrada). */
self.ZUGAR_FIREBASE = {
  sdk: 'https://www.gstatic.com/firebasejs/10.14.1/',
  config: {
    apiKey: 'TU_API_KEY',
    authDomain: 'homiz-413ff.firebaseapp.com',
    projectId: 'homiz-413ff',
    storageBucket: 'homiz-413ff.firebasestorage.app',
    messagingSenderId: 'TU_SENDER_ID',
    appId: 'TU_APP_ID'
  },
  // Firebase → Configuración del proyecto → Cloud Messaging → Certificados push web
  vapidKey: 'TU_LLAVE_VAPID'
};
