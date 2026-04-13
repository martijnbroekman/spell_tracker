import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/providers/nav_index_provider.dart';
import 'package:spell_tracker/screens/spell_books_screen.dart';
import 'package:spell_tracker/screens/spells_screen.dart';

/// The root widget that hosts both top-level screens in an [IndexedStack].
///
/// Switching screens via the [SpellBookDrawer] updates [navIndexProvider]
/// without rebuilding the inactive screen, preserving its state.
class AppShell extends ConsumerWidget {
  const AppShell({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final navIndex = ref.watch(navIndexProvider);
    return IndexedStack(
      index: navIndex,
      children: const [SpellsScreen(), SpellBooksScreen()],
    );
  }
}
