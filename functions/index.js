const functions = require("firebase-functions");
const admin = require("firebase-admin");
// const axios = require("axios");

admin.initializeApp();

exports.testNotification = functions.https.onRequest(async (req, res) => {
  try {
    console.log("Fetching FCM tokens...");

    const usersSnapshot = await admin.firestore().collection("users").get();
    const tokens = [];

    usersSnapshot.forEach((doc) => {
      const data = doc.data();
      if (data.fcmToken) tokens.push(data.fcmToken);
    });

    if (tokens.length === 0) {
      console.log("No FCM tokens found");
      return res.send("No tokens found");
    }

    const message = {
      notification: {
        title: "Test Notification 🌞",
        body: "This is a test notification for Spark plan users",
      },
      tokens,
    };

    // ❌ Send notification is commented out for Spark plan / emulator
    // const response = await admin.messaging().sendMulticast(message);

    console.log("✅ Would send notification to tokens:", tokens);
    console.log("Message:", message);

    res.send(`✅ Function executed successfully. Tokens: ${tokens.length}`);
  } catch (error) {
    console.error("Error sending notification:", error);
    res.status(500).send(error);
  }
});



// exports.dailyGoodMorningNotification = functions.pubsub
//   .schedule("0 7 * * *") // Daily 7 AM
//   .timeZone("Asia/Kolkata")
//   .onRun(async (context) => {
//     try {
//       console.log("Fetching FCM tokens...");
//       const usersSnapshot = await admin.firestore().collection("users").get();

//       if (usersSnapshot.empty) return null;

//       const tokens = [];
//       usersSnapshot.forEach((doc) => {
//         const data = doc.data();
//         if (data.fcmToken) tokens.push(data.fcmToken);
//       });

//       if (tokens.length === 0) return null;

//       // Fetch APIs
//     //   const [weatherRes, quoteRes, festivalRes] = await Promise.all([
//     //     axios.get("https://api.openweathermap.org/data/2.5/weather?q=Delhi&appid=YOUR_API_KEY&units=metric"),
//     //     axios.get("https://zenquotes.io/api/random"),
//     //     axios.get("https://YOUR_FESTIVAL_API_ENDPOINT"),
//     //   ]);

//     //   const weather = `${weatherRes.data.weather[0].main}, ${weatherRes.data.main.temp}°C`;
//     //   const quote = quoteRes.data[0].q + " — " + quoteRes.data[0].a;

//     //   const today = new Date().toISOString().slice(0, 10);
//     //   let todayFestival = "";
//     //   if (festivalRes.data && Array.isArray(festivalRes.data)) {
//     //     const todayData = festivalRes.data.find(f => f.date === today || f.date_local === today);
//     //     if (todayData) todayFestival = `🎉 ${todayData.name}`;
//     //   }

//       const title = "Good Morning 🌞";
//     //   const body = `🌤 Weather: ${weather}\n${todayFestival ? todayFestival + "\n" : ""}💬 ${quote}`;
//     const body = "This is test global notification";

//       const message = { notification: { title, body }, tokens };
//       const response = await admin.messaging().sendMulticast(message);
//       console.log(`✅ Sent to ${response.successCount} users`);
//     } catch (error) {
//       console.error("Error sending notification:", error);
//     }
//   });

// exports.dailyGoodMorningNotification = functions.pubsub
//   .schedule("*/2 * * * *") // Every 2 minutes
//   .timeZone("Asia/Kolkata")
//   .onRun(async (context) => {
//     try {
//       console.log("Fetching FCM tokens...");
//       const usersSnapshot = await admin.firestore().collection("users").get();

//       if (usersSnapshot.empty) return null;

//       const tokens = [];
//       usersSnapshot.forEach((doc) => {
//         const data = doc.data();
//         if (data.fcmToken) tokens.push(data.fcmToken);
//       });

//       if (tokens.length === 0) return null;

//       const title = "Good Morning 🌞";
//       const body = "This is test global notification";

//       const message = { notification: { title, body }, tokens };
//       const response = await admin.messaging().sendMulticast(message);
//       console.log(`✅ Sent to ${response.successCount} users`);
//     } catch (error) {
//       console.error("Error sending notification:", error);
//     }
//   });
