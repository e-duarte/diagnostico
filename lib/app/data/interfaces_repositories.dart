import 'package:diagnostico/app/model/config.dart';
import 'package:diagnostico/app/model/test.dart';

abstract class ConfigurationRepository {
  Future<Configuration?> getConfiguration();

  Future<void> insertConfiguration(Configuration configuration);

  Future<void> dropStore();

  Future<List<Configuration>> listConfigurations();
}

abstract class TestsRepository {
  Future<Tests?> getTest();

  Future<void> insertTest(Tests test);

  Future<void> dropStore();
}
