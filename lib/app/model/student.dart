class Student {
  final int id;
  final String name;
  final List<String> responses;

  Student({
    required this.id,
    required this.name,
    required this.responses,
  });

  factory Student.fromMap(Map<String, dynamic> map) {
    print(map);
    return Student(
      id: map['id'],
      name: map['name'],
      responses: map['responses'].cast<String>(),
    );
  }

  @override
  String toString() {
    return 'Student{\n\tid: $id\n\tname: $name\n\tresponses: $responses\n}';
  }
}
