import 'package:diagnostico/app/model/config.dart';
import 'package:diagnostico/app/model/test.dart';
import 'package:diagnostico/app/pages/roms_screen.dart';
import 'package:diagnostico/app/service/firestore_service.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Future<Map<String, dynamic>> _getSettings() async {
    return {
      'configuration': await ConfigurationService().getConfiguration(),
      'tests': await TestsService().getTests(),
    };
  }

  Future<void> _reloadSettings() async {
    print('Reloading Settings from FireStore');
    await ConfigurationService().removeFromLocalDatabase();
    await TestsService().removeFromLocalDatabase();

    print('Reloading was a sucess');
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Map<String, dynamic>>(
      future: _getSettings(),
      builder: (context, snapshot) {
        switch (snapshot.connectionState) {
          case ConnectionState.none:
            return const Center(child: Text('no connection'));
          case ConnectionState.waiting:
            return const Center(child: CircularProgressIndicator());
          default:
            if (snapshot.hasError) {
              return const Center(
                child: Text("server is not avaliable"),
              );
            } else {
              Map<String, dynamic> settings =
                  snapshot.data as Map<String, dynamic>;
              Configuration config = settings['configuration'] as Configuration;
              Tests tests = settings['tests'] as Tests;

              // print(config.getMatterConfiguration('PSICOGÊNESE'));

              return DefaultTabController(
                length: config.matters.length,
                child: Scaffold(
                  appBar: AppBar(
                    toolbarHeight: MediaQuery.of(context).size.height * 0.06,
                    title: const Text(
                      'Diagnóstico',
                      style: TextStyle(
                          color: Color(0xff609d16),
                          fontSize: 20,
                          fontWeight: FontWeight.bold),
                    ),
                    actions: [
                      IconButton(
                        onPressed: () {
                          setState(() {
                            _reloadSettings();
                          });

                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            duration: const Duration(seconds: 3),
                            backgroundColor: Colors.green[400],
                            content: const Text(
                                'Configurações atualizadas com o Servidor'),
                          ));
                        },
                        icon: const Icon(
                          Icons.refresh,
                          color: Color(0xff609d16),
                        ),
                      ),
                    ],
                    bottom: TabBar(
                      tabs: config.matters
                          .map((e) => Tab(
                                text: e,
                              ))
                          .toList(),
                    ),
                  ),
                  body: TabBarView(
                      children: config.matters
                          .map((matter) => RoomList(
                                matterConfig:
                                    config.getMatterConfiguration(matter),
                                tests: tests,
                              ))
                          .toList()),
                ),
              );
            }
        }
      },
    );
  }
}
