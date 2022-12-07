import 'package:cloud_firestore/cloud_firestore.dart';

class TestDone {
  final String userEmail;
  final String student;
  final String classroom;
  final String subject;
  final int grade;
  final int bimester;
  final int year;
  final DateTime date;

  TestDone({
    required this.userEmail,
    required this.student,
    required this.classroom,
    required this.subject,
    required this.grade,
    required this.bimester,
    required this.year,
    required this.date,
  });

  factory TestDone.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    return TestDone(
      userEmail: data['user_email'],
      student: data['student'],
      classroom: data['classroom'],
      subject: data['subject'],
      grade: data['grade'],
      bimester: data['bimester'],
      year: data['year'],
      date: DateTime.parse(data['date']),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'user_email': userEmail,
      'student': student,
      'classroom': classroom,
      'subject': subject,
      'grade': grade,
      'bimester': bimester,
      'year': year,
      // 'date': '${date.year}-${date.month}-${date.day}',
      'date': date.toString(),
    };
  }

  @override
  String toString() {
    return 'TestDone${toFireStore().toString()}';
  }
}
