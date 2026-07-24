import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../logic/game_state.dart';
import '../widgets/app_background.dart';
import '../widgets/neon_dot_frame.dart';
import 'help_screen.dart';
import 'mafia_count_screen.dart';
import 'rulebook_screen.dart';

/// Screen 1 — "تعداد بازیکنان" (Number of players).
///
/// Tapping a number (or entering a custom one via "بیشتر") moves on to
/// choosing the mafia/citizen/independent split, then role selection.
class PlayerCountScreen extends StatelessWidget {
  final GameState gameState;

  const PlayerCountScreen({super.key, required this.gameState});

  static const List<int> _gridCounts = [3, 4, 5, 6, 7, 8, 9, 10, 11];

  void _goToMafiaCount(BuildContext context, int count) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) =>
            MafiaCountScreen(totalPlayers: count, gameState: gameState),
      ),
    );
  }

  Future<void> _onMoreTap(BuildContext context) async {
    final controller = TextEditingController();
    final count = await showDialog<int>(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.surface,
          title: const Text('More Players (13–100) / بیشتر'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            autofocus: true,
            decoration: const InputDecoration(hintText: 'e.g. 20'),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel / انصراف'),
            ),
            ElevatedButton(
              onPressed: () {
                final value = int.tryParse(controller.text);
                if (value == null || value < 13 || value > 100) return;
                Navigator.of(context).pop(value);
              },
              child: const Text('Confirm / تأیید'),
            ),
          ],
        );
      },
    );
    if (count != null && context.mounted) {
      _goToMafiaCount(context, count);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(
          title: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Number of Players',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              Text(
                'تعداد بازیکنان',
                style: TextStyle(fontSize: 12, color: AppColors.textGold),
              ),
            ],
          ),
          leading: IconButton(
            tooltip: 'Help / راهنما',
            icon: const Icon(Icons.help_outline_rounded, color: AppColors.textGold),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const HelpScreen()),
              );
            },
          ),
          actions: [
            IconButton(
              tooltip: 'Rulebook / رول‌بوک',
              icon: const Icon(Icons.bolt_rounded, color: AppColors.textGold),
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const RulebookScreen()),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              children: [
                Expanded(
                  child: GridView.count(
                    crossAxisCount: 3,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    childAspectRatio: 1,
                    children: _gridCounts
                        .map(
                          (count) => _NumberButton(
                            label: '$count',
                            onTap: () => _goToMafiaCount(context, count),
                          ),
                        )
                        .toList(),
                  ),
                ),
                const SizedBox(height: 16),
                Center(
                  child: SizedBox(
                    width: 110,
                    height: 90,
                    child: _NumberButton(
                      label: '12',
                      fontSize: 32,
                      onTap: () => _goToMafiaCount(context, 12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                _MorePlayersButton(onTap: () => _onMoreTap(context)),
                const SizedBox(height: 16),
                const _CreditLine(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small, unobtrusive attribution shown at the bottom of the first screen -
/// not an ad, just a source credit so people know who made the app.
class _CreditLine extends StatelessWidget {
  const _CreditLine();

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Mafia Psychology Academy',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
        ),
        SizedBox(height: 2),
        Text(
          'Mahyar Yaghoobalipour',
          style: TextStyle(
            color: AppColors.textGold,
            fontFamily: 'serif',
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ],
    );
  }
}

/// A bigger, English-labeled button for entering a custom player count
/// above 12 - separate from the numbered grid so it stands out.
class _MorePlayersButton extends StatelessWidget {
  final VoidCallback onTap;

  const _MorePlayersButton({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return NeonDotFrame(
      dotCount: 4,
      dotSize: 4,
      borderRadius: 18,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: const Padding(
            padding: EdgeInsets.symmetric(vertical: 18),
            child: Center(
              child: Text(
                'More Players',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NumberButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  final double fontSize;

  const _NumberButton({
    required this.label,
    required this.onTap,
    this.fontSize = 26,
  });

  @override
  Widget build(BuildContext context) {
    return NeonDotFrame(
      dotCount: 3,
      dotSize: 3.5,
      borderRadius: 18,
      child: Material(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: Colors.white, width: 1.5),
            ),
            child: Center(
              child: Text(
                label,
                style: TextStyle(
                  fontSize: fontSize,
                  fontWeight: FontWeight.bold,
                  color: AppColors.brightViolet,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
