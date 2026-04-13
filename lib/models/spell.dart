/// Data models for D&D 5e spells, sources, and related types.
library;

/// A D&D 5e character class that can learn spells.
enum ClassType {
  artificer,
  barbarian,
  bard,
  cleric,
  druid,
  fighter,
  monk,
  paladin,
  ranger,
  rogue,
  sorcerer,
  warlock,
  wizard,
}

const _classTypeByName = {
  'Artificer': ClassType.artificer,
  'Barbarian': ClassType.barbarian,
  'Bard': ClassType.bard,
  'Cleric': ClassType.cleric,
  'Druid': ClassType.druid,
  'Fighter': ClassType.fighter,
  'Monk': ClassType.monk,
  'Paladin': ClassType.paladin,
  'Ranger': ClassType.ranger,
  'Rogue': ClassType.rogue,
  'Sorcerer': ClassType.sorcerer,
  'Warlock': ClassType.warlock,
  'Wizard': ClassType.wizard,
};

/// Parses a list of [ClassType]s from the `classes` field of a spell JSON
/// object, returning an empty list when the field is absent or malformed.
List<ClassType> parseClassTypes(Map<String, dynamic>? json) {
  if (json == null) return const [];
  final list = json['fromClassList'];
  if (list is! List) return const [];
  return list
      .map((e) => _classTypeByName[e['name']])
      .whereType<ClassType>()
      .toList(growable: false);
}

/// The casting time of a spell expressed as a number and a unit.
class CastingTime {
  /// The numeric count, e.g. `1` for "1 action".
  final int? number;

  /// The time unit, e.g. `"action"`, `"bonus action"`, or `"minute"`.
  final String? unit;

  CastingTime({this.number, this.unit});

  factory CastingTime.fromJson(Map<String, dynamic> json) {
    return CastingTime(
      number: json['number'] as int?,
      unit: json['unit'] as String?,
    );
  }
}

/// The distance component of a spell's range.
class Distance {
  /// The distance kind, e.g. `"feet"`, `"miles"`, or `"self"`.
  final String type;

  /// The numeric amount when [type] is a measurable unit.
  final int? amount;

  Distance({required this.type, this.amount});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      type: json['type'] as String? ?? '',
      amount: json['amount'] as int?,
    );
  }
}

/// The targeting range of a spell.
class Range {
  /// The range category, e.g. `"self"`, `"touch"`, `"point"`, or
  /// `"special"`.
  final String type;

  /// The specific distance when [type] is `"point"` or similar.
  final Distance distance;

  Range({required this.type, required this.distance});

  factory Range.fromJson(Map<String, dynamic> json) {
    return Range(
      type: json['type'] as String? ?? 'special',
      distance: json['distance'] != null
          ? Distance.fromJson(json['distance'] as Map<String, dynamic>)
          : Distance(type: json['type'] as String? ?? 'self'),
    );
  }
}

/// The material, verbal, and somatic components required to cast a spell.
class Components {
  /// Whether the spell requires a verbal component.
  final bool? v;

  /// Whether the spell requires a somatic component.
  final bool? s;

  /// Whether the spell requires a material component (true/false only;
  /// see [material] for a description).
  final bool? m;

  /// Whether the spell requires a royalty component.
  final bool? r;

  /// A description of the required material component, if any.
  final String? material;

  Components({this.v, this.s, this.m, this.r, this.material});

  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(
      v: json['v'] as bool?,
      s: json['s'] as bool?,
      m: json['m'] is bool ? json['m'] as bool : null,
      r: json['r'] as bool?,
      material: json['m'] is String ? json['m'] as String : null,
    );
  }
}

/// How long a spell's effect lasts.
class Duration {
  /// The kind of duration: `"instant"`, `"timed"`, `"permanent"`,
  /// or `"special"`.
  final String type;

  /// The numeric length for `"timed"` durations (e.g. `8` for 8 hours).
  final int? amount;

  /// The time unit for `"timed"` durations: `"round"`, `"minute"`,
  /// `"hour"`, or `"day"`.
  final String? unit;

  /// Whether the spell requires concentration.
  final bool concentration;

  Duration({
    required this.type,
    this.amount,
    this.unit,
    this.concentration = false,
  });

  factory Duration.fromJson(Map<String, dynamic> json) {
    final nested = json['duration'] as Map<String, dynamic>?;
    return Duration(
      type: json['type'] as String? ?? 'special',
      amount: nested?['amount'] as int?,
      unit: nested?['type'] as String?,
      concentration: json['concentration'] as bool? ?? false,
    );
  }
}

