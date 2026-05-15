const functions = require("firebase-functions/v1");
const admin = require("firebase-admin");

admin.initializeApp({
  databaseURL:
    "https://iot-esp32-lis3dh-default-rtdb.asia-southeast1.firebasedatabase.app",
});

const db = admin.firestore();
const rtdb = admin.database();

/* =====================================================
   🚨 EVENT KECELAKAAN → FIRESTORE + NOTIFIKASI
===================================================== */
exports.onEventDetected = functions
  .region("asia-southeast1")
  .database.ref("/devices/{deviceId}/event")
  .onWrite(async (change, context) => {
    try {
      const deviceId = context.params.deviceId;

      /* =====================================================
         ❌ EVENT DIHAPUS
      ===================================================== */
      if (!change.after.exists()) {
        console.log("⏳ Event kosong");
        return null;
      }

      const event = change.after.val();

      console.log("🚨 EVENT MASUK:", {
        deviceId,
        event,
      });

      /* =====================================================
         🔍 CARI MODULE
      ===================================================== */
      const moduleSnap = await db
        .collection("modules")
        .doc(deviceId)
        .get();

      if (!moduleSnap.exists) {
        console.log("❌ Module tidak ditemukan:", deviceId);
        return null;
      }

      const userId = moduleSnap.data().userId;

      if (!userId) {
        console.log("❌ userId tidak ditemukan");
        return null;
      }

      /* =====================================================
         🔒 ANTI SPAM 5 MENIT
      ===================================================== */
      const lockRef = rtdb.ref(`/devices/${deviceId}/lock`);

      const now = Date.now();

      let allowed = false;

      await lockRef.transaction((current) => {
        if (current === null || now - current > 300000) {
          allowed = true;
          return now;
        }

        return current;
      });

      if (!allowed) {
        console.log("⏳ Skip notif (cooldown aktif)");
        return null;
      }

      /* =====================================================
         ✅ UPDATE ACCIDENT REALTIME
         TIDAK SPAM DOCUMENT
      ===================================================== */
      await db.collection("accidents").doc(deviceId).set(
        {
          deviceId,
          userId,

          accel: {
            x: Number(event.accel_x ?? 0),
            y: Number(event.accel_y ?? 0),
            z: Number(event.accel_z ?? 0),
          },

          magnitude: Number(event.accel_total ?? 0),

          latitude: Number(event.latitude ?? 0),
          longitude: Number(event.longitude ?? 0),

          status: "active",

          eventTime: event.event_time_wib ?? "-",

          updatedAt: admin.firestore.FieldValue.serverTimestamp(),
        },
        { merge: true }
      );

      console.log("✅ Accident realtime diperbarui");

      /* =====================================================
         ✅ SIMPAN KE HISTORY
         HANYA 1X / 5 MENIT
      ===================================================== */
      await db.collection("history").add({
        deviceId,
        userId,

        accel: {
          x: Number(event.accel_x ?? 0),
          y: Number(event.accel_y ?? 0),
          z: Number(event.accel_z ?? 0),
        },

        magnitude: Number(event.accel_total ?? 0),

        latitude: Number(event.latitude ?? 0),
        longitude: Number(event.longitude ?? 0),

        status: "recorded",

        eventTime: event.event_time_wib ?? "-",

        createdAt: admin.firestore.FieldValue.serverTimestamp(),
      });

      console.log("✅ History accident disimpan");

      /* =====================================================
         🔍 AMBIL FCM TOKEN USER
      ===================================================== */
      const userSnap = await db
        .collection("users")
        .doc(userId)
        .get();

      if (!userSnap.exists) {
        console.log("❌ User tidak ditemukan");
        return null;
      }

      const fcmToken = userSnap.data()?.fcmToken;

      if (!fcmToken) {
        console.log("❌ FCM token tidak tersedia");
        return null;
      }

      /* =====================================================
         📲 KIRIM PUSH NOTIFICATION
      ===================================================== */
      await admin.messaging().send({
        token: fcmToken,

        notification: {
          title: "🚨 PERINGATAN KECELAKAAN",
          body: `Kecelakaan terdeteksi pada perangkat ${deviceId}`,
        },

        data: {
          deviceId: String(deviceId),

          latitude: String(event.latitude ?? ""),
          longitude: String(event.longitude ?? ""),

          magnitude: String(event.accel_total ?? ""),

          eventTime: String(event.event_time_wib ?? ""),
        },

        android: {
          priority: "high",
        },
      });

      console.log("📲 Notifikasi berhasil dikirim");

      return null;
    } catch (error) {
      console.error("❌ ERROR:", error);

      return null;
    }
  });

