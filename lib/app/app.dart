import 'package:diagnostico/app/pages/google_signin_screen.dart';
import 'package:diagnostico/app/pages/loading_screen.dart';
import 'package:diagnostico/app/pages/students_screen.dart';
import 'package:diagnostico/app/pages/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:diagnostico/app/pages/home_screen.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = const {
      50: Color.fromARGB(255, 255, 255, 255),
      100: Color.fromARGB(255, 202, 223, 185),
      200: Color(0xff609d16), // cor do tab
      300: Color.fromARGB(255, 163, 203, 130),
      400: Color(0xAA2ECC71),
      500: Color.fromARGB(255, 158, 191, 132),
      600: Color.fromARGB(255, 164, 207, 129),
      700: Color.fromARGB(255, 130, 187, 84),
      800: Color.fromARGB(255, 115, 192, 52),
      900: Color.fromARGB(255, 90, 186, 11),
    };
    MaterialColor colorCustom = MaterialColor(Colors.white.value, color);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Diagnóstico',
      locale: const Locale('pt'),
      theme: ThemeData(primarySwatch: colorCustom),
      initialRoute: '/loading',
      routes: {
        '/home': (context) => const Home(),
        '/students': (context) => const StudentList(),
        '/test': (context) => const TestScreen(),
        '/loading': (context) => const Loading(),
        '/signin': (context) => const GoogleSingInScreen(),
      },
    );
  }
}
