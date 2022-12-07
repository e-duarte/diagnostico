class Student {
  final int id;
  final String name;
  final Map<String, String> responses;

  Student({
    required this.id,
    required this.name,
    required this.responses,
  });

  bool responseIsEmpty() {
    return responses.keys.map((e) => responses[e]).toList().join() == '';
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      id: map['id'],
      name: map['name'],
      responses: map['responses'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'responses': responses,
    };
  }

  @override
  String toString() {
    return 'Student${toMap()}';
  }
}
