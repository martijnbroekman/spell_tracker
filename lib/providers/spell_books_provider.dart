import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:spell_tracker/models/spell_book.dart';

const _prefsKey = 'spell_books';

/// Manages the persisted list of user-created [SpellBook]s.
///
/// Changes are immediately written back to [SharedPreferences].
class SpellBooksNotifier extends AsyncNotifier<List<SpellBook>> {
  @override
  Future<List<SpellBook>> build() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_prefsKey);
    if (raw == null) return [];
    final decoded = jsonDecode(raw) as List<dynamic>;
    return decoded
        .map((e) => SpellBook.fromJson(e as Map<String, dynamic>))
        .toList();
  }

  /// Adds a new [SpellBook] with the given [name] and an empty spell list.
  Future<void> createBook(String name) async {
    final book = SpellBook.create(name: name);
    final next = <SpellBook>[...(state.value ?? []), book];
    await _save(next);
    state = AsyncData(next);
  }

  /// Replaces the book with the same [SpellBook.id] as [updated].
  Future<void> updateBook(SpellBook updated) async {
    final current = state.value ?? [];
    final next = [
      for (final b in current) b.id == updated.id ? updated : b,
    ];
    await _save(next);
    state = AsyncData(next);
  }

  /// Removes the book with the given [id].
  Future<void> deleteBook(String id) async {
    final next = (state.value ?? [])
        .where((b) => b.id != id)
        .toList();
    await _save(next);
    state = AsyncData(next);
  }

  Future<void> _save(List<SpellBook> books) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _prefsKey,
      jsonEncode(books.map((b) => b.toJson()).toList()),
    );
  }
}

/// The persisted list of user-created [SpellBook]s.
final spellBooksProvider =
    AsyncNotifierProvider<SpellBooksNotifier, List<SpellBook>>(
  SpellBooksNotifier.new,
);
