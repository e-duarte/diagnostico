import 'package:diagnostico/app/model/setting.dart';
import 'package:diagnostico/app/service/firestore_service.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:diagnostico/app/widgets/classroom_dialog.dart';
import 'package:flutter/material.dart';

typedef UpdateToDoCallback = void Function();

class CustomTile extends StatelessWidget {
  const CustomTile({
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.period,
    required this.data,
    this.updateTodoHandle,
    Key? key,
  }) : super(key: key);

  final String leading;
  final String title;
  final String subtitle;
  final String period;
  final Map<String, dynamic> data;
  final UpdateToDoCallback? updateTodoHandle;

  final double leadingScale = 60.0;

  Future<List<Setting>> getSetting(String userEmail) async {
    List<Setting> s = await SettingService().getSetting();
    return s;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (data.isNotEmpty) {
          if (data['menu'] == 'Diagnósticos') {
            showModalBottomSheet(
                context: context,
                builder: (context) {
                  if (updateTodoHandle != null) {
                    return ClassroomDialog(
                      userEmail: data['user_email'],
                      classroom: data['classroom'],
                      test: data['test'],
                      testYear: data['year'],
                      updateTodoHandle: updateTodoHandle ??
                          () {
                            print('update empty');
                          },
                    );
                  } else {
                    return Container();
                  }
                });
          } else if (data['menu'] == 'Pendentes') {
            getSetting(data['user_email']).then((settings) {
              Setting setting = settings.singleWhere((s) =>
                  s.year == data['year'] && s.bimester == data['bimester']);
              final subject = subtitle.split(' ')[0];
              final grade = int.parse(subtitle.split(' ')[1][0]);
              var test = setting.tests
                  .singleWhere((t) => t.subject == subject && t.grade == grade);
              SheetService()
                  .getStudents(test, data['classroom'])
                  .then((students) {
                final student = students.singleWhere((s) => s.name == title);

                Navigator.pushNamed(
                  context,
                  '/test',
                  arguments: {
                    'user_email': data['user_email'],
                    'classroom': data['classroom'],
                    'test': test,
                    'student': student,
                    'year': data['year'],
                    'UpdateTodoHandle': updateTodoHandle,
                  },
                );
              });
            });
          }
        }
      },
      child: SizedBox(
        child: Row(
          children: [
            Container(
              width: leadingScale,
              height: leadingScale,
              child: Center(
                child: Text(
                  leading,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              decoration: const BoxDecoration(
                color: Color(0xFFECECEC),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          maxLines: 3,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          subtitle,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: Color(0xFF878181),
                          ),
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              width: MediaQuery.of(context).size.height * 0.05,
              child: Text(
                period,
                textAlign: TextAlign.end,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF878181),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
