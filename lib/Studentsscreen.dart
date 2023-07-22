
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Models/models.dart';
import 'package:csv/csv.dart';
import 'AI.dart';

class StudentScreen extends StatefulWidget {
  @override
  _StudentScreenState createState() => _StudentScreenState();
}

class _StudentScreenState extends State<StudentScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final auth.FirebaseAuth _auth = auth.FirebaseAuth.instance;

  Future<AppUser?> _fetchCurrentUser() async {
    AppUser? currentUser;
    if (_auth.currentUser != null) {
      DocumentSnapshot userSnapshot = await _firestore
          .collection('users')
          .doc(_auth.currentUser!.uid)
          .get();
      currentUser = AppUser.fromJson(userSnapshot.data() as Map<String, dynamic>);
    }
    return currentUser;
  }

  Future<List<Exam>> _fetchExams() async {
    AppUser? currentUser = await _fetchCurrentUser();
    List<Exam> examList = [];

    if (currentUser != null) {
      QuerySnapshot examSnapshot = await _firestore
          .collection('exams')
          .where('className', isEqualTo: currentUser.className)
          .get();

      examList = examSnapshot.docs
          .map((doc) => Exam.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }

    return examList;
  }

  Future<List<Payment>> _fetchPayments() async {
    AppUser? currentUser = await _fetchCurrentUser();
    List<Payment> paymentList = [];

    if (currentUser != null) {
      QuerySnapshot paymentSnapshot = await _firestore
          .collection('payments')
          .where('userId', isEqualTo: currentUser.uid)
          .get();

      paymentList = paymentSnapshot.docs
          .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
          .toList();
    }

    return paymentList;
  }

  Future<String> _generateCsv(List<dynamic> dataList) async {
    List<List<dynamic>> csvDataList = [];
    // Generate header row
    csvDataList.add(dataList[0].toJson().keys.toList());
    // Generate data rows
    for (var data in dataList) {
      csvDataList.add(data.toJson().values.toList());
    }
    return const ListToCsvConverter().convert(csvDataList);
  }

  Future<void> _exportDataToCsv(List<dynamic> dataList) async {
    String csvData = await _generateCsv(dataList);
    // You can use the csv package to write a CSV file to local storage
    // or use a CSV export library to send the data to email or other apps
    print(csvData); // Just printing the CSV data for demonstration
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<auth.User?>(
      stream: _auth.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data != null) {
          // User is authenticated
          auth.User? currentUser = snapshot.data;
          if (currentUser != null && (currentUser.emailVerified ?? false)) {
            // Check user's role
            return FutureBuilder<AppUser?>(
              future: _fetchCurrentUser(),
              builder: (BuildContext context, AsyncSnapshot<AppUser?> snapshot) {
                if (snapshot.hasData) {
                  AppUser? currentUser = snapshot.data;
                  if (currentUser?.role == 'student') {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Student Screen'),
                      ),
                      body: Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.school),
                                  onPressed: () async {
                                    List<Exam> examList = await _fetchExams();
                                    _exportDataToCsv(examList);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.attach_money),
                                  onPressed: () async {
                                    List<Payment> paymentList = await _fetchPayments();
                                    _exportDataToCsv(paymentList);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.event),
                                  onPressed: () {
                                    // Navigate to events screen
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.question_answer_rounded),
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => Artificial(), // Replace "ArtificialScreen" with your screen's class name
                                      ),
                                    );
                                  },
                                ),

                              ],
                            ),
                            const SizedBox(height: 20,),
                            Text('Hello, ${currentUser?.name ?? ''}!'),
                          ],
                        ),
                      ),
                    );
                  } else {
                    return Scaffold(
                      appBar: AppBar(
                        title: const Text('Unauthorized'),
                      ),
                      body: const Center(
                        child: Text('You are not authorized to access this screen.'),
                      ),
                    );
                  }
                } else {
                  return const Center(child: CircularProgressIndicator());
                }
              },
            );
          } else {
            return Scaffold(
              appBar: AppBar(
                title: const Text('Verification Required'),
              ),
              body: const Center(
                child: Text('Please verify your email to access this screen.'),
              ),
            );
          }
        } else {
          return Scaffold(
            appBar: AppBar(
              title: const Text('Login Required'),
            ),
            body: const Center(
              child: Text('Please log in to access this screen.'),
            ),
          );
        }
      },
    );
  }
}











