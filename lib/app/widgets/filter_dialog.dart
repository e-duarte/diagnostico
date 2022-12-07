import 'package:flutter/material.dart';

typedef FilterCallback = Function(Map<String, dynamic> selectedFilters);

class FilterDialog extends StatefulWidget {
  const FilterDialog({
    required this.filters,
    required this.selectedFilters,
    required this.filterHandle,
    Key? key,
  }) : super(key: key);

  final List<Map<String, dynamic>> filters;
  final Map<String, dynamic> selectedFilters;
  final FilterCallback filterHandle;

  @override
  State<FilterDialog> createState() => _FilterDialogState();
}

class _FilterDialogState extends State<FilterDialog> {
  Map<String, dynamic>? selectedFilters;

  @override
  void initState() {
    super.initState();
    selectedFilters = widget.selectedFilters;
  }

  @override
  Widget build(BuildContext context) {
    var selectedFilterBySelectedYear = widget.filters.firstWhere((e) {
      return e['year'] == selectedFilters!['year'];
    });

    var years = {
      'year': {
        for (var y in [for (var f in widget.filters) f['year']]) '$y': y
      }
    };

    var bimesters = {
      'bimester': {
        for (var i in selectedFilterBySelectedYear['bimester']) '$iº': i
      }
    };

    var subjects = {
      'subject': {
        for (var i in selectedFilterBySelectedYear['subject']) '$i': i
      }
    };

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
                const Text(
                  'Filtros',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                Expanded(
                  child: Align(
                    alignment: FractionalOffset.topRight,
                    child: TextButton(
                        child: const Text(
                          'Redefinir',
                          style: TextStyle(color: Colors.black),
                        ),
                        onPressed: () {
                          widget.filterHandle(selectedFilters!);
                          Navigator.pop(context);
                        }),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: Container(
              padding: const EdgeInsets.only(
                  bottom: 14, left: 14, right: 14, top: 6),
              child: ListView(
                children: [
                  buildTile('Ano', years, selectedFilters!['year']),
                  const Divider(),
                  buildTile(
                    'Bimestre',
                    bimesters,
                    selectedFilters!['bimester'],
                  ),
                  const Divider(),
                  buildTile(
                    'Disciplina',
                    subjects,
                    selectedFilters!['subject'],
                  ),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Widget buildTile(
      String title, Map<String, dynamic> filters, var valueSelected) {
    var keyFilter = filters.keys.first;
    var buttonTexts = filters[keyFilter].keys;

    List<Widget> radios = <Widget>[
      for (var t in buttonTexts)
        customRadioButton(t, keyFilter, filters[keyFilter][t], valueSelected)
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18),
        ),
        Wrap(
          children: radios,
        )
      ],
    );
  }

  Widget customRadioButton(
      String text, String key, var value, var valueSelected) {
    return OutlinedButton(
      onPressed: () {
        setState(() {
          selectedFilters![key] = value;
        });
      },
      child: Text(
        text,
        style: TextStyle(
          color:
              (valueSelected == value) ? const Color(0xAA2ECC71) : Colors.black,
        ),
      ),
      // shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      // borderSide:
      // BorderSide(color: (value == index) ? Colors.green : Colors.black),
    );
  }
}
