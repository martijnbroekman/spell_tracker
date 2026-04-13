import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/models/spell_book.dart';
import 'package:spell_tracker/providers/spell_books_provider.dart';
import 'package:spell_tracker/providers/spells_provider.dart';

/// Screen for creating a new spell book or editing an existing one.
///
/// Pass [bookId] to edit; omit it (or pass `null`) to create.
class CreateEditSpellBookScreen extends ConsumerStatefulWidget {
  const CreateEditSpellBookScreen({super.key, this.bookId});

  /// The id of the book to edit, or `null` to create a new book.
  final String? bookId;

  @override
  ConsumerState<CreateEditSpellBookScreen> createState() =>
      _CreateEditSpellBookScreenState();
}

class _CreateEditSpellBookScreenState
    extends ConsumerState<CreateEditSpellBookScreen> {
  late final TextEditingController _nameController;
  final _searchController = TextEditingController();

  late Set<String> _selectedKeys;
  var _searchQuery = '';
  var _isSaving = false;

  @override
  void initState() {
    super.initState();
    final book = widget.bookId == null
        ? null
        : ref
            .read(spellBooksProvider)
            .value
            ?.where((b) => b.id == widget.bookId)
            .firstOrNull;

    _nameController = TextEditingController(text: book?.name ?? '');
    _selectedKeys = Set<String>.of(book?.spellKeys ?? const {});
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    setState(() => _searchQuery = _searchController.text.trim().toLowerCase());
  }

  List<Spell> _filteredSpells(List<Spell> all) {
    if (_searchQuery.isEmpty) return all;
    return all
        .where((s) => s.name.toLowerCase().contains(_searchQuery))
        .toList();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a name for the spell book.'),
        ),
      );
      return;
    }

    setState(() => _isSaving = true);
    final notifier = ref.read(spellBooksProvider.notifier);

    if (widget.bookId == null) {
      await notifier.createBook(name);
      final created = ref
          .read(spellBooksProvider)
          .value
          ?.lastWhere((b) => b.name == name);
      if (created != null) {
        await notifier.updateBook(created.copyWith(spellKeys: _selectedKeys));
      }
    } else {
      final current = ref
          .read(spellBooksProvider)
          .value
          ?.where((b) => b.id == widget.bookId)
          .firstOrNull;
      if (current != null) {
        await notifier.updateBook(
          current.copyWith(name: name, spellKeys: _selectedKeys),
        );
      }
    }

    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final isEditing = widget.bookId != null;
    final spellsAsync = ref.watch(spellsProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? 'Edit Spell Book' : 'New Spell Book'),
        centerTitle: false,
        actions: [
          if (_isSaving)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            )
          else
            IconButton(
              icon: const Icon(Icons.check),
              tooltip: 'Save',
              onPressed: _save,
            ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
            child: TextField(
              controller: _nameController,
              autofocus: !isEditing,
              textCapitalization: TextCapitalization.words,
              decoration: const InputDecoration(
                labelText: 'Name',
                hintText: 'e.g. Wizard Cantrips',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const Divider(height: 24),
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
            child: _SearchBar(controller: _searchController),
          ),
          spellsAsync.when(
            data: (all) {
              final spells = _filteredSpells(all);
              if (spells.isEmpty) {
                return const Expanded(
                  child: Center(child: Text('No spells match your search.')),
                );
              }
              return Expanded(
                child: ListView.builder(
                  itemCount: spells.length,
                  itemBuilder: (context, index) {
                    final spell = spells[index];
                    final key = SpellBook.keyFor(spell);
                    final isSelected = _selectedKeys.contains(key);
                    final levelLabel =
                        spell.level == 0 ? 'Cantrip' : 'Level ${spell.level}';
                    return CheckboxListTile(
                      value: isSelected,
                      controlAffinity: ListTileControlAffinity.leading,
                      title: Text(spell.name),
                      subtitle: Text(
                        '$levelLabel · ${spell.schoolName} · ${spell.source}',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onSurfaceVariant,
                        ),
                      ),
                      onChanged: (checked) {
                        setState(() {
                          if (checked == true) {
                            _selectedKeys = {..._selectedKeys, key};
                          } else {
                            _selectedKeys =
                                _selectedKeys.where((k) => k != key).toSet();
                          }
                        });
                      },
                    );
                  },
                ),
              );
            },
            loading: () => const Expanded(
              child: Center(child: CircularProgressIndicator()),
            ),
            error: (e, _) => Expanded(
              child: Center(child: Text('Error: $e')),
            ),
          ),
        ],
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
    return TextField(
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
    );
  }
}
