import 'package:flutter/foundation.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:uuid/uuid.dart';

const _uuid = Uuid();

/// A named user-created collection of spells.
@immutable
class SpellBook {
  /// Creates a [SpellBook] with the given [id], [name], and [spellKeys].
  const SpellBook({
    required this.id,
    required this.name,
    required this.spellKeys,
  });

  /// Creates a new [SpellBook] with a generated UUID and an empty spell list.
  factory SpellBook.create({required String name}) => SpellBook(
        id: _uuid.v4(),
        name: name,
        spellKeys: const {},
      );

  /// Deserializes a [SpellBook] from a JSON map produced by [toJson].
  factory SpellBook.fromJson(Map<String, dynamic> json) => SpellBook(
        id: json['id'] as String,
        name: json['name'] as String,
        spellKeys:
            (json['spellKeys'] as List<dynamic>).cast<String>().toSet(),
      );

  /// A unique identifier for this spell book (UUID v4).
  final String id;

  /// The display name of this spell book.
  final String name;

  /// The set of spell keys contained in this book.
  ///
  /// Each key has the form `"SOURCE::Spell Name"` — see [keyFor].
  final Set<String> spellKeys;

  /// Returns the spell key for [spell], used to identify it in [spellKeys].
  static String keyFor(Spell spell) => '${spell.source}::${spell.name}';

  /// Returns a copy of this book with the given fields replaced.
  SpellBook copyWith({String? name, Set<String>? spellKeys}) => SpellBook(
        id: id,
        name: name ?? this.name,
        spellKeys: spellKeys ?? this.spellKeys,
      );

  /// Serializes this book to a JSON-compatible map.
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'spellKeys': spellKeys.toList(),
      };

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SpellBook &&
          other.id == id &&
          other.name == name &&
          setEquals(other.spellKeys, spellKeys);

  @override
  int get hashCode => Object.hash(id, name, Object.hashAllUnordered(spellKeys));
}
