import 'dart:io';

import 'package:diagnostico/app/data/interfaces_repositories.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnostico/app/model/setting.dart';
import 'package:diagnostico/app/model/test_done.dart';
import 'package:diagnostico/app/model/test_to_do.dart';
import 'package:diagnostico/app/model/user.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:get_it/get_it.dart';
import "dart:convert";
import 'package:diagnostico/app/model/student.dart';

class SettingService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<List<Setting>> getSetting() async {
    SettingRepository settingRepository = GetIt.I.get();

    Setting? setting = await settingRepository.getSetting();

    if (setting == null) {
      final collectionRef = firebaseDb
          .collection('settings')
          .orderBy('timestamp', descending: true)
          .withConverter(
            fromFirestore: Setting.fromFireStore,
            toFirestore: (Setting setting, _) => setting.toFireStore(),
          );

      final dataSnap = await collectionRef.get();
      final settings = dataSnap.docs.map((s) => s.data()).toList();

      for (var s in settings) {
        settingRepository.insertSetting(s);
      }

      print('Setting was loading from firestore');
      return settings;
    }

    print('Setting was loading from local database');
    return settingRepository.listSettings();
  }

  Future<void> removeFromLocalDatabase() async {
    SettingRepository settingRepository = GetIt.I.get();
    await settingRepository.dropStore();
  }
}

class UserService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<User?> getUser(String email) async {
    final collectionRef = firebaseDb
        .collection('users')
        .where('email', isEqualTo: email)
        .withConverter(
          fromFirestore: User.fromFireStore,
          toFirestore: (User user, _) => user.toFireStore(),
        );
    final dataSnap = await collectionRef.get();
    return dataSnap.docs.isNotEmpty ? dataSnap.docs.first.data() : null;
  }

  Future<void> removeFromLocalDatabase() async {
    SettingRepository settingRepository = GetIt.I.get();
    await settingRepository.dropStore();
  }
}

class TestDoneService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<List<TestDone>> listTestsDone(String email) async {
    final collectionRef = firebaseDb
        .collection('tests_done')
        .where('user_email', isEqualTo: email)
        .withConverter(
          fromFirestore: TestDone.fromFireStore,
          toFirestore: (TestDone testDone, _) => testDone.toFireStore(),
        );
    final dataSnap = await collectionRef.get();

    return dataSnap.docs.map((testDone) => testDone.data()).toSet().toList();
  }

  Future<List<Map<String, dynamic>>> listByUserGrouped(String user) async {
    List<TestDone> testsDone = await listTestsDone(user);

    final uniqueJsonList = testsDone
        .map((td) => jsonEncode({
              'year': td.year,
              'bimester': td.bimester,
              'subject': td.subject,
              'grade': td.grade,
              'classroom': td.classroom,
            }))
        .toSet()
        .toList();

    final groups = uniqueJsonList.map((e) {
      final decoded = jsonDecode(e);

      return {
        'year': decoded['year'],
        'bimester': decoded['bimester'],
        'subject': decoded['subject'],
        'grade': decoded['grade'],
        'classroom': decoded['classroom'],
      };
    }).toList();

    for (var group in groups) {
      group['done'] = testsDone
          .where((td) =>
              td.year == group['year'] &&
              td.bimester == group['bimester'] &&
              td.subject == group['subject'] &&
              td.grade == group['grade'] &&
              td.classroom == group['classroom'])
          .map((td) => td.student)
          .toList();
    }

    return groups;
  }

  Future<void> insertTestDone(TestDone testDone) async {
    final testsDoneRef = firebaseDb.collection('tests_done');
    await testsDoneRef.add(testDone.toFireStore());
  }
}

class TestToDoService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<List<TestToDo>> listTestToDo(String userEmail) async {
    final tds = await TestDoneService().listByUserGrouped(userEmail);
    final settings = await SettingService().getSetting();

    List<TestToDo> testsTodo = [];

    for (var td in tds) {
      final setting = settings.singleWhere(
          (s) => s.year == td['year'] && s.bimester == td['bimester']);

      final test = setting.tests.singleWhere(
          (t) => t.subject == td['subject'] && t.grade == td['grade']);

      List<String> studentsDone = List.from(td['done']);
      List<Student> students =
          await SheetService().getStudents(test, td['classroom']);
      List<String> studentToDo = students
          .where((s) => !studentsDone.contains(s.name))
          .map((e) => e.name)
          .toList();
      // print(studentToDo);

      testsTodo = studentToDo
          .map((s) => TestToDo.fromMap({
                'student': s,
                'classroom': td['classroom'],
                'subject': td['subject'],
                'grade': td['grade'],
                'bimester': td['bimester'],
                'year': td['year'],
              }))
          .toList();
    }
    return testsTodo;
  }

  Future<List<TestToDo>> listAllTestToDo(String userEmail) async {
    final settings = await SettingService().getSetting();
    List<TestToDo> testsToDo = [];

    for (var setting in settings) {
      List<Classroom> classrooms =
          setting.classrooms.where((c) => c.teacher == userEmail).toList();

      for (var classroom in classrooms) {
        List<Test> tests =
            setting.tests.where((t) => t.grade == classroom.grade).toList();
        for (var test in tests) {
          List<Student> allStudents =
              await SheetService().getStudents(test, classroom.classroom);

          if (allStudents[0].name == 'ADRIAN DUARTE DE LIMA') {
            print('entrou');
            print(allStudents[0].responses);
            print(allStudents[0].responseIsEmpty());
          }
          sleep(const Duration(milliseconds: 150));

          testsToDo.addAll(allStudents
              .where((s) => s.responseIsEmpty())
              .map((s) => TestToDo.fromMap({
                    'student': s.name,
                    'classroom': classroom.classroom,
                    'subject': test.subject,
                    'grade': test.grade,
                    'bimester': test.bimester,
                    'year': setting.year,
                  })));
        }
      }
    }

    return testsToDo;
  }
}
