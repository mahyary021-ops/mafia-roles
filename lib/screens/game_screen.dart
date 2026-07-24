import 'package:flutter/material.dart';

import '../logic/game_state.dart';
import '../widgets/app_background.dart';
import '../widgets/role_reveal_card.dart';
import 'roster_screen.dart';

/// The single screen that steps through every player, one at a time.
///
/// Internally this just advances an index rather than pushing a new route
/// per player - simpler, faster, and it's what "no unnecessary features"
/// calls for. Giving [RoleRevealCard] a fresh key per player makes each
/// new player's card start closed automatically.
class GameScreen extends StatefulWidget {
  final GameState gameState;

  const GameScreen({super.key, required this.gameState});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  int _currentPlayerNumber = 1;

  bool get _isLastPlayer =>
      _currentPlayerNumber == widget.gameState.playerCount;

  bool get _isFirstPlayer => _currentPlayerNumber == 1;

  void _onNext() {
    setState(() => _currentPlayerNumber++);
  }

  void _onPrevious() {
    if (!_isFirstPlayer) {
      setState(() => _currentPlayerNumber--);
    }
  }

  void _openRoster() {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RosterScreen(gameState: widget.gameState),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final role = widget.gameState.roleFor(_currentPlayerNumber);

    return PopScope(
      // Prevent leaving mid-game via the system back gesture, so the game
      // master can only exit through the explicit "End Game" action.
      canPop: false,
      child: AppBackground(
        child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: Text('Player $_currentPlayerNumber / بازیکن $_currentPlayerNumber'),
          actions: [
            IconButton(
              tooltip: 'Full Roster / لیست کامل بازیکنان',
              icon: const Icon(Icons.list_alt_rounded),
              onPressed: _openRoster,
            ),
          ],
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: Center(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 24),
                      child: RoleRevealCard(
                        key: ValueKey(_currentPlayerNumber),
                        role: role,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 24,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _isFirstPlayer ? null : _onPrevious,
                        child: const Text('Previous / قبلی'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: ElevatedButton(
                        onPressed: _isLastPlayer ? _openRoster : _onNext,
                        style: _isLastPlayer
                            ? ElevatedButton.styleFrom(
                                backgroundColor:
                                    Theme.of(context).colorScheme.error,
                              )
                            : null,
                        child: Text(
                          _isLastPlayer
                              ? 'Full Roster / لیست نهایی'
                              : 'Next / بعدی',
                        ),
                      ),
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
