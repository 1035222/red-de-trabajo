importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-app-compat.js');
importScripts('https://www.gstatic.com/firebasejs/11.10.0/firebase-messaging-compat.js');

firebase.initializeApp({
  apiKey: 'AIzaSyA9btCF5sEp-CQQ0V8Zq_wLsrc6lLCSjjs',
  appId: '1:867847161323:web:93984ec1d70c918a3085ae',
  messagingSenderId: '867847161323',
  projectId: 'red-de-trabajo',
  authDomain: 'red-de-trabajo.firebaseapp.com',
  storageBucket: 'red-de-trabajo.firebasestorage.app',
});

firebase.messaging();
