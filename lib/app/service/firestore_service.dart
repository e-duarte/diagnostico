import 'package:diagnostico/app/data/interfaces_repositories.dart';
import 'package:diagnostico/app/model/config.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:diagnostico/app/model/test.dart';
import 'package:get_it/get_it.dart';

class ConfigurationService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<Configuration> getConfiguration() async {
    ConfigurationRepository configRepository = GetIt.I.get();
    // await configRepository.dropStore();

    Configuration? config = await configRepository.getConfiguration();

    if (config == null) {
      final collectionRef = firebaseDb.collection('configs').withConverter(
          fromFirestore: Configuration.fromFireStore,
          toFirestore: (Configuration config, _) => config.toFireStore());
      collectionRef.orderBy('timestamp');

      final dataSnap = await collectionRef.get();
      final configs = dataSnap.docs.map((e) => e.data()).toList();
      final config = configs[configs.length - 1];

      configRepository.insertConfiguration(config);

      print('Config was loading from firestore');
      return config;
    }

    print('Config was loading from local database');
    return config;
  }

  Future<void> removeFromLocalDatabase() async {
    ConfigurationRepository configRepository = GetIt.I.get();
    await configRepository.dropStore();
  }
}

class TestsService {
  final firebaseDb = FirebaseFirestore.instance;

  Future<Tests> getTests() async {
    TestsRepository testsRepository = GetIt.I.get();
    // await testsRepository.dropStore();

    Tests? tests = await testsRepository.getTest();

    if (tests == null) {
      final collectionRef = firebaseDb.collection('tests').withConverter(
          fromFirestore: Tests.fromFireStore,
          toFirestore: (Tests tests, _) => tests.toFireStore());
      collectionRef.orderBy('timestamp');

      final dataSnap = await collectionRef.get();
      final testsList = dataSnap.docs.map((e) => e.data()).toList();
      final tests = testsList[testsList.length - 1];
      testsRepository.insertTest(tests);

      print('Test was loading from firestore');
      return tests;
    }
    print('Test was loading from local database');
    return tests;
  }

  Future<void> removeFromLocalDatabase() async {
    TestsRepository configRepository = GetIt.I.get();
    await configRepository.dropStore();
  }
}
