const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp({
  databaseURL:
    "https://iot-esp32-lis3dh-default-rtdb.asia-southeast1.firebasedatabase.app",
});

exports.onEventDetected = functions
  .region("asia-southeast1")
  .database.ref("/devices/{deviceId}/event")
  .onWrite(async (change, context) => {
    const deviceId = context.params.deviceId;

    // jika event dihapus → abaikan
    if (!change.after.exists()) return null;

    const event = change.after.val();

    console.log("🚨 EVENT MASUK:", { deviceId, event });

    /* ================================
       1. SIMPAN KE FIRESTORE
    ================================= */
    await admin
      .firestore()
      .collection("accidents")
      .add({
        deviceId,
        accel: {
          x: event.accel_x ?? null,
          y: event.accel_y ?? null,
          z: event.accel_z ?? null,
        },
        latitude: event.latitude ?? null,
        longitude: event.longitude ?? null,
        eventTime: event.event_time_wib ?? null,
        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

    /* ================================
       2. CARI MODULE → USER
    ================================= */
    const moduleSnap = await admin
      .firestore()
      .collection("modules")
      .doc(deviceId)
      .get();

    if (!moduleSnap.exists) {
      console.log("❌ Module tidak ditemukan:", deviceId);
      return null;
    }

    const userId = moduleSnap.data().userId;

    /* ================================
       3. AMBIL FCM TOKEN
    ================================= */
    const userSnap = await admin
      .firestore()
      .collection("users")
      .doc(userId)
      .get();

    const fcmToken = userSnap.data()?.fcmToken;
    if (!fcmToken) {
      console.log("❌ FCM token tidak tersedia");
      return null;
    }

    /* ================================
       4. KIRIM NOTIFIKASI 🚀
    ================================= */
    await admin.messaging().send({
      token: fcmToken,
      notification: {
        title: "🚨 EVENT PERANGKAT",
        body: `Perangkat ${deviceId} mengirim data event`,
      },
      data: {
        deviceId,
        latitude: String(event.latitude ?? ""),
        longitude: String(event.longitude ?? ""),
        eventTime: String(event.event_time_wib ?? ""),
      },
    });

    console.log("📲 Notifikasi terkirim ke user:", userId);
    return null;
  });
