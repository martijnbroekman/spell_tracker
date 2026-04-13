import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/models/spell_book.dart';
import 'package:spell_tracker/providers/spell_books_provider.dart';
import 'package:spell_tracker/providers/spells_provider.dart';
import 'package:spell_tracker/screens/create_edit_spell_book_screen.dart';
import 'package:spell_tracker/widgets/spell_tile.dart';

/// Displays the spells contained in a single spell book.
class SpellBookDetailScreen extends ConsumerStatefulWidget {
  const SpellBookDetailScreen({super.key, required this.bookId});

  /// The [id][SpellBook.id] of the book to display.
  final String bookId;

  @override
  ConsumerState<SpellBookDetailScreen> createState() =>
      _SpellBookDetailScreenState();
}

class _SpellBookDetailScreenState
    extends ConsumerState<SpellBookDetailScreen> {
  final _searchController = TextEditingController();
  var _searchQuery = '';

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
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  List<Spell> _bookSpells(List<Spell> all, Set<String> keys) {
    final inBook = all.where((s) => keys.contains(SpellBook.keyFor(s)));
    if (_searchQuery.isEmpty) return inBook.toList();
    return inBook
        .where((s) => s.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final book = ref
        .watch(spellBooksProvider)
        .value
        ?.where((b) => b.id == widget.bookId)
        .firstOrNull;
    final spellsAsync = ref.watch(spellsProvider);

    if (book == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(book.name),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            tooltip: 'Edit book',
            onPressed: () => Navigator.push<void>(
              context,
              MaterialPageRoute(
                builder: (_) => CreateEditSpellBookScreen(bookId: book.id),
              ),
            ),
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: _SearchBar(controller: _searchController),
        ),
      ),
      body: spellsAsync.when(
        data: (all) {
          final spells = _bookSpells(all, book.spellKeys);
          if (spells.isEmpty) {
            return _EmptyState(hasSpells: book.spellKeys.isNotEmpty);
          }
          return _SpellList(spells: spells);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
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

class _SpellList extends StatelessWidget {
  const _SpellList({required this.spells});

  final List<Spell> spells;

  /// Builds a flat list of items — either a [_LevelHeader] or a [Spell] —
  /// sorted by level then name, with a header at the start of each group.
  List<Object> _buildItems() {
    final sorted = [...spells]
      ..sort((a, b) {
        final lvl = a.level.compareTo(b.level);
        return lvl != 0 ? lvl : a.name.compareTo(b.name);
      });

    final items = <Object>[];
    int? lastLevel;
    for (final spell in sorted) {
      if (spell.level != lastLevel) {
        items.add(spell.level);
        lastLevel = spell.level;
      }
      items.add(spell);
    }
    return items;
  }

  @override
  Widget build(BuildContext context) {
    final items = _buildItems();
    return ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        final item = items[index];
        if (item is int) return _LevelHeader(level: item);
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SpellTile(spell: item as Spell),
            if (index < items.length - 1 && items[index + 1] is! int)
              const Divider(height: 1),
          ],
        );
      },
    );
  }
}

class _LevelHeader extends StatelessWidget {
  const _LevelHeader({required this.level});

  final int level;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = level == 0 ? 'Cantrip' : 'Level $level';
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
      child: Row(
        children: [
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Divider(
              color: theme.colorScheme.primary.withValues(alpha: 0.3),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.hasSpells});

  final bool hasSpells;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final message = hasSpells
        ? 'No spells match your search.'
        : 'This spell book is empty.\nTap edit to add spells.';
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
      ),
    );
  }
}
