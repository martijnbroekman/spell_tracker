import 'package:flutter/foundation.dart';
import 'package:spell_tracker/models/spell.dart';

/// Sentinel used in [SpellFilter.copyWith] to distinguish an explicit `null`
/// from an omitted argument for the nullable [SpellFilter.name] field.
const Object _absent = Object();

/// An immutable value object holding the active filter criteria for the spell
/// list.
///
/// All multi-select criteria use empty sets to mean "no filter applied".
/// [apply] returns a new list containing only the spells that satisfy every
/// non-empty criterion.
@immutable
class SpellFilter {
  /// Creates a [SpellFilter].
  ///
  /// All parameters default to their "no filter" state.
  const SpellFilter({
    this.name,
    this.levels = const {},
    this.schools = const {},
    this.classes = const {},
    this.sources = const {},
  });

  /// Case-insensitive substring to match against spell names.
  ///
  /// `null` or empty string means the criterion is inactive.
  final String? name;

  /// Spell levels to include. Empty means all levels are shown.
  final Set<int> levels;

  /// School codes (single letters, e.g. `'V'`) to include.
  ///
  /// Empty means all schools are shown.
  final Set<String> schools;

  /// Classes to include. Empty means all classes are shown.
  final Set<ClassType> classes;

  /// Source acronyms (e.g. `'PHB'`) to include.
  ///
  /// Empty means all sources are shown.
  final Set<String> sources;

  /// The number of multi-select criteria that are currently active (1 per
  /// non-empty set, regardless of how many items are selected).
  int get activeCount =>
      (levels.isNotEmpty ? 1 : 0) +
      (schools.isNotEmpty ? 1 : 0) +
      (classes.isNotEmpty ? 1 : 0) +
      (sources.isNotEmpty ? 1 : 0);

  /// Whether no filter criterion is active.
  bool get isEmpty =>
      (name == null || name!.isEmpty) && activeCount == 0;

  /// Returns a copy of this filter with the given fields replaced.
  ///
  /// Pass `name: null` to clear the name criterion.
  SpellFilter copyWith({
    Object? name = _absent,
    Set<int>? levels,
    Set<String>? schools,
    Set<ClassType>? classes,
    Set<String>? sources,
  }) {
    return SpellFilter(
      name: identical(name, _absent) ? this.name : name as String?,
      levels: levels ?? this.levels,
      schools: schools ?? this.schools,
      classes: classes ?? this.classes,
      sources: sources ?? this.sources,
    );
  }

  /// Returns a filtered copy of [spells] containing only the spells that
  /// match every active criterion.
  List<Spell> apply(List<Spell> spells) =>
      spells.where(_matches).toList(growable: false);

  bool _matches(Spell spell) {
    final nameQuery = name?.trim().toLowerCase();
    if (nameQuery != null && nameQuery.isNotEmpty) {
      if (!spell.name.toLowerCase().contains(nameQuery)) return false;
    }
    if (levels.isNotEmpty && !levels.contains(spell.level)) return false;
    if (schools.isNotEmpty && !schools.contains(spell.school)) return false;
    if (classes.isNotEmpty) {
      final spellClasses = spell.classes ?? const [];
      if (!spellClasses.any(classes.contains)) return false;
    }
    if (sources.isNotEmpty && !sources.contains(spell.source)) return false;
    return true;
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpellFilter &&
          other.name == name &&
          setEquals(other.levels, levels) &&
          setEquals(other.schools, schools) &&
          setEquals(other.classes, classes) &&
          setEquals(other.sources, sources);

  @override
  int get hashCode => Object.hash(
        name,
        Object.hashAllUnordered(levels),
        Object.hashAllUnordered(schools),
        Object.hashAllUnordered(classes),
        Object.hashAllUnordered(sources),
      );
}
