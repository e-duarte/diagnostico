import 'package:cloud_firestore/cloud_firestore.dart';

class Tests {
  final List<Test> tests;
  final double timestamp;

  Tests({
    required this.tests,
    required this.timestamp,
  });

  factory Tests.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    final double timestamp = data['timestamp'];
    final List<Map<String, dynamic>> mapTests =
        data['tests'].cast<Map<String, dynamic>>();

    List<Test> tests = mapTests.map((t) {
      return Test.fromMap({
        'matter': t['matter'],
        'year': t['year'],
        'bimestre': t['bimestre'],
        'vars': t['vars'].cast<String>(),
        'options': Map.from(t['options']),
      });
    }).toList();

    return Tests(tests: tests, timestamp: timestamp);
  }

  factory Tests.fromSembast(Map<String, dynamic> map) {
    map = Map.from(map);

    double timestamp = map['timestamp'];
    final List<Map<String, dynamic>> mapTests =
        map['tests'].cast<Map<String, dynamic>>();
    List<Test> tests = mapTests.map((t) {
      return Test.fromMap({
        'matter': t['matter'],
        'year': t['year'],
        'bimestre': t['bimestre'],
        'vars': t['vars'].cast<String>(),
        'options': Map.from(t['options']),
      });
    }).toList();

    return Tests(tests: tests, timestamp: timestamp);
  }

  Map<String, dynamic> toFireStore() {
    return {
      'tests': tests.map((test) => test.toFireStore()).toList(),
      'timestamp': timestamp,
    };
  }

  Test getTest(String matter, int year) {
    return tests.where((element) {
      return element.matter.toLowerCase() == matter.toLowerCase();
    }).lastWhere((element) {
      return element.year == year;
    });
  }
}

class Test {
  final String matter;
  final int year;
  final String bimestre;
  final Map<String, dynamic> vars;

  Test({
    required this.matter,
    required this.year,
    required this.bimestre,
    required this.vars,
  });

  factory Test.fromMap(Map<String, dynamic> map) {
    Map<String, dynamic> options = Map.from(map['options']);
    List<String> vars = List.from(map['vars']);

    Map<String, dynamic> mapVars = {
      for (int i = 0; i < vars.length; i++) vars[i]: options['var${i + 1}']
    };

    return Test(
      matter: map['matter'],
      year: map['year'],
      bimestre: map['bimestre'],
      vars: mapVars,
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'matter': matter,
      'year': year,
      'bimestre': bimestre,
      'vars': vars.keys.toList(),
      'options': {
        for (var i in List.generate(vars.length, (index) => index + 1))
          'var$i': vars.values.toList()[i - 1]
      },
    };
  }
}
