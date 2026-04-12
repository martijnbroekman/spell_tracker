import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/screens/spells_screen.dart';
import 'package:spell_tracker/theme.dart';

void main() {
  runApp(ProviderScope(child: const App()));
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Spellbook',
      theme: parchmentTheme(),
      home: const SpellsScreen(),
    );
  }
}
