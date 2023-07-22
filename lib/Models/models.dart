import 'package:cloud_firestore/cloud_firestore.dart';

/// Represents an App user.
class AppUser {
  final String uid;
  final String name;
  final String email;
  final String className;
  final String schoolName;
  final Role role;

  /// Creates an instance of [AppUser].
  AppUser({
    required this.uid,
    required this.name,
    required this.email,
    required this.className,
    required this.schoolName,
    required this.role,
  });

  /// Creates an instance of [AppUser] from a JSON object.
  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: json['uid'],
      name: json['name'],
      email: json['email'],
      className: json['className'],
      schoolName: json['schoolName'],
      role: Role.values.firstWhere((role) => role.toString() == 'Role.${json['role']}'),
    );
  }

  /// Converts an instance of [AppUser] to a JSON object.
  Map<String, dynamic> toJson() => {
    'uid': uid,
    'name': name,
    'email': email,
    'className': className,
    'schoolName': schoolName,
    'role': role.toString().split('.').last,
  };
}

/// Represents a payment.
class Payment {
  final String paymentId;
  final String userId;
  final double amount;
  final String description;
  final DateTime timestamp;

  /// Creates an instance of [Payment].
  Payment({
    required this.paymentId,
    required this.userId,
    required this.amount,
    required this.description,
    required this.timestamp,
  });

  /// Creates an instance of [Payment] from a JSON object.
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      paymentId: json['paymentId'],
      userId: json['userId'],
      amount: json['amount'],
      description: json['description'],
      timestamp: DateTime.parse(json['timestamp']),
    );
  }

  /// Converts an instance of [Payment] to a JSON object.
  Map<String, dynamic> toJson() => {
    'paymentId': paymentId,
    'userId': userId,
    'amount': amount,
    'description': description,
    'timestamp': timestamp.toIso8601String(),
  };
}

class Exam {
  final String examId;
  final String userId;
  final String className;
  final String examName;
  final String teacherName;
  final String subject;
  final Map<String, double> marks;
  final DateTime timestamp;

  Exam({
    required this.examId,
    required this.userId,
    required this.className,
    required this.examName,
    required this.teacherName,
    required this.subject,
    required this.marks,
    required this.timestamp,
  });

  double get averageMarks {
    if (marks.isEmpty) {
      return 0.0;
    } else {
      double sum = marks.values.reduce((a, b) => a + b);
      double count = marks.length.toDouble();
      return sum / count;
    }
  }

  factory Exam.fromJson(Map<String, dynamic> json) => Exam(
    examId: json['examId'],
    userId: json['userId'],
    className: json['className'],
    examName: json['examName'],
    teacherName: json['teacherName'],
    subject: json['subject'],
    marks: Map<String, double>.from(json['marks']),
    timestamp: DateTime.parse(json['timestamp']),
  );

  Map<String, dynamic> toJson() => {
    'examId': examId,
    'userId': userId,
    'className': className,
    'examName': examName,
    'teacherName': teacherName,
    'subject': subject,
    'marks': marks,
    'timestamp': timestamp.toIso8601String(),
  };
}


/// Represents a school.
class School {
  final String schoolId;
  final String name;
  final String address;
  final String city;

  /// Creates an instance of [School].
  School({
    required this.schoolId,
    required this.name,
    required this.address,
    required this.city,
  });

  /// Creates an instance of [School] from a JSON object.
  factory School.fromJson(Map<String, dynamic> json) {
    return School(
      schoolId: json['schoolId'],
      name: json['name'],
      address: json['address'],
      city: json['city'],
    );
  }

  /// Converts an instance of [School] to a JSON object.
  Map<String, dynamic> toJson() => {
    'schoolId': schoolId,
    'name': name,
    'address': address,
    'city': city,
  };
}

/// Enumeration of user roles.
enum Role {
  admin,
  teacher,
  student,
}



