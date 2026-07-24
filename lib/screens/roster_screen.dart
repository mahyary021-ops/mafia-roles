import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../logic/ad_service.dart';
import '../logic/game_state.dart';
import '../models/role.dart';
import '../models/team.dart';
import '../widgets/app_background.dart';
import 'night_actions_screen.dart';

/// A spoiler view for the game master only: every player number next to
/// their assigned role, all at once (instead of tapping through cards one
/// by one). Lets the game master mark players as removed (e.g. voted out
/// or shot at night) as bookkeeping, grouped and labeled by which night
/// they were removed in, and ends the game from here.
///
/// This screen reads live from [GameState], so navigating away and back
/// (even via the system back button) never loses anything - only pressing
/// "End Game" (which starts a fresh game) clears the history.
class RosterScreen extends StatefulWidget {
  final GameState gameState;

  const RosterScreen({super.key, required this.gameState});

  @override
  State<RosterScreen> createState() => _RosterScreenState();
}

class _RosterScreenState extends State<RosterScreen> {
  final _interstitial = InterstitialAdController();

  /// Whether the "removed" section lists nights oldest-first (Night 1 at
  /// the top) or newest-first. Toggled by double-tapping any night divider.
  bool _oldestFirst = true;

  List<int> _nightOrder(int nightCount) {
    final indices = List<int>.generate(nightCount, (i) => i);
    return _oldestFirst ? indices : indices.reversed.toList();
  }

  @override
  void initState() {
    super.initState();
    // Loaded ahead of time so it's ready the instant "End Game" is
    // pressed. If it never loads (e.g. no internet), that's fine -
    // showIfReady() just skips straight to actually ending the game.
    _interstitial.preload();
  }

  @override
  void dispose() {
    _interstitial.dispose();
    super.dispose();
  }

  void _onEndNight() {
    setState(() => widget.gameState.endNight());
  }

  Future<void> _onEndGame() async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surface,
        title: const Text('End Game? / پایان بازی؟'),
        content: const Text(
          'Are you sure you want to end this game?\n'
          'آیا مطمئنید می‌خواهید از این بازی خارج شوید؟',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Cancel / انصراف'),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('End Game / پایان بازی'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;

    _interstitial.showIfReady(() {
      widget.gameState.endGame();
      if (mounted) {
        Navigator.of(context).popUntil((route) => route.isFirst);
      }
    });
  }

  /// White (diff >= 4), yellow (diff == 3), orange (diff == 2), or red
  /// (diff <= 1) - how far citizens are ahead of the combined "black side"
  /// (mafia + independent). A quick visual read on how close the game is.
  Color _statusColor(int diff) {
    if (diff <= 1) return AppColors.mafiaTeam;
    if (diff == 2) return Colors.orange;
    if (diff == 3) return Colors.amber;
    return Colors.white;
  }

