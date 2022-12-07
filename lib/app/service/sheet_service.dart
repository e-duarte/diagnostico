import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/google_config.dart';
import 'package:diagnostico/app/model/setting.dart';
import 'package:gsheets/gsheets.dart';

class SheetService {
  final GoogleConfigurations configs = GoogleConfigurations();

  Future<List<Student>> getStudents(
    Test test,
    String room,
  ) async {
    final gsheets = GSheets(configs.credentials);

    final ss = await gsheets.spreadsheet(test.link);
    final questionSheet = ss.worksheetByTitle(room);

    final studentCells =
        await questionSheet?.cells.allRows(fromRow: 13, fromColumn: 2) ?? [];

    // print(studentCells);
    final questionCells = await questionSheet!.cells.row(12, fromColumn: 3);

    List<Student> students = studentCells.map((row) {
      var cells = List.from(row);

      int rowId = cells[0].row;
      String name = cells.removeAt(0).value;

      Map<String, String> responses = {};

      if (test.subject == 'PSICOGÊNESE') {
        if (cells.isNotEmpty) {
          var varKey = test.vars.keys.first;
          var index = cells.length - 1;
          responses = {varKey: test.vars[varKey][index]};
        } else {
          responses = {test.vars.keys.first: ''};
        }
      } else {
        // responses = cells.map((r) => r.value).toList().cast<String>();
        if (cells.isEmpty) {
          responses = {for (var k in questionCells) k.value: ''};
        } else {
          responses = {
            for (var i = 0; i < questionCells.length; i++)
              questionCells[i].value: cells[i].value
          };
        }
      }

      return Student.fromMap({
        'id': rowId,
        'name': name,
        'responses': responses,
      });
    }).toList();

    return students;
  }

  Future<void> insertResponse(String link, String classroom, int studentId,
      List<String> responses) async {
    final gsheets = GSheets(configs.credentials);

    final ss = await gsheets.spreadsheet(link);
    final questionSheet = ss.worksheetByTitle(classroom);

    questionSheet?.values.insertRow(studentId, responses, fromColumn: 3);
  }
}
