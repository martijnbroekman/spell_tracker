import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Manages the selected top-level navigation index.
///
/// `0` = Spells, `1` = Spell Books.
class NavIndexNotifier extends Notifier<int> {
  @override
  int build() => 0;

  /// Sets the active navigation index to [index].
  void set(int index) => state = index;
}

/// The currently selected top-level navigation index.
final navIndexProvider =
    NotifierProvider<NavIndexNotifier, int>(NavIndexNotifier.new);
