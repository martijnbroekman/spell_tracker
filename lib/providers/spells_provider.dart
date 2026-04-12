import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/providers/sources_provider.dart';

/// Provides a flat list of all [Spell]s across every loaded [Source].
final spellsProvider = FutureProvider<List<Spell>>((ref) async {
  final sources = await ref.watch(sourcesProvider.future);
  return sources.expand((source) => source.spells).toList();
});
