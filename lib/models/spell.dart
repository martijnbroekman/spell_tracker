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

List<ClassType> parseClassTypes(Map<String, dynamic>? json) {
  if (json == null) return const [];

  final list = json['fromClassList'];
  if (list is! List) return const [];

  return list
      .map((e) => _classTypeByName[e['name']])
      .whereType<ClassType>()
      .toList(growable: false);
}

class CastingTime {
  final int? number;
  final String? unit;

  CastingTime({this.number, this.unit});

  factory CastingTime.fromJson(Map<String, dynamic> json) {
    return CastingTime(
      number: json['number'],
      unit: json['unit'],
    );
  }
}

class Distance {
  final String type;
  final int? amount;

  Distance({required this.type, this.amount});

  factory Distance.fromJson(Map<String, dynamic> json) {
    return Distance(
      type: json['type'] ?? '',
      amount: json['amount'],
    );
  }
}

class Range {
  final String type;
  final Distance distance;

  Range({required this.type, required this.distance});

  factory Range.fromJson(Map<String, dynamic> json) {


    return Range(
      type: json['type'],
      distance: json['range'] != null ?
       Distance.fromJson(json['distance'] as Map<String, dynamic>) :
       Distance(type: 'self'),
    );
  }
}

class Components {
  final bool? v; // Verbal
  final bool? s; // Somatic
  final bool? m; // Material
  final bool? r; // Royalty
  final String? material; // Material description

  Components({
    this.v,
    this.s,
    this.m,
    this.r,
    this.material,
  });

  factory Components.fromJson(Map<String, dynamic> json) {
    return Components(
      v: json['v'],
      s: json['s'],
      m: json['m'] is bool ? json['m'] : null,
      r: json['r'],
      material: json['m'] is String ? json['m'] : null,
    );
  }
}

class DurationDetail {
  final String? type;
  final int? duration;
  final String? unit;

  DurationDetail({this.type, this.duration, this.unit});

  factory DurationDetail.fromJson(dynamic json) {
    if (json is String) {
      return DurationDetail(type: json);
    }
    if (json is Map<String, dynamic>) {
      return DurationDetail(
        type: json['type'],
        duration: json['duration'],
        unit: json['unit'],
      );
    }
    return DurationDetail();
  }
}

class Duration {
  final List<DurationDetail>? time;
  final bool? concentration;

  Duration({this.time, this.concentration});

  factory Duration.fromJson(Map<String, dynamic> json) {
    return Duration(
      time: (json['time'] as List?)
          ?.map((e) => DurationDetail.fromJson(e))
          .toList(),
      concentration: json['concentration'],
    );
  }
}

class Spell {
  final String name;
  final String source;
  final int? page;
  final int level;
  final String school;
  final List<CastingTime>? time;
  final Range? range;
  final Components? components;
  final List<Duration>? duration;

  final List<String>? entries;
  final List<String>? entriesHigherLevel;
  final List<String>? damageInflict;
  final List<String>? savingThrow;
  final List<String>? conditionInflict;
  final List<String>? miscTags;
  final List<String>? areaTags;
  final List<ClassType>? classes;
  final List<String>? spellAttack;
  final List<String>? affectsCreatureType;
  final List<String>? damageResist;
  // final SpellMeta? meta;
  // final List<String>? otherSources;
  // final bool? srd;
  // final bool? basicRules;
  // final ScalingLevelDice? scalingLevelDice;

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
    // this.meta,
    // this.otherSources,
    // this.srd,
    // this.basicRules,
    // this.scalingLevelDice,
  });

  /// Full school name derived from the single-letter school code.
  String get schoolName => switch (school) {
    'A' => 'Abjuration',
    'C' => 'Conjuration',
    'D' => 'Divination',
    'E' => 'Enchantment',
    'V' => 'Evocation',
    'I' => 'Illusion',
    'N' => 'Necromancy',
    'T' => 'Transmutation',
    _ => school,
  };

  factory Spell.fromJson(Map<String, dynamic> json) {
    return Spell(
      name: json['name'] ?? '',
      source: json['source'] ?? '',
      page: json['page'],
      level: json['level'] ?? 0,
      school: json['school'] ?? '',
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
      classes: parseClassTypes(json['classes']),
      spellAttack: (json['spellAttack'] as List?)?.cast<String>(),
      affectsCreatureType:
          (json['affectsCreatureType'] as List?)?.cast<String>(),
      damageResist: (json['damageResist'] as List?)?.cast<String>(),
      // meta: json['meta'] != null
      //     ? SpellMeta.fromJson(json['meta'] as Map<String, dynamic>)
      //     : null,
      // otherSources: (json['otherSources'] as List?)?.cast<String>(),
      // srd: json['srd'],
      // basicRules: json['basicRules'],
      // scalingLevelDice: json['scalingLevelDice'] != null
      //     ? ScalingLevelDice.fromJson(json['scalingLevelDice'] as Map<String, dynamic>)
      //     : null,
    );
  }
}

class SpellMeta {
  final bool? ritual;

  SpellMeta({this.ritual});

  factory SpellMeta.fromJson(Map<String, dynamic> json) {
    return SpellMeta(
      ritual: json['ritual'],
    );
  }
}

class ScalingLevelDice {
  final String label;
  final Map<String, String> scaling;

  ScalingLevelDice({
    required this.label,
    required this.scaling,
  });

  factory ScalingLevelDice.fromJson(Map<String, dynamic> json) {
    return ScalingLevelDice(
      label: json['label'] ?? '',
      scaling: (json['scaling'] as Map<String, dynamic>?)
              ?.map((key, value) => MapEntry(key, value.toString())) ??
          {},
    );
  }
}

class Source {
  final List<Spell> spells;
  final String name;
  final String acronym;

  Source({
    required this.spells,
    required this.name,
    required this.acronym,
  });

  factory Source.fromJson(Map<String, dynamic> json) {
    return Source(
      spells: (json['spells'] as List?)
              ?.map((e) => Spell.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      name: json['name'] ?? '',
      acronym: json['acronym'] ?? '',
    );
  }
}