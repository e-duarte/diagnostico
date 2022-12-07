import 'package:cloud_firestore/cloud_firestore.dart';

class Setting {
  final List<Test> tests;
  final List<Classroom> classrooms;
  final int year;
  final int bimester;
  final double timestamp;

  Setting({
    required this.tests,
    required this.classrooms,
    required this.year,
    required this.bimester,
    required this.timestamp,
  });

  List<Classroom> getClassroomsByUser(String user) {
    return classrooms.where((c) => c.teacher == user).toList();
  }

  // Classroom getClassroomsId(String classroom) {
  //   return classrooms.singleWhere((c) => c.classroom == classroom);
  // }

  // List<Test> getTestByGrade(int grade) {
  //   return tests.where((t) => t.grade == grade).toList();
  // }

  List<Test> getTestByClassrooms(List<Classroom> classrooms, String subject) {
    return tests
        .where((t) => classrooms.map((c) => c.grade).contains(t.grade))
        .where((t) => t.subject == subject)
        .toList();
  }

  List<String> getSubjectsByUser(String user) {
    List<Classroom> userClassrooms = getClassroomsByUser(user);
    return tests
        .where((t) => userClassrooms.map((c) => c.grade).contains(t.grade))
        .map((t) => t.subject)
        .toSet()
        .toList();
  }

  factory Setting.fromSembast(Map<String, dynamic> data) {
    List<Map<String, dynamic>> testsData =
        data['tests'].cast<Map<String, dynamic>>();

    List<Map<String, dynamic>> classroomsData =
        data['classrooms'].cast<Map<String, dynamic>>();

    List<Test> tests = testsData.map((test) => Test.fromMap(test)).toList();

    List<Classroom> classrooms = classroomsData
        .map((classroom) => Classroom.fromMap(classroom))
        .toList();
    return Setting(
      tests: tests,
      classrooms: classrooms,
      year: data['year'],
      bimester: data['bimester'],
      timestamp: data['timestamp'],
    );
  }

  factory Setting.fromFireStore(DocumentSnapshot<Map<String, dynamic>> snapshot,
      SnapshotOptions? options) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    List<Map<String, dynamic>> testsData =
        data['tests'].cast<Map<String, dynamic>>();

    List<Map<String, dynamic>> classroomsData =
        data['classrooms'].cast<Map<String, dynamic>>();

    List<Test> tests = testsData.map((test) => Test.fromMap(test)).toList();

    List<Classroom> classrooms = classroomsData
        .map((classroom) => Classroom.fromMap(classroom))
        .toList();

    return Setting(
      tests: tests,
      classrooms: classrooms,
      year: data['year'],
      bimester: data['bimester'],
      timestamp: data['timestamp'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'tests': [for (var test in tests) test.toFireStore()],
      'classrooms': [for (var classroom in classrooms) classroom.toFireStore()],
      'year': year,
      'bimester': bimester,
      'timestamp': timestamp
    };
  }

  @override
  String toString() {
    return 'Setting${toFireStore().toString()}';
  }
}

class Test {
  final String link;
  final String subject;
  final String title;
  final int grade;
  final int bimester;
  final Map<String, dynamic> vars;

  Test({
    required this.link,
    required this.subject,
    required this.title,
    required this.grade,
    required this.bimester,
    required this.vars,
  });

  factory Test.fromMap(Map<String, dynamic> map) {
    return Test(
      link: map['link'],
      subject: map['subject'],
      title: map['title'],
      grade: map['grade'],
      bimester: map['bimester'],
      vars: map['vars'] as Map<String, dynamic>,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'link': link,
      'subject': subject,
      'title': title,
      'grade': grade,
      'bimester': bimester,
      'vars': {for (var k in vars.keys) k: vars[k]}
    };
  }

  @override
  String toString() {
    return 'Test${toFireStore().toString()}';
  }
}

class Classroom {
  final String classroom;
  final int grade;
  final String period;
  final String teacher;

  Classroom({
    required this.classroom,
    required this.grade,
    required this.period,
    required this.teacher,
  });

  factory Classroom.fromMap(Map<String, dynamic> map) {
    return Classroom(
      classroom: map['classroom'],
      grade: map['grade'],
      period: map['period'],
      teacher: map['teacher'],
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'classroom': classroom,
      'grade': grade,
      'period': period,
      'teacher': teacher,
    };
  }

  @override
  String toString() {
    return 'Classroom${toFireStore().toString()}';
  }
}
