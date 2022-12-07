class TestToDo {
  final String student;
  final String classroom;
  final String subject;
  final int grade;
  final int bimester;
  final int year;

  TestToDo({
    required this.student,
    required this.classroom,
    required this.subject,
    required this.grade,
    required this.bimester,
    required this.year,
  });

  factory TestToDo.fromMap(Map<String, dynamic> data) {
    return TestToDo(
      student: data['student'],
      classroom: data['classroom'],
      subject: data['subject'],
      grade: data['grade'],
      bimester: data['bimester'],
      year: data['year'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'student': student,
      'classroom': classroom,
      'subject': subject,
      'grade': grade,
      'bimester': bimester,
      'year': year
    };
  }

  @override
  String toString() {
    return 'TestToDo${toMap().toString()}';
  }
}
