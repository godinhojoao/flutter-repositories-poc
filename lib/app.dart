import 'package:flutter/material.dart';
import 'package:flutter_repositories_poc/routes/settings_page.dart';
import 'routes/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 141, 107, 7)),
        useMaterial3: true,
      ),
      initialRoute: '/home',
      routes: {
        '/home': (context) => const HomePage(),
        '/settings': (context) => SettingsPage(),
      },
      onGenerateRoute: (settings) {
        if (settings.name == null) {
          return null;
        }
        return MaterialPageRoute(
          builder: (context) {
            switch (settings.name) {
              case '/home':
                return const HomePage();
              case '/settings':
                return const SettingsPage();
              default:
                return const SizedBox.shrink();
            }
          },
        );
      },
    );
  }
}
