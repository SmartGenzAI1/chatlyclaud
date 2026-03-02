// Firebase Cloud Messaging Service Worker
// Required for FCM push notifications on web
// Place this file in the web/ directory

importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/10.7.1/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyD8F8O5dENFxGnYEQF0vHfb174r3TtdY4k',
  authDomain: 'bubbldrop2025.firebaseapp.com',
  projectId: 'bubbldrop2025',
  storageBucket: 'bubbldrop2025.firebasestorage.app',
  messagingSenderId: '455624929536',
  appId: '1:455624929536:web:a5cf99597b88413fe103e5',
  measurementId: 'G-4KDQMLK235',
});

const messaging = firebase.messaging();

// Handle background messages
messaging.onBackgroundMessage((payload) => {
  console.log('[firebase-messaging-sw.js] Background message received:', payload);

  const notificationTitle = payload.notification?.title || 'New Message';
  const notificationOptions = {
    body: payload.notification?.body || '',
    icon: '/icons/Icon-192.png',
    badge: '/icons/Icon-192.png',
    tag: payload.data?.chatId || 'chatly-notification',
  };

  self.registration.showNotification(notificationTitle, notificationOptions);
});

// Handle notification click
self.addEventListener('notificationclick', (event) => {
  event.notification.close();
  event.waitUntil(
    clients.openWindow('/')
  );
});
