import 'package:flutter/material.dart';
import 'package:spell_tracker/models/spell.dart';

/// Shows all details for a single [Spell].
class SpellDetailScreen extends StatelessWidget {
  const SpellDetailScreen({super.key, required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(spell.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _SchoolLevelHeader(spell: spell),
            const SizedBox(height: 16),
            _QuickStatsCard(spell: spell),
            if (spell.components?.material != null) ...[
              const SizedBox(height: 8),
              _MaterialComponent(material: spell.components!.material!),
            ],
            if (spell.entries?.isNotEmpty == true) ...[
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Description'),
              const SizedBox(height: 8),
              _Entries(entries: spell.entries!),
            ],
            if (spell.entriesHigherLevel?.isNotEmpty == true) ...[
              const SizedBox(height: 20),
              const _SectionHeader(title: 'At Higher Levels'),
              const SizedBox(height: 8),
              _Entries(entries: spell.entriesHigherLevel!),
            ],
            if (spell.classes?.isNotEmpty == true) ...[
              const SizedBox(height: 20),
              const _SectionHeader(title: 'Available to'),
              const SizedBox(height: 8),
              _ClassChips(classes: spell.classes!),
            ],
            const SizedBox(height: 20),
            _SourceLine(spell: spell),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }
}

class _SchoolLevelHeader extends StatelessWidget {
  const _SchoolLevelHeader({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final levelLabel =
        spell.level == 0 ? 'Cantrip' : 'Level ${spell.level} spell';

    return Text(
      '$levelLabel · ${spell.schoolName}',
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.w600,
      ),
    );
  }
}

class _QuickStatsCard extends StatelessWidget {
  const _QuickStatsCard({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        child: Column(
          children: [
            _StatRow(label: 'Casting Time', value: _castingTime(spell.time)),
            const Divider(height: 16),
            _StatRow(label: 'Range', value: _range(spell.range)),
            const Divider(height: 16),
            _StatRow(label: 'Duration', value: _duration(spell.duration)),
            const Divider(height: 16),
            _StatRow(
              label: 'Components',
              value: _components(spell.components),
            ),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: 120,
          child: Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}

class _MaterialComponent extends StatelessWidget {
  const _MaterialComponent({required this.material});

  final String material;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Text(
      'Material: $material',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
        fontStyle: FontStyle.italic,
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(
        fontWeight: FontWeight.bold,
      ),
    );
  }
}

class _Entries extends StatelessWidget {
  const _Entries({required this.entries});

  final List<String> entries;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: entries
          .map(
            (entry) => Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Text(entry, style: Theme.of(context).textTheme.bodyMedium),
            ),
          )
          .toList(),
    );
  }
}

class _ClassChips extends StatelessWidget {
  const _ClassChips({required this.classes});

  final List<ClassType> classes;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 4,
      children: classes.map((c) => Chip(label: Text(_className(c)))).toList(),
    );
  }
}

class _SourceLine extends StatelessWidget {
  const _SourceLine({required this.spell});

  final Spell spell;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final page = spell.page != null ? ', p. ${spell.page}' : '';
    return Text(
      'Source: ${spell.source}$page',
      style: theme.textTheme.bodySmall?.copyWith(
        color: theme.colorScheme.onSurfaceVariant,
      ),
    );
  }
}

String _castingTime(List<CastingTime>? times) {
  if (times == null || times.isEmpty) return '—';
  final t = times.first;
  return '${t.number ?? ''} ${t.unit ?? ''}'.trim();
}

String _range(Range? range) {
  if (range == null) return '—';
  return switch (range.type) {
    'self' => 'Self',
    'touch' => 'Touch',
    'sight' => 'Sight',
    'unlimited' => 'Unlimited',
    'special' => 'Special',
    _ when range.distance.amount != null =>
      '${range.distance.amount} ${range.distance.type}',
    _ => range.distance.type,
  };
}

String _duration(List<Duration>? durations) {
  if (durations == null || durations.isEmpty) return '—';
  final d = durations.first;
  final detail = d.time?.firstOrNull;

  final base = switch (detail?.type) {
    'instant' => 'Instantaneous',
    'timed' => '${detail?.duration ?? ''} ${detail?.unit ?? ''}'.trim(),
    'permanent' => 'Until dispelled',
    _ => detail?.type ?? '—',
  };

  return d.concentration == true ? 'Concentration, up to $base' : base;
}

String _components(Components? c) {
  if (c == null) return '—';
  final parts = [
    if (c.v == true) 'V',
    if (c.s == true) 'S',
    if (c.m == true || c.material != null) 'M',
    if (c.r == true) 'R',
  ];
  return parts.isEmpty ? '—' : parts.join(', ');
}

String _className(ClassType c) {
  final name = c.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
