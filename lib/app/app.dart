import 'package:diagnostico/app/pages/students_screen.dart';
import 'package:diagnostico/app/pages/test_screen.dart';
import 'package:flutter/material.dart';
import 'package:diagnostico/app/pages/home_screen.dart';
import 'package:diagnostico/app/data/init_sembast.dart';
import 'package:animated_splash_screen/animated_splash_screen.dart';
import 'package:page_transition/page_transition.dart';

class App extends StatelessWidget {
  const App({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    Map<int, Color> color = const {
      50: Color.fromARGB(255, 255, 255, 255),
      100: Color.fromARGB(255, 202, 223, 185),
      200: Color(0xff609d16), // cor do tab
      300: Color.fromARGB(255, 163, 203, 130),
      400: Color.fromARGB(255, 148, 181, 121),
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
      initialRoute: '/home',
      routes: {
        '/home': (context) => FutureBuilder(
              future: Init.initialize(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.done) {
                  return AnimatedSplashScreen(
                    duration: 3000,
                    splash: Image.asset(
                      'assets/icon/icon.png',
                      scale: 0.5,
                    ),
                    nextScreen: const Home(),
                    splashTransition: SplashTransition.fadeTransition,
                    // pageTransitionType: PageTransitionType.scale,
                    backgroundColor: Colors.white,
                    splashIconSize: 250,
                  );
                } else {
                  return const Material(
                    child: CircularProgressIndicator(),
                  );
                }
              },
            ),
        '/students': (context) => const StudentList(),
        '/test': (context) => const TestScreen(),
      },
    );
  }
}
