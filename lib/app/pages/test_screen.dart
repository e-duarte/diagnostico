import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/model/test_done.dart';
import 'package:diagnostico/app/service/firestore_service.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:diagnostico/app/model/setting.dart';

typedef UpdateToDoCallback = void Function();

class TestScreen extends StatelessWidget {
  const TestScreen({
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    print(arguments['student']);

    return arguments['UpdateTodoHandle'] != null
        ? TestView(
            userEmail: arguments['user_email'],
            classroom: arguments['classroom'],
            test: arguments['test'],
            student: arguments['student'],
            testYear: arguments['year'],
            updateTodoHandle: arguments['UpdateTodoHandle'],
          )
        : TestView(
            userEmail: arguments['user_email'],
            classroom: arguments['classroom'],
            test: arguments['test'],
            student: arguments['student'],
            testYear: arguments['year'],
          );
  }
}

class TestView extends StatefulWidget {
  const TestView({
    required this.userEmail,
    required this.classroom,
    required this.test,
    required this.student,
    required this.testYear,
    this.updateTodoHandle,
    Key? key,
  }) : super(key: key);

  final String userEmail;
  final String classroom;
  final Test test;
  final Student student;
  final int testYear;
  final UpdateToDoCallback? updateTodoHandle;

  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  List<String?> selectedValues = [];

  @override
  void initState() {
    super.initState();
    var responses = widget.student.responses;
    selectedValues =
        responses.keys.map((e) => responses[e]).toList().join() != ''
            ? responses.keys.map((k) => responses[k]).toList().cast<String>()
            : responses.keys.map((k) => '').toList();
  }

  void radioHandle(String? selected, int index) {
    setState(() {
      selectedValues[index] = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFECECEC),
      appBar: AppBar(
        title: Text(widget.student.name),
        backgroundColor: const Color(0xAA2ECC71),
      ),
      body: Center(
        child: Container(
          width: MediaQuery.of(context).size.width * 0.95,
          height: MediaQuery.of(context).size.height * 0.85,
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.all(Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(20.0),
          child: ListView(
            children: <Widget>[
              for (int i = 0; i < widget.student.responses.length; i++)
                Question(
                  question: widget.student.responses.keys.elementAt(i),
                  values: widget
                      .test.vars[widget.student.responses.keys.elementAt(i)]
                      .cast<String>(),
                  valueSelected: selectedValues[i],
                  questionIndex: i,
                  handle: radioHandle,
                )
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.test.subject == 'PSICOGÊNESE') {
            String key = widget.test.vars.keys.first;

            List<String?> valuesPsicogenese =
                widget.test.vars[key].cast<String>();
            List<String?> responsePsicogenese = [
              for (var i in valuesPsicogenese) ''
            ];

            for (int i = 0; i < valuesPsicogenese.length; i++) {
              if (valuesPsicogenese[i] == selectedValues.first) {
                responsePsicogenese[i] = 'X';
              } else {
                responsePsicogenese[i] = '';
              }
            }

            selectedValues = responsePsicogenese;
          }

          await SheetService().insertResponse(widget.test.link,
              widget.classroom, widget.student.id, List.from(selectedValues));
          await TestDoneService().insertTestDone(TestDone(
              userEmail: widget.userEmail,
              student: widget.student.name,
              classroom: widget.classroom,
              subject: widget.test.subject,
              grade: widget.test.grade,
              bimester: widget.test.bimester,
              year: widget.testYear,
              date: DateTime.now()));

          print('Enviado com sucesso para o servidor');
          widget.updateTodoHandle!();

          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
              backgroundColor: Color(0xAA2ECC71),
              content: Text('Respostas enviadas para o servidor')));
        },
        child: const Icon(Icons.send),
        backgroundColor: const Color(0xAA2ECC71),
      ),
    );
    // return ;
  }
}

typedef RadioCallback = Function(String? selected, int index);

class Question extends StatelessWidget {
  const Question({
    required this.question,
    required this.values,
    required this.valueSelected,
    required this.questionIndex,
    required this.handle,
    Key? key,
  }) : super(key: key);

  final String question;
  final List<String> values;
  final String? valueSelected;
  final int questionIndex;
  final RadioCallback handle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${questionIndex + 1}. $question',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        values.length > 2
            ? Column(
                children: [
                  for (int i = 0; i < values.length; i++)
                    SizedBox(
                      // width: 150,
                      child: RadioListTile<String>(
                        title: Text(values[i]),
                        value: values[i],
                        groupValue: valueSelected,
                        activeColor: const Color(0xAA2ECC71),
                        onChanged: (String? value) {
                          handle(value, questionIndex);
                        },
                      ),
                    )
                ],
              )
            : Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (int i = 0; i < values.length; i++)
                    SizedBox(
                      width: 150,
                      child: RadioListTile<String>(
                        title: Text(values[i]),
                        value: values[i],
                        groupValue: valueSelected,
                        activeColor: const Color(0xAA2ECC71),
                        onChanged: (String? value) {
                          handle(value, questionIndex);
                        },
                      ),
                    )
                ],
              )
      ],
    );
  }
}
