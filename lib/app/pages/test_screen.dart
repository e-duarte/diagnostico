import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/service/sheet_service.dart';
import 'package:flutter/material.dart';
import 'package:diagnostico/app/model/test.dart';

class TestScreen extends StatelessWidget {
  const TestScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Map arguments = ModalRoute.of(context)?.settings.arguments as Map;

    return TestView(
      link: arguments['link'],
      room: arguments['room'],
      test: arguments['test'],
      student: arguments['student'],
    );
  }
}

class TestView extends StatefulWidget {
  const TestView({
    required this.link,
    required this.room,
    required this.test,
    required this.student,
    Key? key,
  }) : super(key: key);

  final String link;
  final String room;
  final Test test;
  final Student student;

  @override
  _TestViewState createState() => _TestViewState();
}

class _TestViewState extends State<TestView> {
  List<String?> selectedValues = [];

  @override
  void initState() {
    super.initState();

    selectedValues = widget.student.responses.isNotEmpty
        ? widget.student.responses
        : widget.test.vars.keys
            .map((k) => widget.test.vars[k][0].toString())
            .toList();
  }

  void radioHandle(String? selected, int index) {
    setState(() {
      selectedValues[index] = selected;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.student.name),
      ),
      body: Container(
        padding: const EdgeInsets.all(20.0),
        child: ListView(
          children: <Widget>[
            for (int i = 0; i < widget.test.vars.length; i++)
              Question(
                question: widget.test.vars.keys.elementAt(i),
                values: widget.test.vars[widget.test.vars.keys.elementAt(i)]
                    .cast<String>(),
                valueSelected: selectedValues[i],
                questionIndex: i,
                handle: radioHandle,
              )
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          if (widget.test.matter == 'PSICOGÊNESE') {
            String key = widget.test.vars.keys.first;
            List<String?> valuesPiscogenese = [
              for (var i in widget.test.vars[key]) ''
            ];
            for (int i = 0; i < widget.test.vars[key].length; i++) {
              if (selectedValues.first == widget.test.vars[key][i]) {
                valuesPiscogenese[i] = 'X';
              } else {
                valuesPiscogenese[i] = '';
              }
            }

            selectedValues = valuesPiscogenese;
          }
          Student student = Student.fromMap({
            "id": widget.student.id,
            "name": widget.student.name,
            "responses": selectedValues
          });

          print(student);

          await SheetService()
              .insertResponse(widget.link, widget.room, student);

          print('Enviado com sucesso para o servidor');

          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
              backgroundColor: Colors.green[400],
              content: const Text('Respostas enviadas para o servidor')));
        },
        child: const Icon(Icons.add),
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
