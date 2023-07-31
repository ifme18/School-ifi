import * as functions from "firebase-functions";
import * as admin from "firebase-admin";
admin.initializeApp();

// TypeScript equivalent of `_registerAdmin` function from Dart code
export const registerAdmin = functions.https.onCall(async (data, context) => {
  try {
    const { email, name, schoolName, password } = data;

    // Perform your logic to create the admin account here
    // For example, you can use the Firebase Admin SDK to create the admin user
    const userRecord = await admin.auth().createUser({
      email: email,
      displayName: name,
      password: password,
    });

    // Add a custom claim to the user indicating they are an admin
    await admin.auth().setCustomUserClaims(userRecord.uid, { role: "admin" });

    return { status: "success" };
  } catch (error) {
    console.error("Error registering:", error);
    // Return an error message if needed
    return { status: "error", message: "Failed to create an admin account." };
  }
});
