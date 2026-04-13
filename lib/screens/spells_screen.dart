import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/providers/spell_filter_provider.dart';
import 'package:spell_tracker/screens/spell_detail_screen.dart';
import 'package:spell_tracker/screens/spell_filter_sheet.dart';

/// Displays a searchable, filterable scrollable list of all available spells.
class SpellsScreen extends ConsumerStatefulWidget {
  const SpellsScreen({super.key});

  @override
  ConsumerState<SpellsScreen> createState() => _SpellsScreenState();
}

class _SpellsScreenState extends ConsumerState<SpellsScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    final current = ref.read(spellFilterProvider);
    ref
        .read(spellFilterProvider.notifier)
        .set(current.copyWith(name: _searchController.text));
  }

  @override
  Widget build(BuildContext context) {
    final spellsAsync = ref.watch(filteredSpellsProvider);
    final activeCount = ref.watch(
      spellFilterProvider.select((f) => f.activeCount),
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Spells'),
        centerTitle: false,
        actions: [_FilterButton(activeCount: activeCount)],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _SearchBar(controller: _searchController),
        ),
      ),
      body: spellsAsync.when(
        data: (spells) => spells.isEmpty
            ? const _EmptyState()
            : _SpellList(spells: spells),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading spells: $e')),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  const _SearchBar({required this.controller});

  final TextEditingController controller;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: TextField(
        controller: controller,
        textCapitalization: TextCapitalization.none,
        decoration: InputDecoration(
          hintText: 'Search spells…',
          prefixIcon: const Icon(Icons.search),
          suffixIcon: ValueListenableBuilder<TextEditingValue>(
            valueListenable: controller,
            builder: (_, value, _) => value.text.isEmpty
                ? const SizedBox.shrink()
                : IconButton(
                    icon: const Icon(Icons.clear),
                    onPressed: controller.clear,
                  ),
          ),
          filled: true,
          fillColor: theme.colorScheme.surface,
          contentPadding: const EdgeInsets.symmetric(vertical: 0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8),
            borderSide: BorderSide(color: theme.colorScheme.outline),
          ),
        ),
      ),
    );
  }
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({required this.activeCount});

  final int activeCount;

  @override
  Widget build(BuildContext context) {
    final button = IconButton(
      icon: const Icon(Icons.tune),
      tooltip: 'Filter',
      onPressed: () => showFilterSheet(context),
    );

    if (activeCount == 0) return button;

    return Badge.count(
      count: activeCount,
      child: button,
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.search_off,
            size: 48,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 12),
          Text(
            'No spells match your filters.',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
        ],
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
