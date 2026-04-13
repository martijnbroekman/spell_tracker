import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/screens/app_shell.dart';
import 'package:spell_tracker/theme.dart';

void main() {
  runApp(const ProviderScope(child: App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spell Tracker',
      theme: parchmentTheme(),
      home: const AppShell(),
    );
  }
}
