import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/screens/spell_detail_screen.dart';

/// A [ListTile] that displays a single [spell] with its school icon, name,
/// level, and source. Tapping navigates to [SpellDetailScreen].
class SpellTile extends StatelessWidget {
  const SpellTile({super.key, required this.spell});

  /// The spell to display.
  final Spell spell;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final levelLabel = spell.level == 0 ? 'Cantrip' : 'Level ${spell.level}';

    return ListTile(
      leading: _SchoolIcon(schoolName: spell.schoolName),
      title: Text(spell.name),
      subtitle: Text(
        '$levelLabel · ${spell.source}',
        style: TextStyle(color: colorScheme.onSurfaceVariant),
      ),
      trailing: const Icon(Icons.chevron_right),
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute<void>(
          builder: (_) => SpellDetailScreen(spell: spell),
        ),
      ),
    );
  }
}

class _SchoolIcon extends StatelessWidget {
  const _SchoolIcon({required this.schoolName});

  final String schoolName;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: SvgPicture.asset(
        'assets/${schoolName.toLowerCase()}.svg',
        width: 40,
        height: 40,
        fit: BoxFit.cover,
      ),
    );
  }
}
