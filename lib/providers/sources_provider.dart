import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';

/// Loads and parses all [Source]s (and their [Spell]s) from the bundled
/// `assets/spells_full.json` file.
///
/// Parsing runs in a separate isolate via [compute] to avoid blocking the UI.
final sourcesProvider = FutureProvider<List<Source>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/spells_full.json');
  return compute(_parseSources, jsonString);
});

List<Source> _parseSources(String jsonString) {
  final decoded = jsonDecode(jsonString) as List;
  return decoded
      .map((e) => Source.fromJson(e as Map<String, dynamic>))
      .toList();
}