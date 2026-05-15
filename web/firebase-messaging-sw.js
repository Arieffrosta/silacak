importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-app-compat.js");
importScripts("https://www.gstatic.com/firebasejs/10.12.2/firebase-messaging-compat.js");

firebase.initializeApp({
  apiKey: "API_KEY_KAMU",
  authDomain: "PROJECT_ID.firebaseapp.com",
  projectId: "PROJECT_ID",
  storageBucket: "PROJECT_ID.appspot.com",
  messagingSenderId: "SENDER_ID",
  appId: "APP_ID",
});

const firebaseConfig = {
      apiKey: "AIzaSyCTSS8vMHGPnRGLCwrICnJC7YLOTRPmhBg",
      authDomain: "iot-esp32-lis3dh.firebaseapp.com",
      databaseURL: "https://iot-esp32-lis3dh-default-rtdb.asia-southeast1.firebasedatabase.app",
      projectId: "iot-esp32-lis3dh",
      storageBucket: "iot-esp32-lis3dh.firebasestorage.app",
      messagingSenderId: "1024768647705",
      appId: "1:1024768647705:web:5707554652599e5e16c088",
      measurementId: "G-8GNNT1ENP6"
    };
    