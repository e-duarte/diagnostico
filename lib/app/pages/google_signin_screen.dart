import 'package:diagnostico/app/model/user.dart';
import 'package:diagnostico/app/service/firestore_service.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';

class GoogleSingInScreen extends StatefulWidget {
  const GoogleSingInScreen({Key? key}) : super(key: key);

  @override
  State<GoogleSingInScreen> createState() => _GoogleSingInScreenState();
}

class _GoogleSingInScreenState extends State<GoogleSingInScreen> {
  // GoogleSignInAccount? _currentUser;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  bool userNotFound = false;

  @override
  void initState() {
    super.initState();
    // _signOut();
    _googleSignIn.onCurrentUserChanged.listen((GoogleSignInAccount? account) {
      setState(() {
        if (account != null) {
          UserService().getUser(account.email).then((value) {
            if (value != null) {
              User loggedUser = User(
                user: value.user,
                email: value.email,
                manager: value.manager,
                permission: value.permission,
                photoUrl: account.photoUrl ?? '',
              );
              Navigator.pushNamed(
                context,
                '/home',
                arguments: {
                  'logged_user': loggedUser,
                },
              );
            } else {
              print('Usuário não foi cadastrado');
              userNotFound = true;
              _signOut();
            }
          });
        }
      });
    });
  }

  Future<void> _singIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      print(error);
    }
  }

  Future<void> _signOut() => _googleSignIn.disconnect();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Expanded(
              child: Align(
                alignment: FractionalOffset.topCenter,
                // child: Text('Developed by João Souza'),
              ),
            ),
            const Text(
              'Dulgnóstico App',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            Image.asset(
              'assets/icon/icon.png',
              width: MediaQuery.of(context).size.width * 0.5,
            ),
            const SizedBox(
              height: 20,
            ),
            const Text('Avaliações Diagnósticas da Dulcinéia'),
            const SizedBox(
              height: 20,
            ),
            SizedBox(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.13,
              child: ElevatedButton(
                onPressed: _singIn,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/icon/google_signin.png',
                      width: 30,
                      height: 30,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    const Text('Entrar com Google'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
            userNotFound
                ? const Text(
                    'O usuário não foi cadastrado',
                    style: TextStyle(color: Colors.red),
                  )
                : Container(),
            const Expanded(
              child: Align(
                alignment: FractionalOffset.bottomCenter,
                child: Text(
                  'Developed by João Souza',
                  style: TextStyle(
                    fontSize: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
