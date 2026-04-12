import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/providers/spells_provider.dart';
import 'package:spell_tracker/screens/spell_detail_screen.dart';

/// Displays a scrollable list of all available spells.
class SpellsScreen extends ConsumerWidget {
  const SpellsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spellsAsync = ref.watch(spellsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells'),
        centerTitle: false,
      ),
      body: spellsAsync.when(
        data: (spells) => _SpellList(spells: spells),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading spells: $e')),
      ),
    );
  }
}

class _SpellList extends StatelessWidget {
  const _SpellList({required this.spells});

  final List<Spell> spells;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      itemCount: spells.length,
      separatorBuilder: (_, _) => const Divider(height: 1),
      itemBuilder: (context, index) => _SpellTile(spell: spells[index]),
    );
  }
}

class _SpellTile extends StatelessWidget {
  const _SpellTile({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelLabel = spell.level == 0 ? 'Cantrip' : 'Level ${spell.level}';

    return ListTile(
      leading: _SchoolIcon(schoolName: spell.schoolName),
      title: Text(spell.name),
      subtitle: Text(
        '$levelLabel · ${spell.source}',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => SpellDetailScreen(spell: spell),
        ),
      ),
    );
  }
}

class _SchoolIcon extends StatelessWidget {
  const _SchoolIcon({required this.schoolName});

  final String schoolName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SvgPicture.asset(
        'assets/${schoolName.toLowerCase()}.svg',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
