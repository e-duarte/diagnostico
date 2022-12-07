import 'package:diagnostico/app/model/setting.dart';

abstract class SettingRepository {
  Future<Setting?> getSetting();

  Future<List<Setting>> listSettings();

  Future<void> insertSetting(Setting setting);

  Future<void> dropStore();
}
