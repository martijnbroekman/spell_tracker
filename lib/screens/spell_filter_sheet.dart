import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:spell_tracker/models/spell.dart';
import 'package:spell_tracker/models/spell_filter.dart';
import 'package:spell_tracker/providers/spell_filter_provider.dart';

/// Opens the filter bottom sheet over [context].
void showFilterSheet(BuildContext context) {
  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (_) => const _FilterSheet(),
  );
}

class _FilterSheet extends StatelessWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.65,
      minChildSize: 0.4,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return ClipRRect(
          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
          child: Material(
            color: Theme.of(context).colorScheme.surface,
            child: CustomScrollView(
              controller: scrollController,
              slivers: const [
                SliverToBoxAdapter(child: _SheetHandle()),
                SliverToBoxAdapter(child: _SheetHeader()),
                SliverToBoxAdapter(child: Divider(height: 1)),
                SliverToBoxAdapter(child: _LevelFilterSection()),
                SliverToBoxAdapter(child: Divider(height: 1)),
                SliverToBoxAdapter(child: _SchoolFilterSection()),
                SliverToBoxAdapter(child: Divider(height: 1)),
                SliverToBoxAdapter(child: _ClassFilterSection()),
                SliverToBoxAdapter(child: Divider(height: 1)),
                SliverToBoxAdapter(child: _SourceFilterSection()),
                SliverToBoxAdapter(child: SizedBox(height: 32)),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _SheetHandle extends StatelessWidget {
  const _SheetHandle();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.outlineVariant,
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }
}

class _SheetHeader extends ConsumerWidget {
  const _SheetHeader();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(spellFilterProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Filter Spells',
              style: theme.textTheme.titleLarge,
            ),
          ),
          if (!filter.isEmpty)
            TextButton(
              onPressed: () => ref
                  .read(spellFilterProvider.notifier)
                  .set(const SpellFilter()),
              child: const Text('Clear all'),
            ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel(this.title);

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleSmall,
      ),
    );
  }
}

class _ChipGroup extends StatelessWidget {
  const _ChipGroup({required this.children});

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Wrap(spacing: 8, runSpacing: 4, children: children),
    );
  }
}

class _LevelFilterSection extends ConsumerWidget {
  const _LevelFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      spellFilterProvider.select((f) => f.levels),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Spell Level'),
        _ChipGroup(
          children: [
            for (final level in List.generate(10, (i) => i))
              FilterChip(
                label: Text(level == 0 ? 'Cantrip' : '$level'),
                selected: selected.contains(level),
                onSelected: (on) {
                  final next = Set<int>.of(selected);
                  on ? next.add(level) : next.remove(level);
                  ref
                      .read(spellFilterProvider.notifier)
                      .set(ref.read(spellFilterProvider).copyWith(levels: next));
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _SchoolFilterSection extends ConsumerWidget {
  const _SchoolFilterSection();

  static const _schools = [
    ('A', 'Abjuration'),
    ('C', 'Conjuration'),
    ('D', 'Divination'),
    ('E', 'Enchantment'),
    ('V', 'Evocation'),
    ('I', 'Illusion'),
    ('N', 'Necromancy'),
    ('T', 'Transmutation'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      spellFilterProvider.select((f) => f.schools),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('School'),
        _ChipGroup(
          children: [
            for (final (code, label) in _schools)
              FilterChip(
                label: Text(label),
                selected: selected.contains(code),
                onSelected: (on) {
                  final next = Set<String>.of(selected);
                  on ? next.add(code) : next.remove(code);
                  ref
                      .read(spellFilterProvider.notifier)
                      .set(
                        ref.read(spellFilterProvider).copyWith(schools: next),
                      );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _ClassFilterSection extends ConsumerWidget {
  const _ClassFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      spellFilterProvider.select((f) => f.classes),
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Class'),
        _ChipGroup(
          children: [
            for (final cls in ClassType.values)
              FilterChip(
                label: Text(_className(cls)),
                selected: selected.contains(cls),
                onSelected: (on) {
                  final next = Set<ClassType>.of(selected);
                  on ? next.add(cls) : next.remove(cls);
                  ref
                      .read(spellFilterProvider.notifier)
                      .set(
                        ref.read(spellFilterProvider).copyWith(classes: next),
                      );
                },
              ),
          ],
        ),
      ],
    );
  }
}

class _SourceFilterSection extends ConsumerWidget {
  const _SourceFilterSection();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selected = ref.watch(
      spellFilterProvider.select((f) => f.sources),
    );
    final sourcesAsync = ref.watch(availableSourcesProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const _SectionLabel('Source Book'),
        sourcesAsync.when(
          data: (sources) => _ChipGroup(
            children: [
              for (final source in sources)
                FilterChip(
                  label: Text(source),
                  selected: selected.contains(source),
                  onSelected: (on) {
                    final next = Set<String>.of(selected);
                    on ? next.add(source) : next.remove(source);
                    ref
                        .read(spellFilterProvider.notifier)
                        .set(
                          ref
                              .read(spellFilterProvider)
                              .copyWith(sources: next),
                        );
                  },
                ),
            ],
          ),
          loading: () => const Padding(
            padding: EdgeInsets.all(16),
            child: CircularProgressIndicator(),
          ),
          error: (_, _) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}

String _className(ClassType c) {
  final name = c.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
