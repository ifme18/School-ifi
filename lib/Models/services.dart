
import 'package:cloud_firestore/cloud_firestore.dart';

import 'models.dart';

final FirebaseFirestoreService dbService = FirebaseFirestoreService();


class FirebaseFirestoreService {
 final CollectionReference _usersCollectionRef =
 FirebaseFirestore.instance.collection('users');
 final CollectionReference _paymentsCollectionRef =
 FirebaseFirestore.instance.collection('payments');
 final CollectionReference _examsCollectionRef =
 FirebaseFirestore.instance.collection('exams');
 final CollectionReference _schoolsCollectionRef =
 FirebaseFirestore.instance.collection('schools');

 Future<void> updateUserRecord(AppUser user) async {
  await _usersCollectionRef.doc(user.uid).set(user.toJson());
 }

 Future<void> deletePaymentRecord(String paymentId) async {
  await _paymentsCollectionRef.doc(paymentId).delete();
 }

 Future<List<Payment>> fetchPaymentsOfUser(String userId) async {
  final QuerySnapshot querySnapshot =
  await _paymentsCollectionRef.where('userId', isEqualTo: userId).get();
  return querySnapshot.docs
      .map((doc) => Payment.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
 }

 Future<void> updatePaymentRecord(Payment payment) async {
  await _paymentsCollectionRef
      .doc(payment.paymentId)
      .set(payment.toJson());
 }

 Future<List<Exam>> fetchExamsOfUser(String userId) async {
  final QuerySnapshot querySnapshot =
  await _examsCollectionRef.where('userId', isEqualTo: userId).get();
  return querySnapshot.docs
      .map((doc) => Exam.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
 }

 Future<void> updateExamRecord(Exam exam) async {
  await _examsCollectionRef.doc(exam.examId).set(exam.toJson());
 }

 Future<List<School>> fetchAllSchools() async {
  final QuerySnapshot querySnapshot = await _schoolsCollectionRef.get();
  return querySnapshot.docs
      .map((doc) => School.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
 }

 Future<void> updateSchoolRecord(School school) async {
  await _schoolsCollectionRef.doc(school.schoolId).set(school.toJson());
 }

 Future<List<AppUser>> fetchAllUsers(String adminEmail) async {
  final QuerySnapshot querySnapshot = await _usersCollectionRef.get();
  return querySnapshot.docs
      .map((doc) => AppUser.fromJson(doc.data() as Map<String, dynamic>))
      .toList();
 }
}