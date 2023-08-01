rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {

    // Schools collection
    match /Schools/{schoolId} {
      allow read;
      allow write: if request.auth != null && request.auth.uid == resource.data.Admin;
    }

    // Admins collection
    match /Admins/{adminId} {
      allow read: if request.auth != null && request.auth.uid == adminId;
      allow create: if request.auth != null && request.resource.data.email == request.auth.token.email && request.resource.data.schoolId == request.auth.token.schoolId;
      allow update, delete: if request.auth != null && request.auth.uid == adminId;
    }

    // Students collection
    match /Students/{studentId} {
      allow read: if request.auth != null && (
        request.auth.token.schoolId == resource.data.schoolId ||
        request.auth.uid == resource.data.parentId
      );
      allow create: if request.auth != null && request.resource.data.schoolId == request.auth.token.schoolId && request.resource.data.parentId == request.auth.uid;
      allow update, delete: if request.auth != null && (
        request.auth.uid == resource.data.parentId ||
        request.auth.uid == get(/databases/$(database)/documents/Schools/$(resource.data.schoolId)).data.Admin
      );
    }

    // Examinations collection
    match /Examinations/{examinationId} {
      allow read: if request.auth != null && (
        request.auth.token.schoolId == resource.data.schoolId ||
        request.auth.uid == resource.data.parentId
      );
      allow write: if request.auth != null && request.auth.uid == resource.data.parentId;
    }

    // FeesStatements collection
    match /FeesStatements/{feestatementId} {
      allow read: if request.auth != null && (
        request.auth.token.schoolId == resource.data.schoolId ||
        request.auth.uid == resource.data.parentId
      );
      allow write: if request.auth != null && request.auth.uid == resource.data.parentId;
    }

    // Reports collection
    match /Reports/{reportId} {
      allow read: if request.auth != null && (
        request.auth.token.schoolId == resource.data.schoolId ||
        request.auth.uid == resource.data.parentId
      );
      allow write: if request.auth != null && request.auth.uid == resource.data.parentId;
    }

    // Events collection
    match /Events/{eventId} {
      allow read: if request.auth != null && (
        request.auth.token.schoolId == resource.data.schoolId ||
        resource.data.class == null
      );
      allow write: if request.auth != null && request.auth.uid == resource.data.schoolId;
    }
  }
}





