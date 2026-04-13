import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell_book.dart';
import 'package:spell_tracker/providers/spell_books_provider.dart';
import 'package:spell_tracker/screens/create_edit_spell_book_screen.dart';
import 'package:spell_tracker/screens/spell_book_detail_screen.dart';
import 'package:spell_tracker/widgets/spell_book_drawer.dart';

/// Displays the list of user-created [SpellBook]s.
class SpellBooksScreen extends ConsumerWidget {
  const SpellBooksScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(spellBooksProvider);

    return Scaffold(
      drawer: const SpellBookDrawer(),
      appBar: AppBar(
        title: const Text('Spell Books'),
        centerTitle: false,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => const CreateEditSpellBookScreen(),
          ),
        ),
        tooltip: 'New spell book',
        child: const Icon(Icons.add),
      ),
      body: booksAsync.when(
        data: (books) => books.isEmpty
            ? const _EmptyState()
            : _BookList(books: books),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error loading spell books: $e')),
      ),
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.menu_book_outlined,
            size: 64,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(height: 16),
          Text(
            'No spell books yet.',
            style: theme.textTheme.titleMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap + to create your first spell book.',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _BookList extends StatelessWidget {
  const _BookList({required this.books});

  final List<SpellBook> books;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 88),
      itemCount: books.length,
      separatorBuilder: (_, _) => const SizedBox(height: 8),
      itemBuilder: (context, index) => _SpellBookCard(book: books[index]),
    );
  }
}

class _SpellBookCard extends ConsumerWidget {
  const _SpellBookCard({required this.book});

  final SpellBook book;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final spellCount = book.spellKeys.length;
    final subtitle = spellCount == 1 ? '1 spell' : '$spellCount spells';

    return Card(
      child: InkWell(
        borderRadius: BorderRadius.circular(4),
        onTap: () => Navigator.push<void>(
          context,
          MaterialPageRoute(
            builder: (_) => SpellBookDetailScreen(bookId: book.id),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(book.name, style: theme.textTheme.titleMedium),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                icon: const Icon(Icons.edit_outlined),
                tooltip: 'Edit',
                onPressed: () => Navigator.push<void>(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        CreateEditSpellBookScreen(bookId: book.id),
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.delete_outline),
                tooltip: 'Delete',
                onPressed: () => _confirmDelete(context, ref),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete spell book?'),
        content: Text(
          '"${book.name}" will be permanently deleted.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await ref.read(spellBooksProvider.notifier).deleteBook(book.id);
    }
  }
}
