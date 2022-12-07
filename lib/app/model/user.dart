import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String user;
  final String email;
  final bool manager;
  final String permission;
  final String photoUrl;

  User({
    required this.user,
    required this.email,
    required this.manager,
    required this.permission,
    required this.photoUrl,
  });

  factory User.fromFireStore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  ) {
    Map<String, dynamic> data = snapshot.data() as Map<String, dynamic>;
    return User(
      user: data['user'],
      email: data['email'],
      manager: data['manager'],
      permission: data['permission'],
      photoUrl: '',
    );
  }

  Map<String, dynamic> toFireStore() {
    return {
      'user': user,
      'email': email,
      'manager': manager,
      'permission': permission,
      'photourl': photoUrl,
    };
  }

  @override
  String toString() {
    return 'User${toFireStore().toString()}';
  }
}
