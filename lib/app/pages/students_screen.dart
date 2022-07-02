import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:flutter/material.dart';

class StudentList extends StatelessWidget {
  const StudentList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    // print(arguments['test'].vars);

    return Scaffold(
      appBar: AppBar(
        title: Text(arguments['room']),
      ),
      body: FutureBuilder<List<Student>>(
        future: SheetService().getStudents(
            arguments['link'], arguments['room'], arguments['test']),
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
                List<Student> students = snapshot.data ?? [];

                return ListView.separated(
                  itemCount: students.length,
                  itemBuilder: (BuildContext context, int index) {
                    return ListTile(
                      onTap: () {
                        Navigator.pushNamed(
                          context,
                          '/test',
                          arguments: {
                            'link': arguments['link'],
                            'room': arguments['room'],
                            'test': arguments['test'],
                            'student': students[index]
                          },
                        );
                      },
                      title: Text(students[index].name),
                    );
                  },
                  separatorBuilder: (BuildContext context, int index) =>
                      const Divider(),
                );
              }
          }
        },
      ),
    );
  }
}
