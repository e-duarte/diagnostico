import 'package:diagnostico/app/model/setting.dart';
import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:flutter/material.dart';

typedef UpdateToDoCallback = void Function();

class ClassroomDialog extends StatefulWidget {
  const ClassroomDialog({
    required this.userEmail,
    required this.classroom,
    required this.test,
    required this.testYear,
    this.updateTodoHandle,
    Key? key,
  }) : super(key: key);

  final String userEmail;
  final String classroom;
  final Test test;
  final int testYear;
  final UpdateToDoCallback? updateTodoHandle;

  @override
  State<ClassroomDialog> createState() => _ClassroomDialogState();
}

class _ClassroomDialogState extends State<ClassroomDialog> {
  bool loadsStudent = true;
  List<Student> students = [];

  void updateStudents() {
    setState(() {
      print('updating students');
      loadsStudent = true;
      if (widget.updateTodoHandle != null) {
        widget.updateTodoHandle!();
      }
    });
  }

  Future<List<Student>> getStudents(String classroom, Test test) async {
    students = loadsStudent
        ? await SheetService().getStudents(test, classroom)
        : students;
    loadsStudent = false;
    print(loadsStudent);
    return students;
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      child: Column(
        children: [
          Container(
            height: MediaQuery.of(context).size.height * 0.06,
            color: const Color(0xAA2ECC71),
            child: Row(
              children: [
                IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: const Icon(Icons.close),
                ),
                Text(
                  '${widget.classroom} - ${widget.test.subject}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 14, left: 14, right: 14, top: 6),
              child: FutureBuilder<List<Student>>(
                future: getStudents(widget.classroom, widget.test),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    List<Student> students = snapshot.data ?? [];
                    return ListView.separated(
                        itemBuilder: ((context, index) {
                          return ListTile(
                            title: Text(
                              students[index].name,
                              style: const TextStyle(fontSize: 14),
                            ),
                            onTap: () {
                              if (widget.updateTodoHandle != null) {
                                Navigator.pushNamed(
                                  context,
                                  '/test',
                                  arguments: {
                                    'user_email': widget.userEmail,
                                    'classroom': widget.classroom,
                                    'test': widget.test,
                                    'student': students[index],
                                    'year': widget.testYear,
                                    'UpdateTodoHandle': updateStudents,
                                  },
                                );
                              }
                            },
                          );
                        }),
                        separatorBuilder: (context, index) => const Divider(),
                        itemCount: students.length);
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
            ),
          )
        ],
      ),
    );
  }
}
