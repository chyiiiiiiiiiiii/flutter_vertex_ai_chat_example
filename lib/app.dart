import 'package:flutter/material.dart';
import 'package:vertex_ai_example/home_page.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: const HomePage(),
      theme: ThemeData.from(
          colorScheme: ColorScheme.fromSeed(
        seedColor: Colors.blue,
      )),
      debugShowCheckedModeBanner: false,
    );
  }
}