  String _statusLabel(int diff) {
    if (diff <= 1) return 'Red — Critical';
    if (diff == 2) return 'Orange — Tense';
    if (diff == 3) return 'Yellow — Caution';
    return 'White — Safe';
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.gameState.playerCount ?? 0;
    final remaining = widget.gameState.remainingByTeam();
    final mafiaLeft = remaining[Team.mafia] ?? 0;
    final citizenLeft = remaining[Team.citizen] ?? 0;
    final independentLeft = remaining[Team.independent] ?? 0;
    final blackSideLeft = mafiaLeft + independentLeft;
    final diff = citizenLeft - blackSideLeft;
    final statusColor = _statusColor(diff);
    final statusLabel = _statusLabel(diff);

    final removalsByNight = widget.gameState.removalsByNight;
    final allRemoved = removalsByNight.expand((n) => n).toSet();
    final activeNumbers = [
      for (int n = 1; n <= total; n++)
        if (!allRemoved.contains(n)) n,
    ];

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Text('Full Roster / لیست کامل بازیکنان'),
          actions: [
            IconButton(
              tooltip: 'Night Actions / اعمال شب',
              icon: const Icon(Icons.nightlight_round),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) => NightActionsScreen(gameState: widget.gameState),
                  ),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Container(
                margin: const EdgeInsets.fromLTRB(16, 12, 16, 0),
                padding:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                decoration: BoxDecoration(
                  color: AppColors.surfaceVariant,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: statusColor, width: 2),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 14,
                          height: 14,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: statusColor.withOpacity(0.7),
                                blurRadius: 8,
                                spreadRadius: 1,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Game Status: $statusLabel',
                          style: TextStyle(
                            color: statusColor,
                            fontWeight: FontWeight.bold,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _StatChip(
                        label: 'Mafia', value: mafiaLeft, color: AppColors.mafiaTeam),
                    _StatChip(
                        label: 'Citizen',
                        value: citizenLeft,
                        color: AppColors.citizenTeam),
                    if (independentLeft > 0)
                      _StatChip(
                        label: 'Independent',
                        value: independentLeft,
                        color: AppColors.independentTeam,
                      ),
                  ],
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    for (final n in activeNumbers)
                      _PlayerTile(
                        playerNumber: n,
                        role: widget.gameState.roleFor(n),
                        removed: false,
                        onToggle: () => setState(
                          () => widget.gameState.toggleRemoved(n),
                        ),
                      ),
                    for (final night in _nightOrder(removalsByNight.length))
                      if (removalsByNight[night].isNotEmpty) ...[
                        GestureDetector(
                          onDoubleTap: () =>
                              setState(() => _oldestFirst = !_oldestFirst),
                          child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Row(
                            children: [
                              const Expanded(child: Divider()),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 10),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Icon(
                                      _oldestFirst
                                          ? Icons.arrow_downward
                                          : Icons.arrow_upward,
                                      size: 12,
                                      color: AppColors.textSecondary,
                                    ),
                                    const SizedBox(width: 4),
                                    Text(
                                      'Night ${night + 1}',
                                      style: const TextStyle(
                                        color: AppColors.textSecondary,
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Expanded(child: Divider()),
                            ],
                          ),
                          ),
                        ),
                        for (final n in removalsByNight[night])
                          _PlayerTile(
                            playerNumber: n,
                            role: widget.gameState.roleFor(n),
                            removed: true,
                            onToggle: () => setState(
                              () => widget.gameState.toggleRemoved(n),
                            ),
                          ),
                      ],
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _onEndNight,
                        child: Text(
                          'End Night ${widget.gameState.currentNight}',
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: _onEndGame,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.error,
                        ),
                        child: const Text('End Game'),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PlayerTile extends StatelessWidget {
  final int playerNumber;
  final Role role;
  final bool removed;
  final VoidCallback onToggle;

  const _PlayerTile({
    required this.playerNumber,
    required this.role,
    required this.removed,
    required this.onToggle,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: SizedBox(
        width: 24,
        height: 24,
        child: removed
            ? Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: role.color.withOpacity(0.25),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: role.color.withOpacity(0.6),
                        width: 1.5,
                      ),
                    ),
                  ),
                  Icon(Icons.gps_fixed, size: 12, color: role.color.withOpacity(0.7)),
                ],
              )
            : Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: role.color, shape: BoxShape.circle),
              ),
      ),
      title: Text(
        'Player $playerNumber',
        style: TextStyle(
          decoration: removed ? TextDecoration.lineThrough : null,
          color: removed ? role.color.withOpacity(0.55) : AppColors.textPrimary,
        ),
      ),
      subtitle: Text(
        '${role.name} / ${role.nameFa}',
        style: TextStyle(decoration: removed ? TextDecoration.lineThrough : null),
      ),
      trailing: IconButton(
        icon: Icon(
          removed ? Icons.replay_circle_filled_outlined : Icons.track_changes,
          color: removed ? AppColors.textSecondary : AppColors.mafiaTeam,
        ),
        tooltip: removed ? 'Restore / بازگرداندن' : 'Remove / حذف بازیکن',
        onPressed: onToggle,
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  final String label;
  final int value;
  final Color color;

  const _StatChip({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('$value',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
        Text(label, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
      ],
    );
  }
}
