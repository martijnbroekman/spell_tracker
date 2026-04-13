import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/providers/nav_index_provider.dart';

/// The side navigation drawer shared by all top-level screens.
///
/// Displays destinations for "Spells" and "Spell Books". Tapping a destination
/// updates [navIndexProvider] and closes the drawer.
class SpellBookDrawer extends ConsumerWidget {
  const SpellBookDrawer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedIndex = ref.watch(navIndexProvider);
    final theme = Theme.of(context);

    return NavigationDrawer(
      selectedIndex: selectedIndex,
      onDestinationSelected: (index) {
        ref.read(navIndexProvider.notifier).set(index);
        Navigator.pop(context);
      },
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(28, 16, 16, 10),
          child: Text(
            'D&D Spell Tracker',
            style: theme.textTheme.titleSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.auto_stories_outlined),
          selectedIcon: Icon(Icons.auto_stories),
          label: Text('Spells'),
        ),
        const NavigationDrawerDestination(
          icon: Icon(Icons.menu_book_outlined),
          selectedIcon: Icon(Icons.menu_book),
          label: Text('Spell Books'),
        ),
      ],
    );
  }
}
