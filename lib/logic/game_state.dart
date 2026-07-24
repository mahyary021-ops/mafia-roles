import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show Color;

import '../models/role.dart';
import '../models/team.dart';
import 'role_generator.dart';

/// Holds the current game's role assignments purely in RAM.
///
/// There is no persistence layer by design: nothing is written to disk or
/// any database. Calling [endGame] wipes everything, and restarting the
/// app (or the OS reclaiming memory) wipes it just the same. Navigating
/// back and forth between screens (e.g. the system back button) does NOT
/// lose anything, since this object lives above the screens in the widget
/// tree - only [endGame] (a fresh "Number of Players" pick) resets it.
class GameState extends ChangeNotifier {
  List<Role>? _assignments;

  /// Removed player numbers, grouped by the night they were removed in.
  /// `_removalsByNight[0]` is night 1's removals, `[1]` is night 2's, etc.
  /// The last entry is always the "current" (not yet ended) night.
  final List<List<int>> _removalsByNight = [[]];

  /// This night's in-progress action markers: playerNumber -> (color,
  /// label), set from the Night Actions screen. Cleared automatically
  /// whenever the night ends (or the game ends), since they represent
  /// only the current night's unfinished bookkeeping.
  final Map<int, Color> _nightMarkColors = {};
  final Map<int, String> _nightMarkLabels = {};

  /// True once roles have been generated for the current game.
  bool get hasActiveGame => _assignments != null;

  int? get playerCount => _assignments?.length;

  /// The night currently in progress (1-based).
  int get currentNight => _removalsByNight.length;

  /// Removals grouped by night, e.g. `[[3, 7], [1]]` means players 3 and 7
  /// were removed on night 1, and player 1 on night 2. The last group may
  /// be empty if no one has been removed yet on the current night.
  List<List<int>> get removalsByNight =>
      List.unmodifiable(_removalsByNight.map(List<int>.unmodifiable));

  bool isRemoved(int playerNumber) =>
      _removalsByNight.any((night) => night.contains(playerNumber));

  /// Adds/removes [playerNumber] from wherever it currently is. New
  /// removals always go into the *current* (last) night's bucket.
  void toggleRemoved(int playerNumber) {
    for (final night in _removalsByNight) {
      if (night.remove(playerNumber)) {
        notifyListeners();
        return;
      }
    }
    _removalsByNight.last.add(playerNumber);
    notifyListeners();
  }

  /// Locks in the current night's results and starts a fresh bucket for
  /// the next night. Past nights remain visible in [removalsByNight].
  void endNight() {
    _removalsByNight.add([]);
    _nightMarkColors.clear();
    _nightMarkLabels.clear();
    notifyListeners();
  }

  Color? nightMarkColor(int playerNumber) => _nightMarkColors[playerNumber];
  String? nightMarkLabel(int playerNumber) => _nightMarkLabels[playerNumber];

  void setNightMark(int playerNumber, Color color, String label) {
    _nightMarkColors[playerNumber] = color;
    _nightMarkLabels[playerNumber] = label;
    notifyListeners();
  }

  void clearNightMark(int playerNumber) {
    _nightMarkColors.remove(playerNumber);
    _nightMarkLabels.remove(playerNumber);
    notifyListeners();
  }

  void clearAllNightMarks() {
    _nightMarkColors.clear();
    _nightMarkLabels.clear();
    notifyListeners();
  }

  /// Takes a finished, already-sized role pool (one entry per player,
  /// built by the setup screens from the game master's choices), shuffles
  /// it exactly once, and locks it in. [roleFor] will always return the
  /// same role for the same player number until [endGame] is called.
  void startGame(List<Role> pool) {
    _assignments = RoleGenerator.shuffled(pool);
    _removalsByNight
      ..clear()
      ..add([]);
    _nightMarkColors.clear();
    _nightMarkLabels.clear();
    notifyListeners();
  }

  /// Returns the fixed role for [playerNumber] (1-based).
  Role roleFor(int playerNumber) {
    final assignments = _assignments;
    if (assignments == null) {
      throw StateError('No active game: startGame() has not been called.');
    }
    return assignments[playerNumber - 1];
  }

  /// All roles currently in play, one per player - used to build the
  /// Night Actions icon toolbar (which only shows roles actually present).
  List<Role> get allAssignedRoles => List.unmodifiable(_assignments ?? []);

  /// Counts of still-active (not removed) players per team - used by the
  /// roster screen's live status header.
  Map<Team, int> remainingByTeam() {
    final assignments = _assignments;
    final result = <Team, int>{};
    if (assignments == null) return result;
    for (int i = 0; i < assignments.length; i++) {
      final playerNumber = i + 1;
      if (isRemoved(playerNumber)) continue;
      final team = assignments[i].team;
      result[team] = (result[team] ?? 0) + 1;
    }
    return result;
  }

  /// Erases all assignments from memory. Called when "End Game" is
  /// pressed - this is the only thing that clears the night history.
  void endGame() {
    _assignments = null;
    _removalsByNight
      ..clear()
      ..add([]);
    _nightMarkColors.clear();
    _nightMarkLabels.clear();
    notifyListeners();
  }
}
