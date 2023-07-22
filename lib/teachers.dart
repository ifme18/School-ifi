import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/models.dart';

class EventUploaderScreen extends StatefulWidget {
  @override
  _EventUploaderScreenState createState() => _EventUploaderScreenState();
}

class _EventUploaderScreenState extends State<EventUploaderScreen> {
  final TextEditingController _classNameController = TextEditingController();
  final TextEditingController _eventTitleController = TextEditingController();
  final TextEditingController _eventDescriptionController =
  TextEditingController();

  void _postEvent() {
    final className = _classNameController.text;
    final eventTitle = _eventTitleController.text;
    final eventDescription = _eventDescriptionController.text;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      final currentUserUid = user.uid;

      final event = {
        'userId': currentUserUid,
        'className': className,
        'eventTitle': eventTitle,
        'eventDescription': eventDescription,
        'timestamp': Timestamp.now(),
      };

      FirebaseFirestore.instance
          .collection('events')
          .add(event)
          .then((value) {
        // Event successfully posted
        _notifyStudents(className, eventTitle);
        _classNameController.clear();
        _eventTitleController.clear();
        _eventDescriptionController.clear();
        // Perform any additional actions after posting the event
      })
          .catchError((error) {
        print('Error posting event: $error');
        // Handle the error appropriately
      });
    }
  }

  void _notifyStudents(String className, String eventTitle) {
    FirebaseFirestore.instance
        .collection('users')
        .where('className', isEqualTo: className)
        .get()
        .then((querySnapshot) {
      querySnapshot.docs.forEach((doc) {
        final studentId = doc.id;
        final student = AppUser.fromJson(doc.data());
        _sendNotification(studentId, student.name, eventTitle);
      });
    })
        .catchError((error) {
      print('Error retrieving students: $error');
      // Handle the error appropriately
    });
  }

  void _sendNotification(String studentId, String studentName, String eventTitle) {
    // Implementation of sending notification to students
    // You can use Firebase Cloud Messaging (FCM) or any other
    // notification service here
    // Example:
    // firebaseMessaging.send(
    //   to: studentId,
    //   notification: MessagingNotification(
    //     title: 'New Event',
    //     body: 'Dear $studentName, a new event "$eventTitle" has been added. Check it out!',
    //   ),
    // );
  }

  @override
  void dispose() {
    _classNameController.dispose();
    _eventTitleController.dispose();
    _eventDescriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Event Uploader'),
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _classNameController,
              decoration: InputDecoration(
                labelText: 'Class Name',
              ),
            ),
            TextField(
              controller: _eventTitleController,
              decoration: InputDecoration(
                labelText: 'Event Title',
              ),
            ),
            TextField(
              controller: _eventDescriptionController,
              decoration: InputDecoration(
                labelText: 'Event Description',
              ),
              maxLines: null,
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _postEvent,
              child: Text('Post Event'),
            ),
          ],
        ),
      ),
    );
  }
}