/// Returns the full school name for a single-letter [code], e.g. `'V'` →
/// `'Evocation'`. Returns [code] unchanged when unrecognised.
String schoolNameFromCode(String code) => switch (code) {
  'A' => 'Abjuration',
  'C' => 'Conjuration',
  'D' => 'Divination',
  'E' => 'Enchantment',
  'V' => 'Evocation',
  'I' => 'Illusion',
  'N' => 'Necromancy',
  'T' => 'Transmutation',
  _ => code,
};

/// A single D&D 5e spell with all of its properties.
class Spell {
  /// The spell's name.
  final String name;

  /// The source book abbreviation, e.g. `"PHB"`.
  final String source;

  /// The page number in [source], if known.
  final int? page;

  /// The spell level. `0` denotes a cantrip.
  final int level;

  /// A single-letter school code, e.g. `"V"` for Evocation.
  ///
  /// Use [schoolName] for the human-readable form.
  final String school;

  /// One or more casting times.
  final List<CastingTime>? time;

  /// The targeting range of the spell.
  final Range? range;

  /// The components required to cast the spell.
  final Components? components;

  /// The duration entries for the spell.
  final List<Duration>? duration;

  /// Plain-text description paragraphs.
  final List<String>? entries;

  /// Description of the spell when cast at a higher level.
  final List<String>? entriesHigherLevel;

  /// Damage types inflicted by the spell.
  final List<String>? damageInflict;

  /// Saving throw types required by the spell.
  final List<String>? savingThrow;

  /// Conditions the spell can inflict.
  final List<String>? conditionInflict;

  /// Miscellaneous mechanic tags.
  final List<String>? miscTags;

  /// Area-of-effect shape tags.
  final List<String>? areaTags;

  /// Classes that have access to this spell.
  final List<ClassType>? classes;

  /// Whether the spell uses a melee or ranged spell attack.
  final List<String>? spellAttack;

  /// Creature types affected by the spell.
  final List<String>? affectsCreatureType;

  /// Damage types the spell grants resistance to.
  final List<String>? damageResist;

  Spell({
    required this.name,
    required this.source,
    this.page,
    required this.level,
    required this.school,
    this.time,
    this.range,
    this.components,
    this.duration,
    this.entries,
    this.entriesHigherLevel,
    this.damageInflict,
    this.savingThrow,
    this.conditionInflict,
    this.miscTags,
    this.areaTags,
    this.classes,
    this.spellAttack,
    this.affectsCreatureType,
    this.damageResist,
  });

  /// Full school name derived from the single-letter [school] code.
  String get schoolName => schoolNameFromCode(school);

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'] as String? ?? '',
      source: json['source'] as String? ?? '',
      page: json['page'] as int?,
      level: json['level'] as int? ?? 0,
      school: json['school'] as String? ?? '',
      time: (json['time'] as List?)
          ?.map((e) => CastingTime.fromJson(e as Map<String, dynamic>))
          .toList(),
      range: json['range'] != null
          ? Range.fromJson(json['range'] as Map<String, dynamic>)
          : null,
      components: json['components'] != null
          ? Components.fromJson(json['components'] as Map<String, dynamic>)
          : null,
      duration: (json['duration'] as List?)
          ?.map((e) => Duration.fromJson(e as Map<String, dynamic>))
          .toList(),
      entries: (json['entries'] as List?)?.whereType<String>().toList(),
      entriesHigherLevel:
          (json['entriesHigherLevel'] as List?)?.whereType<String>().toList(),
      damageInflict: (json['damageInflict'] as List?)?.cast<String>(),
      savingThrow: (json['savingThrow'] as List?)?.cast<String>(),
      conditionInflict: (json['conditionInflict'] as List?)?.cast<String>(),
      miscTags: (json['miscTags'] as List?)?.cast<String>(),
      areaTags: (json['areaTags'] as List?)?.cast<String>(),
      classes: parseClassTypes(json['classes'] as Map<String, dynamic>?),
      spellAttack: (json['spellAttack'] as List?)?.cast<String>(),
      affectsCreatureType:
          (json['affectsCreatureType'] as List?)?.cast<String>(),
      damageResist: (json['damageResist'] as List?)?.cast<String>(),
    );
  }
}

/// A named spell source (book) containing a collection of [Spell]s.
class Source {
  /// The spells published in this source.
  final List<Spell> spells;

  /// The full name of the source book.
  final String name;

  /// The short acronym used to identify the source, e.g. `"PHB"`.
  final String acronym;

  Source({required this.spells, required this.name, required this.acronym});

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      spells: (json['spells'] as List?)
              ?.map((e) => Spell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      name: json['name'] as String? ?? '',
      acronym: json['acronym'] as String? ?? '',
    );
  }
}
