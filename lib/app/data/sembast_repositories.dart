import 'package:diagnostico/app/data/interfaces_repositories.dart';
import 'package:diagnostico/app/model/setting.dart';
import 'package:get_it/get_it.dart';
import 'package:sembast/sembast.dart';

class SembastSettingRepository implements SettingRepository {
  final Database _database = GetIt.I.get();
  final StoreRef _store = intMapStoreFactory.store("setting_store");

  @override
  Future<void> dropStore() async {
    _store.drop(_database);
  }

  @override
  Future<Setting?> getSetting() async {
    final snapshot = await _store.record(1).get(_database);

    return snapshot != null ? Setting.fromSembast(snapshot) : null;
  }

  @override
  Future<void> insertSetting(Setting setting) async {
    await dropStore();
    return await _store.add(_database, setting.toFireStore());
  }

  @override
  Future<List<Setting>> listSettings() async {
    final snapshots = await _store.find(_database);

    return snapshots
        .map((snapshot) => Setting.fromSembast(snapshot.value))
        .toList();
  }
}
