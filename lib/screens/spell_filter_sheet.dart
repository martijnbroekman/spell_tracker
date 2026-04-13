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

class _FilterSheet extends ConsumerWidget {
  const _FilterSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final filter = ref.watch(spellFilterProvider);
    final sourcesAsync = ref.watch(availableSourcesProvider);
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(context).bottom,
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: Material(
          color: theme.colorScheme.surface,
          child: SafeArea(
            top: false,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const _SheetHandle(),
                _SheetHeader(filter: filter),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _MultiSelectField<int>(
                        label: 'Spell Level',
                        options: List.generate(10, (i) => i),
                        selected: filter.levels,
                        labelOf: (l) => l == 0 ? 'Cantrip' : 'Level $l',
                        emptyLabel: 'All levels',
                        onChanged: (next) => ref
                            .read(spellFilterProvider.notifier)
                            .set(filter.copyWith(levels: next)),
                      ),
                      const SizedBox(height: 12),
                      _MultiSelectField<String>(
                        label: 'School',
                        options: const [
                          'A', 'C', 'D', 'E', 'V', 'I', 'N', 'T',
                        ],
                        selected: filter.schools,
                        labelOf: _schoolLabel,
                        emptyLabel: 'All schools',
                        onChanged: (next) => ref
                            .read(spellFilterProvider.notifier)
                            .set(filter.copyWith(schools: next)),
                      ),
                      const SizedBox(height: 12),
                      _MultiSelectField<ClassType>(
                        label: 'Class',
                        options: ClassType.values,
                        selected: filter.classes,
                        labelOf: _className,
                        emptyLabel: 'All classes',
                        onChanged: (next) => ref
                            .read(spellFilterProvider.notifier)
                            .set(filter.copyWith(classes: next)),
                      ),
                      const SizedBox(height: 12),
                      sourcesAsync.when(
                        data: (sources) => _MultiSelectField<String>(
                          label: 'Source Book',
                          options: sources,
                          selected: filter.sources,
                          labelOf: (s) => s,
                          emptyLabel: 'All sources',
                          onChanged: (next) => ref
                              .read(spellFilterProvider.notifier)
                              .set(filter.copyWith(sources: next)),
                        ),
                        loading: () => const _FieldSkeleton(label: 'Source Book'),
                        error: (_, _) => const SizedBox.shrink(),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
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

class _SheetHeader extends StatelessWidget {
  const _SheetHeader({required this.filter});

  final SpellFilter filter;

  @override
  Widget build(BuildContext context) {
    return Consumer(
      builder: (context, ref, _) => Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 12, 12),
        child: Row(
          children: [
            Expanded(
              child: Text(
                'Filter Spells',
                style: Theme.of(context).textTheme.titleLarge,
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
      ),
    );
  }
}

/// A tappable form-field-style row that opens a multi-select dialog.
class _MultiSelectField<T> extends StatelessWidget {
  const _MultiSelectField({
    required this.label,
    required this.options,
    required this.selected,
    required this.labelOf,
    required this.emptyLabel,
    required this.onChanged,
  });

  final String label;
  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;
  final String emptyLabel;
  final ValueChanged<Set<T>> onChanged;

  String get _summary {
    if (selected.isEmpty) return emptyLabel;
    if (selected.length == options.length) return emptyLabel;
    final labels = options
        .where(selected.contains)
        .map(labelOf)
        .toList();
    if (labels.length <= 3) return labels.join(', ');
    return '${labels.take(2).join(', ')} +${labels.length - 2} more';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isActive = selected.isNotEmpty && selected.length < options.length;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        InkWell(
          onTap: () => _openDialog(context),
          borderRadius: BorderRadius.circular(6),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            decoration: BoxDecoration(
              color: isActive
                  ? theme.colorScheme.primary.withValues(alpha: 0.08)
                  : theme.colorScheme.surface,
              border: Border.all(
                color: isActive
                    ? theme.colorScheme.primary
                    : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Text(
                    _summary,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurface,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  Icons.arrow_drop_down,
                  color: isActive
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _openDialog(BuildContext context) async {
    final result = await showDialog<Set<T>>(
      context: context,
      builder: (_) => _MultiSelectDialog<T>(
        title: label,
        options: options,
        selected: selected,
        labelOf: labelOf,
      ),
    );
    if (result != null) onChanged(result);
  }
}

/// A skeleton placeholder used while [availableSourcesProvider] is loading.
class _FieldSkeleton extends StatelessWidget {
  const _FieldSkeleton({required this.label});

  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: theme.textTheme.labelLarge),
        const SizedBox(height: 4),
        Container(
          height: 48,
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(6),
          ),
          child: const Center(
            child: SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ],
    );
  }
}

class _MultiSelectDialog<T> extends StatefulWidget {
  const _MultiSelectDialog({
    required this.title,
    required this.options,
    required this.selected,
    required this.labelOf,
  });

  final String title;
  final List<T> options;
  final Set<T> selected;
  final String Function(T) labelOf;

  @override
  State<_MultiSelectDialog<T>> createState() => _MultiSelectDialogState<T>();
}

class _MultiSelectDialogState<T> extends State<_MultiSelectDialog<T>> {
  late Set<T> _selected;

  @override
  void initState() {
    super.initState();
    _selected = Set<T>.of(widget.selected);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AlertDialog(
      title: Text(widget.title),
      contentPadding: const EdgeInsets.symmetric(vertical: 8),
      content: SizedBox(
        width: double.maxFinite,
        child: ListView.builder(
          shrinkWrap: true,
          itemCount: widget.options.length,
          itemBuilder: (context, index) {
            final option = widget.options[index];
            return CheckboxListTile(
              title: Text(
                widget.labelOf(option),
                style: theme.textTheme.bodyMedium,
              ),
              value: _selected.contains(option),
              dense: true,
              onChanged: (checked) {
                setState(() {
                  if (checked == true) {
                    _selected.add(option);
                  } else {
                    _selected.remove(option);
                  }
                });
              },
            );
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, <T>{}),
          child: const Text('Clear'),
        ),
        FilledButton(
          onPressed: () => Navigator.pop(context, _selected),
          child: const Text('Done'),
        ),
      ],
    );
  }
}

String _schoolLabel(String code) => switch (code) {
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

String _className(ClassType c) {
  final name = c.name;
  return '${name[0].toUpperCase()}${name.substring(1)}';
}
