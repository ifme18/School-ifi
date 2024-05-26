import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

exports.registerAdmin = functions.https.onCall(async (data) => {
  const {email, name, schoolId, password} = data;

  try {
    const userCredential = await admin.auth().createUser({
      email,
      password,
    });

    const user = userCredential;
    await admin.auth().setCustomUserClaims(user.uid, {role: "admin"});

    await admin.firestore().collection("admins").doc(user.uid).set({
      name,
      schoolId,
    });

    return {status: "success"};
  } catch (error) {
    console.error("Error registering:", error);
    throw new functions.https.HttpsError(
      "internal", "An error occurred during registration."
    );
  }
});

exports.registerTeacher = functions.https.onCall(async (data, context) => {
  const {email, phoneNumber, name, schoolId, password, imageUrl, tscNumber} = data;

  try {
    // Create user with email and password or phone number
    let userCredential;
    if (email && phoneNumber) {
      userCredential = await admin.auth().createUser({
        email,
        password,
        phoneNumber,
      });
    } else if (email) {
      userCredential = await admin.auth().createUser({
        email,
        password,
      });
    } else if (phoneNumber) {
      userCredential = await admin.auth().createUser({
        phoneNumber,
      });
    } else {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Either email or phone number is required."
      );
    }

    // Set custom user claim for role as teacher
    await admin.auth().setCustomUserClaims(userCredential.user.uid, {role: "teacher"});

    // Store teacher details in Firestore
    await admin.firestore().collection("teachers").doc(userCredential.user.uid).set({
      name,
      schoolId,
      imageUrl,
      tscNumber,
      contactInfo: {
        email: email || null,
        phoneNumber: phoneNumber || null,
      },
    });

    return {status: "success"};
  } catch (error) {
    console.error("Error registering:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred during registration."
    );
  }
});

exports.registerStudent = functions.https.onCall(async (data) => {
  const {email, phoneNumber, name, regno, schoolId, classId, password} = data;

  try {
    // Create user with email and password or phone number
    let userCredential;
    if (email && phoneNumber) {
      userCredential = await admin.auth().createUser({
        email,
        password,
        phoneNumber,
      });
    } else if (email) {
      userCredential = await admin.auth().createUser({
        email,
        password,
      });
    } else if (phoneNumber) {
      userCredential = await admin.auth().createUser({
        phoneNumber,
      });
    } else {
      throw new functions.https.HttpsError(
        "invalid-argument",
        "Either email or phone number is required."
      );
    }

    const user = userCredential.user;

    // Set custom user claim for role as student
    await admin.auth().setCustomUserClaims(user.uid, {role: "student"});

    // Store student details in Firestore
    await admin.firestore().collection("students").doc(user.uid).set({
      name,
      regno,
      schoolId,
      classId,
      contactInfo: {
        email: email || null,
        phoneNumber: phoneNumber || null,
      },
    });

    return {status: "success"};
  } catch (error) {
    console.error("Error registering:", error);
    throw new functions.https.HttpsError(
      "internal",
      "An error occurred during registration."
    );
  }
});

exports.sendNotificationOnNewEvent = functions.firestore
  .document('events/{eventId}')
  .onCreate(async (snapshot, context) => {
    const newEvent = snapshot.data();
    const schoolId = newEvent.schoolId;

    // Get the list of device tokens for the given school
    const querySnapshot = await admin
      .firestore()
      .collection('admins')
      .where('schoolId', '==', schoolId)
      .get();

    const tokens: string[] = [];
    querySnapshot.forEach((doc) => {
      const token = doc.data().fcmToken;
      if (token) {
        tokens.push(token);
      }
    });

    // Send a notification to all device tokens
    const payload = {
      notification: {
        title: 'New Event',
        body: `New event "${newEvent.title}" has been created.`,
      },
    };

    return admin.messaging().sendToDevice(tokens, payload);
  });


exports.sendWelcomeEmail = functions.https.onCall(async (data, context) => {
  const email = data.email;

  try {
    const mailOptions = {
      from: 'your-email@example.com',
      to: email,
      subject: 'Welcome to SchoolIfi',
      text: 'You have been registered successfully on SchoolIfi.',
    };

    await admin.messaging().sendEmail(mailOptions);
    console.log(`Welcome email sent to ${email}`);
    return { success: true };
  } catch (error) {
    console.error('Error sending welcome email:', error);
    return { success: false, error: error.message };
  }
});
