/**
 * Import function triggers from their respective submodules:
 *
 * import {onCall} from "firebase-functions/v2/https";
 * import {onDocumentWritten} from "firebase-functions/v2/firestore";
 *
 * See a full list of supported triggers at https://firebase.google.com/docs/functions
 */

import {onRequest} from "firebase-functions/v2/https";
import * as logger from "firebase-functions/logger";

// Start writing functions
// https://firebase.google.com/docs/functions/typescript

// export const helloWorld = onRequest((request, response) => {
//   logger.info("Hello logs!", {structuredData: true});
//   response.send("Hello from Firebase!");
// });
// index.ts

import * as functions from 'firebase-functions';
import * as admin from 'firebase-admin';
admin.initializeApp();

exports.login = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated
  if (!context.auth) {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated.');
  }

  const { role } = data;

  try {
    const user = context.auth;
    const idTokenResult = await user.getIdTokenResult();

    // Check if the user has the correct role
    const customClaims = idTokenResult.claims;
    if (customClaims && customClaims.role === role) {
      // User has the correct role, return success
      return { status: 'success', role };
    } else {
      // User does not have the correct role, return an error
      throw new functions.https.HttpsError('permission-denied', 'Invalid credentials or role.');
    }
  } catch (error) {
    // Handle errors during login
    console.error('Error logging in:', error);
    throw new functions.https.HttpsError('internal', 'An error occurred during login.');
  }
});

exports.registerAdmin = functions.https.onCall(async (data, context) => {
  // Check if the user is authenticated as an admin
  if (!context.auth || !context.auth.token.role === 'admin') {
    throw new functions.https.HttpsError('unauthenticated', 'User not authenticated as admin.');
  }

  const { email, name, schoolName, password } = data;

  try {
    // Create a new Firebase user with the admin role custom claim
    const userCredential = await admin.auth().createUser({
      email,
      password,
    });

    const user = userCredential.user;
    await user.getIdToken(true);
    await user.updateProfile({ displayName: name });

    // Add custom claim for admin role
    await admin.auth().setCustomUserClaims(user.uid, { role: 'admin' });

    // Additional custom properties for admin
    await admin.firestore().collection('admins').doc(user.uid).set({
      name,
      schoolName,
    });

    return { status: 'success' };
  } catch (error) {
    // Handle errors during registration
    console.error('Error registering:', error);
    throw new functions.https.HttpsError('internal', 'An error occurred during registration.');
  }
});
