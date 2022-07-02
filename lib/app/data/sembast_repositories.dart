import 'package:diagnostico/app/data/interfaces_repositories.dart';
import 'package:diagnostico/app/model/config.dart';
import 'package:diagnostico/app/model/test.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class SembastConfigurationRepository implements ConfigurationRepository {
  final Database _database = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("configuration_store");

  @override
  Future<void> dropStore() async {
    _store.drop(_database);
  }

  @override
  Future<void> insertConfiguration(Configuration config) async {
    _store.drop(_database);

    final l = await listConfigurations();
    return await _store.add(_database, config.toFireStore());
  }

  @override
  Future<Configuration?> getConfiguration() async {
    final snapshot = await _store.record(1).get(_database);

    return snapshot != null ? Configuration.fromSembast(snapshot) : null;
  }

  @override
  Future<List<Configuration>> listConfigurations() async {
    final snapshots = await _store.find(_database);
    return snapshots
        .map((snapshot) => Configuration.fromSembast(snapshot.value))
        .toList(growable: false);
  }
}

class SembastTestsRepository implements TestsRepository {
  final Database _database = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("tests_store");

  @override
  Future<void> dropStore() async {
    _store.drop(_database);
  }

  @override
  Future<Tests?> getTest() async {
    final snapshot = await _store.record(1).get(_database);
    return snapshot != null ? Tests.fromSembast(snapshot) : null;
  }

  @override
  Future<void> insertTest(Tests test) async {
    _store.drop(_database);
    return await _store.add(_database, test.toFireStore());
  }
}
