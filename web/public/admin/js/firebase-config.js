/* Firebase Cloud Messaging (proyecto homiz-413ff). Estos datos son públicos: identifican la app web, no dan acceso.
   La llave privada del servidor vive solo en backend/firebase-key.json (no se sube al repositorio).
   Lo usan push.js (página) y firebase-messaging-sw.js (avisos con la pestaña cerrada). */
self.ZUGAR_FIREBASE = {
  sdk: 'https://www.gstatic.com/firebasejs/10.14.1/',
  config: {
    apiKey: 'AIzaSyBx7pt0_zgMJBrK0MoFiM91-7tOmRLtX1E',
    authDomain: 'homiz-413ff.firebaseapp.com',
    projectId: 'homiz-413ff',
    storageBucket: 'homiz-413ff.firebasestorage.app',
    messagingSenderId: '781670117568',
    appId: '1:781670117568:web:ce01ba2a927343e7c57d25'
  },
  // Firebase → Configuración del proyecto → Cloud Messaging → Certificados push web
  vapidKey: 'BEJw-k2x765RpmUta5eQpKFwF0Pfp5f8B7yRorKR792pTS0irlUE-dGdiGZj7sC9KDaZf3skbgCH8WpdhV25Elc'
};
