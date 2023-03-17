import 'package:diagnostico/app/model/setting.dart';
import 'package:diagnostico/app/model/test_done.dart';
import 'package:diagnostico/app/model/test_to_do.dart';
import 'package:diagnostico/app/model/user.dart';
import 'package:diagnostico/app/service/firestore_service.dart';
import 'package:diagnostico/app/widgets/custom_tile.dart';
import 'package:diagnostico/app/widgets/filter_dialog.dart';
import 'package:diagnostico/app/widgets/option_button.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  int indexScreeen = 0;
  List<TestToDo> todos = [];
  bool loadTodos = true;
  Map<String, dynamic> selectedFilters = {
    'year': 'last',
    'bimester': 'last',
    'subject': 'PORTUGUÊS'
  };

  @override
  void initState() {
    super.initState();
  }

  void updateScreen(Map<String, dynamic> filters) {
    setState(() {
      selectedFilters = filters;
    });
  }

  void updateTodoList() {
    print('get new todos of server');
    loadTodos = true;
  }

  Future<List<Setting>> _getSettings(userEmail) async {
    var settings = await SettingService().getSetting();
    List<Classroom> classrooms = [];

    for (var s in settings) {
      classrooms.addAll(s.getClassroomsByUser(userEmail));
    }

    return classrooms.isNotEmpty ? settings : [];
  }

  Future<List<TestDone>> _getTestDones(String user) async {
    return await TestDoneService().listTestsDone(user);
  }

  Future<List<TestToDo>> _getTestsTodo(String userEmail) async {
    todos =
        loadTodos ? await TestToDoService().listAllTestToDo(userEmail) : todos;
    loadTodos = false;
    return todos;
    // return await TestToDoService().listTestToDo(userEmail);
  }

  Future<void> _reloadSettings() async {
    print('Reloading Settings from FireStore');
    await SettingService().removeFromLocalDatabase();
    print('Reloading was a sucess');
  }

  Future<void> _signOut() => _googleSignIn.disconnect();

  void swicthScreen(int index) {
    setState(() {
      indexScreeen = index;
    });
  }

  Widget buildOptions() {
    const double spacing = 5.0;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        OptionButton(
          index: 0,
          title: 'Histórico',
          iconPath: 'assets/icon/feed.png',
          callback: swicthScreen,
        ),
        const SizedBox(width: spacing),
        OptionButton(
          index: 1,
          title: 'Diagnósticos',
          iconPath: 'assets/icon/fichas.png',
          callback: swicthScreen,
        ),
        const SizedBox(width: spacing),
        OptionButton(
          index: 2,
          title: 'Pendentes',
          iconPath: 'assets/icon/students.png',
          callback: swicthScreen,
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    final User loggedUser = User(
      user: arguments['logged_user'].user,
      email: arguments['logged_user'].email,
      // email: 'paulocastro@gmail.com',
      manager: arguments['logged_user'].manager,
      permission: arguments['logged_user'].permission,
      photoUrl: arguments['logged_user'].photoUrl,
    );

    const double spacing = 10.0;
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        backgroundColor: const Color(0xAA2ECC71),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              icon: CircleAvatar(
                backgroundImage: NetworkImage(loggedUser.photoUrl),
              ),
              onPressed: () {
                showDialog(
                    context: context,
                    builder: (context) {
                      return AlertDialog(
                        title: const Text('Você deseja sair?'),
                        actions: [
                          TextButton(
                            onPressed: () => Navigator.pop(context),
                            child: const Text(
                              'Cancelar',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                          TextButton(
                            onPressed: () {
                              _signOut();
                              Navigator.popAndPushNamed(context, '/signin');
                            },
                            child: const Text(
                              'Sair',
                              style: TextStyle(color: Colors.black),
                            ),
                          ),
                        ],
                      );
                    });
              },
            );
          },
        ),
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        title: Text(
          'Prof. ${loggedUser.user}',
          style: const TextStyle(
            fontSize: 16,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _reloadSettings();
                loadTodos = true;
              });

              ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                duration: Duration(seconds: 3),
                backgroundColor: Color(0xAA2ECC71),
                content: Text('Configurações atualizadas com o Servidor'),
              ));
            },
            icon: const Icon(
              Icons.refresh,
              color: Color.fromARGB(255, 0, 0, 0),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            const SizedBox(height: spacing),
            buildOptions(),
            const SizedBox(height: spacing),
            Expanded(
              child: Container(
                child: [
                  FutureBuilder<List<TestDone>>(
                    future: _getTestDones(loggedUser.email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        List<TestDone> data = snapshot.data ?? [];
                        data.sort((a, b) => b.date.compareTo(a.date));

                        return HomeScreen(
                          title: 'Histórico',
                          itensData: data
                              .map((e) => {
                                    'title': e.student,
                                    'subtitle': '${e.subject} ${e.grade}º ANO',
                                    'period': '${e.date.day}/${e.date.month}',
                                    'leading': e.classroom,
                                    'data': {},
                                  })
                              .toList(),
                        );
                      } else {
                        return const Material(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<Setting>>(
                    future: _getSettings(loggedUser.email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        List<Setting> data = snapshot.data ?? [];

                        print(data);

                        if (data.isNotEmpty) {
                          Setting setting = data.first;
                          List<Classroom> classrooms = [];
                          List<Test> tests = [];
                          int year = 0;

                          if (selectedFilters['year'] == 'last') {
                            setting = data.firstWhere((element) =>
                                element.year == DateTime.now().year);

                            year = setting.year;

                            classrooms = setting.getClassroomsByUser(
                              loggedUser.email,
                            );
                            tests = setting.getTestByClassrooms(
                              classrooms,
                              selectedFilters['subject'],
                            );
                          } else {
                            setting = data.firstWhere((s) =>
                                s.year == selectedFilters['year'] &&
                                s.bimester == selectedFilters['bimester']);

                            year = setting.year;

                            classrooms = setting.getClassroomsByUser(
                              loggedUser.email,
                            );
                            tests = setting.getTestByClassrooms(
                              classrooms,
                              selectedFilters['subject'],
                            );
                          }

                          List<Map<String, dynamic>> dataItems =
                              classrooms.map((c) {
                            Test t =
                                tests.firstWhere((t) => t.grade == c.grade);
                            return {
                              'title': t.title,
                              'subtitle': '${t.grade}º ANO',
                              'period': '${t.bimester}º bim',
                              'leading': c.classroom,
                              'data': {
                                'menu': 'Diagnósticos',
                                'user_email': loggedUser.email,
                                'classroom': c.classroom,
                                'test': t,
                                'year': year,
                              },
                            };
                          }).toList();

                          // List<int> bimesters = data
                          //     .where((setting) => setting.year == year)
                          //     .map((setting) => setting.bimester)
                          //     .toList();

                          // print(bimesters);

                          List<String> subjectNames =
                              setting.getSubjectsByUser(loggedUser.email);
                          // aranhadalva@gmail.com
                          return HomeScreen(
                            title: 'Diagnósticos',
                            itensData: dataItems,
                            filters: data
                                .map((setting) => {
                                      'year': setting.year,
                                      // 'bimester': bimesters,
                                      'bimester': data
                                          .where((e) => e.year == setting.year)
                                          .map((setting) => setting.bimester)
                                          .toList(),
                                      'subject': subjectNames,
                                    })
                                .toList(),
                            updateScreenHandle: updateScreen,
                            updateTodoHandle: updateTodoList,
                          );
                        } else {
                          return HomeScreen(
                            title: 'Diagnósticos',
                            itensData: [],
                            updateScreenHandle: updateScreen,
                            updateTodoHandle: updateTodoList,
                          );
                        }
                      } else {
                        return const Material(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                  FutureBuilder<List<TestToDo>>(
                    future: _getTestsTodo(loggedUser.email),
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.done) {
                        List<TestToDo> data = snapshot.data ?? [];

                        return HomeScreen(
                          title: 'Pendentes',
                          updateTodoHandle: updateTodoList,
                          itensData: data
                              .map((e) => {
                                    'title': e.student,
                                    'subtitle':
                                        '${e.subject} ${e.grade}º ANO ${e.bimester}º bim',
                                    'period': '${e.year}',
                                    'leading': e.classroom,
                                    'data': {
                                      'menu': 'Pendentes',
                                      'user_email': loggedUser.email,
                                      'classroom': e.classroom,
                                      'test': '',
                                      'year': e.year,
                                      'bimester': e.bimester,
                                    },
                                  })
                              .toList(),
                        );
                      } else {
                        return const Material(
                          child: Center(
                            child: CircularProgressIndicator(
                              color: Colors.black,
                            ),
                          ),
                        );
                      }
                    },
                  ),
                ][indexScreeen],
                padding: const EdgeInsets.only(
                    bottom: 14, left: 14, right: 14, top: 6),
                width: MediaQuery.of(context).size.width * 0.95,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

typedef FilterCallback = Function(Map<String, dynamic> selectedFilters);
typedef UpdateToDoCallback = void Function();

class HomeScreen extends StatefulWidget {
  const HomeScreen({
    required this.title,
    this.filters = const [],
    required this.itensData,
    this.updateScreenHandle,
    this.updateTodoHandle,
    Key? key,
  }) : super(key: key);

  final String title;
  final List<Map<String, dynamic>> filters;
  final List<Map<String, dynamic>> itensData;
  final FilterCallback? updateScreenHandle;
  final UpdateToDoCallback? updateTodoHandle;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Map<String, dynamic>? selectedFilters;

  @override
  void initState() {
    super.initState();

    if (widget.filters.isNotEmpty) {
      List<Map<String, dynamic>> filters = [for (var i in widget.filters) i];
      filters.sort((a, b) => a['year'].compareTo(b['year']));

      int year = filters.last['year'];
      int bimester = filters.last['bimester'].last;
      String subject = filters.last['subject'].first;

      selectedFilters = {
        'year': year,
        'bimester': bimester,
        'subject': subject
      };
    }
  }

  void filterHandle(Map<String, dynamic> filters) {
    print('FILTROS SELECIONADOS');
    print(filters);
    selectedFilters = filters;
    widget.updateScreenHandle!(filters);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: MediaQuery.of(context).size.height * 0.06,
          child: Row(
            children: [
              Text(
                widget.title,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: Align(
                    alignment: FractionalOffset.topRight,
                    child: widget.filters.isNotEmpty
                        ? IconButton(
                            icon:
                                const Icon(Icons.format_align_justify_rounded),
                            onPressed: () {
                              showModalBottomSheet(
                                  context: context,
                                  builder: (context) {
                                    return FilterDialog(
                                      filters: widget.filters,
                                      selectedFilters: selectedFilters!,
                                      filterHandle: filterHandle,
                                    );
                                  });
                            })
                        : Container()),
              ),
            ],
          ),
        ),
        Expanded(
          child: widget.itensData.isNotEmpty
              ? ListView.separated(
                  itemBuilder: (context, index) {
                    var data = widget.itensData[index]['data'];
                    Map<String, dynamic> dataCast = {
                      for (var k in data.keys) '$k': data[k]
                    };

                    if (widget.updateTodoHandle == null) {
                      return CustomTile(
                        leading: widget.itensData[index]['leading']!,
                        title: widget.itensData[index]['title']!,
                        subtitle: widget.itensData[index]['subtitle']!,
                        period: widget.itensData[index]['period']!,
                        data: dataCast,
                      );
                    } else {
                      return CustomTile(
                        leading: widget.itensData[index]['leading']!,
                        title: widget.itensData[index]['title']!,
                        subtitle: widget.itensData[index]['subtitle']!,
                        period: widget.itensData[index]['period']!,
                        data: dataCast,
                        updateTodoHandle: widget.updateTodoHandle,
                      );
                    }
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                  itemCount: widget.itensData.length,
                )
              : SizedBox(
                  child: Center(
                      child: Text(
                          'Coffee Time! Nenhum ${widget.title} encontrado')),
                ),
        )
      ],
    );
  }
}
