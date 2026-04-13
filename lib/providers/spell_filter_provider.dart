import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/models/spell_filter.dart';
import 'package:spell_tracker/providers/spells_provider.dart';

/// Manages the currently active [SpellFilter].
class SpellFilterNotifier extends Notifier<SpellFilter> {
  @override
  SpellFilter build() => const SpellFilter();

  /// Replaces the current filter with [filter].
  void set(SpellFilter filter) => state = filter;
}

/// The currently active [SpellFilter], defaults to no filters applied.
final spellFilterProvider =
    NotifierProvider<SpellFilterNotifier, SpellFilter>(
  SpellFilterNotifier.new,
);

/// The spell list after applying the active [SpellFilter].
final filteredSpellsProvider = FutureProvider<List<Spell>>((ref) async {
  final spells = await ref.watch(spellsProvider.future);
  final filter = ref.watch(spellFilterProvider);
  return filter.apply(spells);
});

/// Sorted list of unique source acronyms present in the full spell list.
final availableSourcesProvider = FutureProvider<List<String>>((ref) async {
  final spells = await ref.watch(spellsProvider.future);
  final sources = {for (final s in spells) s.source}.toList()..sort();
  return sources;
});