/* =====================================================
   🗺️ TRACKING RTDB → FIRESTORE
===================================================== */
exports.syncTrackingToFirestore = functions
  .region("asia-southeast1")
  .database.ref("/devices/{deviceId}")
  .onUpdate(async (change, context) => {
    try {
      const deviceId = context.params.deviceId;

      const data = change.after.val();

      if (!data) return null;

      const lat = Number(data.latitude ?? 0);
      const lng = Number(data.longitude ?? 0);

      /* =====================================================
         ❌ GPS BELUM VALID
      ===================================================== */
      if (lat === 0 || lng === 0) {
        console.log("⏳ GPS belum valid");
        return null;
      }

      const now = Date.now();

      /* =====================================================
         🔒 ANTI SPAM TRACKING 5 DETIK
      ===================================================== */
      const lastRef = rtdb.ref(`/devices/${deviceId}/lastTrack`);

      const snap = await lastRef.once("value");

      const lastTime = snap.exists() ? snap.val() : 0;

      if (now - lastTime < 5000) {
        console.log("⏳ Skip tracking");
        return null;
      }

      await lastRef.set(now);

      /* =====================================================
         ✅ SIMPAN TRACKING
      ===================================================== */
      await db
        .collection("tracks")
        .doc(deviceId)
        .collection("points")
        .add({
          lat,
          lng,
          speed: Number(data.speed ?? 0),
          timestamp: admin.firestore.FieldValue.serverTimestamp(),
        });

      console.log("✅ Tracking masuk Firestore");

      return null;
    } catch (error) {
      console.error("❌ ERROR TRACKING:", error);

      return null;
    }
  });

/* =====================================================
   🧹 DELETE ACCIDENT REALTIME
===================================================== */
exports.deleteAllAccidents = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    try {
      const userId = data.userId;

      if (!userId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "userId wajib diisi"
        );
      }

      const snapshot = await db
        .collection("accidents")
        .where("userId", "==", userId)
        .get();

      let batch = db.batch();
      let count = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);

        count++;

        if (count === 500) {
          await batch.commit();

          batch = db.batch();

          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      console.log("🧹 Accident realtime dihapus");

      return {
        success: true,
        message: "Accident deleted",
      };
    } catch (error) {
      console.error(error);

      throw new functions.https.HttpsError(
        "internal",
        error.message
      );
    }
  });

/* =====================================================
   🧹 DELETE HISTORY ACCIDENT
===================================================== */
exports.deleteHistoryAccidents = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    try {
      const userId = data.userId;

      if (!userId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "userId wajib diisi"
        );
      }

      const snapshot = await db
        .collection("history")
        .where("userId", "==", userId)
        .get();

      let batch = db.batch();
      let count = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);

        count++;

        if (count === 500) {
          await batch.commit();

          batch = db.batch();

          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      console.log("🧹 History accident dihapus");

      return {
        success: true,
        message: "History deleted",
      };
    } catch (error) {
      console.error(error);

      throw new functions.https.HttpsError(
        "internal",
        error.message
      );
    }
  });

/* =====================================================
   🧹 DELETE TRACK HISTORY
===================================================== */
exports.deleteTrackHistory = functions
  .region("asia-southeast1")
  .https.onCall(async (data, context) => {
    try {
      const deviceId = data.deviceId;

      if (!deviceId) {
        throw new functions.https.HttpsError(
          "invalid-argument",
          "deviceId wajib diisi"
        );
      }

      const snapshot = await db
        .collection("tracks")
        .doc(deviceId)
        .collection("points")
        .get();

      let batch = db.batch();
      let count = 0;

      for (const doc of snapshot.docs) {
        batch.delete(doc.ref);

        count++;

        if (count === 500) {
          await batch.commit();

          batch = db.batch();

          count = 0;
        }
      }

      if (count > 0) {
        await batch.commit();
      }

      console.log("🧹 Tracking dihapus");

      return {
        success: true,
        message: "Tracking deleted",
      };
    } catch (error) {
      console.error(error);

      throw new functions.https.HttpsError(
        "internal",
        error.message
      );
    }
  });