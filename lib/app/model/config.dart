import 'package:cloud_firestore/cloud_firestore.dart';

class Configuration {
  final List<String> matters;
  final List<MatterConfiguration> matterconfigurations;
  final double timestamp;

  Configuration({
    required this.matters,
    required this.matterconfigurations,
    required this.timestamp,
  });

  factory Configuration.fromSembast(Map<String, dynamic> map) {
    map = Map.from(map);

    final List<String> matters =
        map.keys.toList().where((element) => element != 'timestamp').toList();

    double timestamp = map['timestamp'];

    List<MatterConfiguration> matterConfigs = matters.map((matter) {
      return MatterConfiguration.fromMap({
        'matter': matter,
        'rooms': List.from(map[matter]['rooms']),
        'links': List.from(map[matter]['links']),
      });
    }).toList();

    return Configuration(
      matters: matters,
      matterconfigurations: matterConfigs,
      timestamp: timestamp,
    );
  }

  factory Configuration.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;

    final List<String> matters =
        data.keys.toList().where((element) => element != 'timestamp').toList();
    double timestamp = data['timestamp'];

    List<MatterConfiguration> matterConfigs = matters.map((matter) {
      return MatterConfiguration.fromMap({
        'matter': matter,
        'rooms': List.from(data[matter]['rooms']),
        'links': List.from(data[matter]['links']),
      });
    }).toList();

    return Configuration(
      matters: matters,
      matterconfigurations: matterConfigs,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toFireStore() {
    Map<String, dynamic> configMap = {
      'timestamp': timestamp,
    };

    for (var matter in matters) {
      configMap[matter] = getMatterConfiguration(matter).toFireStore();
    }

    print(configMap['PSICOGÊNESE']);

    return configMap;
  }

  List<String> getRooms(String matter) {
    return matterconfigurations
        .where((element) => element.matter == matter)
        .toList()[0]
        .rooms;
  }

  MatterConfiguration getMatterConfiguration(String matter) {
    return matterconfigurations
        .lastWhere((matterConfig) => matterConfig.matter == matter);
  }
}

class MatterConfiguration {
  final String matter;
  final List<String> rooms;
  final List<Map<String, dynamic>> links;

  MatterConfiguration({
    required this.matter,
    required this.rooms,
    required this.links,
  });

  factory MatterConfiguration.fromMap(Map<String, dynamic> map) {
    return MatterConfiguration(
      matter: map['matter'],
      rooms: map['rooms'].cast<String>(),
      links: map['links'].cast<Map<String, dynamic>>(),
    );
  }

  Map<String, dynamic> toFireStore() {
    return {"rooms": rooms, "links": links};
  }

  String getLink(int year) {
    return links.lastWhere((link) => link['year'] == year)['link'];
  }

  @override
  String toString() {
    return 'MatterConfiguratution{\n\tmatter: $matter,\n\trooms: $rooms,\n\tlinks: $links\n}';
  }
}
