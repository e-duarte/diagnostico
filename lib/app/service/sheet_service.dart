import 'package:diagnostico/app/model/student.dart';
import 'package:diagnostico/app/google_config.dart';
import 'package:diagnostico/app/model/test.dart';
import 'package:gsheets/gsheets.dart';

class SheetService {
  final GoogleConfigurations configs = GoogleConfigurations();

  Future<List<Student>> getStudents(
    String link,
    String room,
    Test test,
  ) async {
    final gsheets = GSheets(configs.credentials);

    final ss = await gsheets.spreadsheet(link);
    final questionSheet = ss.worksheetByTitle(room);

    final studentCells =
        await questionSheet?.cells.allRows(fromRow: 13, fromColumn: 2) ?? [];

    List<Student> students = studentCells.map((row) {
      var cells = List.from(row);
      int id = cells[0].row;
      String name = cells.removeAt(0).value;

      List<String> responses = [];

      if (test.matter != 'PSICOGÊNESE') {
        responses = cells.map((r) => r.value).toList().cast<String>();
      } else {
        responses = [];

        if (cells.isNotEmpty) {
          var key = test.vars.keys.first;
          var index = cells.length - 1;
          responses = [test.vars[key][index]];
        }
      }

      return Student.fromMap({
        'id': id,
        'name': name,
        'responses': responses,
      });
    }).toList();

    return students;
  }

  Future<void> insertResponse(
    String link,
    String room,
    Student student,
    // Test test,
  ) async {
    final gsheets = GSheets(configs.credentials);

    final ss = await gsheets.spreadsheet(link);
    final questionSheet = ss.worksheetByTitle(room);

    questionSheet?.values
        .insertRow(student.id, student.responses, fromColumn: 3);
  }
}
