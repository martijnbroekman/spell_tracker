import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';

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