import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../constants/app_colors.dart';
import '../logic/game_state.dart';
import '../models/role.dart';
import '../models/role_type.dart';
import '../models/team.dart';
import '../widgets/app_background.dart';

/// A first version of a "night board" for the game master: tap a role
/// icon to arm it, then tap a player to apply that role's effect to them
/// - their name lights up in a color that says what happened.
///
/// This is a general-purpose tool, not a full rules engine for every one
/// of the game's 28 roles: it groups roles into six broad effect types
/// (shot / saved / silenced / cured / blocked / other) and handles the two
/// interactions explicitly asked for (Doctor undoing a Sniper/Godfather
/// shot, Priest undoing Natasha's silence). Anything more specific is
/// still up to the game master's own judgment - see the note at the
/// bottom of this screen.
class NightActionsScreen extends StatefulWidget {
  final GameState gameState;

  const NightActionsScreen({super.key, required this.gameState});

  @override
  State<NightActionsScreen> createState() => _NightActionsScreenState();
}

enum _Effect { shot, saved, silenced, cured, blocked, info }

class _NightActionsScreenState extends State<NightActionsScreen> {
  RoleType? _armedType;
  Role? _armedRole;

  _Effect _effectFor(RoleType type) {
    switch (type) {
      case RoleType.godfather:
      case RoleType.mafia:
      case RoleType.sniper:
      case RoleType.strongman:
        return _Effect.shot;
      case RoleType.doctor:
      case RoleType.commander:
        return _Effect.saved;
      case RoleType.priest:
        return _Effect.cured;
      case RoleType.natasha:
        return _Effect.silenced;
      case RoleType.bartender:
      case RoleType.enchanter:
        return _Effect.blocked;
      default:
        return _Effect.info;
    }
  }

  Color _colorForEffect(_Effect e) {
    switch (e) {
      case _Effect.shot:
        return Colors.redAccent;
      case _Effect.saved:
      case _Effect.cured:
        return Colors.greenAccent;
      case _Effect.silenced:
        return Colors.blueGrey;
      case _Effect.blocked:
        return Colors.brown;
      case _Effect.info:
        return Colors.purpleAccent;
    }
  }

  String _labelForEffect(_Effect e, Role role) {
    switch (e) {
      case _Effect.shot:
        return 'Shot (${role.name}) / شات (${role.nameFa})';
      case _Effect.saved:
        return 'Saved (${role.name}) / سیو (${role.nameFa})';
      case _Effect.cured:
        return 'Cured (${role.name}) / رفع اثر (${role.nameFa})';
      case _Effect.silenced:
        return 'Silenced (${role.name}) / سکوت (${role.nameFa})';
      case _Effect.blocked:
        return 'Blocked (${role.name}) / بسته (${role.nameFa})';
      case _Effect.info:
        return '${role.name} / ${role.nameFa}';
    }
  }

  void _toggleArm(Role role) {
    setState(() {
      if (_armedType == role.type) {
        _armedType = null;
        _armedRole = null;
      } else {
        _armedType = role.type;
        _armedRole = role;
      }
    });
  }

  void _applyToPlayer(int playerNumber) {
    final armed = _armedRole;
    if (armed == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Tap a role icon above first / اول یه آیکون نقش رو انتخاب کنید'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final effect = _effectFor(armed.type);
    final currentLabel = widget.gameState.nightMarkLabel(playerNumber) ?? '';

    if (effect == _Effect.saved && currentLabel.startsWith('Shot')) {
      widget.gameState.setNightMark(
        playerNumber,
        Colors.greenAccent,
        'Saved - was shot / سیو شد (شات خورده بود)',
      );
    } else if (effect == _Effect.cured && currentLabel.startsWith('Silenced')) {
      widget.gameState.setNightMark(
        playerNumber,
        Colors.greenAccent,
        'Cured - was silenced / رفع سکوت شد',
      );
    } else {
      widget.gameState.setNightMark(
        playerNumber,
        _colorForEffect(effect),
        _labelForEffect(effect, armed),
      );
    }
    setState(() {}); // refresh to show the new mark
  }

  List<Role> _distinctRolesPresent() {
    final seen = <RoleType>{};
    final result = <Role>[];
    // Mafia first, then citizen, then independent - matches the wake order.
    for (final team in [Team.mafia, Team.citizen, Team.independent]) {
      for (final role in widget.gameState.allAssignedRoles) {
        if (role.team == team && seen.add(role.type)) {
          result.add(role);
        }
      }
    }
    return result;
  }

  @override
  Widget build(BuildContext context) {
    final total = widget.gameState.playerCount ?? 0;
    final roles = _distinctRolesPresent();

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Night Actions / اعمال شب')),
        body: SafeArea(
          child: Column(
            children: [
              SizedBox(
                height: 76,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  children: roles.map((role) {
                    final armed = _armedType == role.type;
                    return GestureDetector(
                      onTap: () => _toggleArm(role),
                      child: Container(
                        width: 56,
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        decoration: BoxDecoration(
                          color: armed
                              ? role.color.withOpacity(0.35)
                              : AppColors.surfaceVariant,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: armed ? role.color : Colors.white12,
                            width: armed ? 2.5 : 1,
                          ),
                          boxShadow: armed
                              ? [
                                  BoxShadow(
                                    color: role.color.withOpacity(0.6),
                                    blurRadius: 10,
                                    spreadRadius: 1,
                                  ),
                                ]
                              : null,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10),
                          child: SvgPicture.asset(
                            role.iconAsset,
                            colorFilter: ColorFilter.mode(role.color, BlendMode.srcIn),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
              if (_armedRole != null)
                Container(
                  width: double.infinity,
                  color: _armedRole!.color.withOpacity(0.15),
                  padding: const EdgeInsets.symmetric(vertical: 6),
                  child: Text(
                    'Armed: ${_armedRole!.name} / ${_armedRole!.nameFa} - tap a player',
                    textAlign: TextAlign.center,
                    style: TextStyle(color: _armedRole!.color, fontSize: 12),
                  ),
                ),
              const Divider(height: 1),
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: total,
                  itemBuilder: (context, index) {
                    final playerNumber = index + 1;
                    if (widget.gameState.isRemoved(playerNumber)) {
                      return const SizedBox.shrink();
                    }
                    final markColor = widget.gameState.nightMarkColor(playerNumber);
                    final markLabel = widget.gameState.nightMarkLabel(playerNumber);
                    return ListTile(
                      onTap: () => _applyToPlayer(playerNumber),
                      title: Text(
                        'Player $playerNumber',
                        style: TextStyle(
                          color: markColor ?? AppColors.textPrimary,
                          fontWeight: markColor != null ? FontWeight.bold : null,
                        ),
                      ),
                      subtitle: markLabel != null
                          ? Text(markLabel, style: TextStyle(color: markColor, fontSize: 11))
                          : null,
                      trailing: markColor != null
                          ? IconButton(
                              icon: const Icon(Icons.close, size: 18),
                              tooltip: 'Clear mark / پاک کردن',
                              onPressed: () => setState(
                                () => widget.gameState.clearNightMark(playerNumber),
                              ),
                            )
                          : null,
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  children: [
                    const Text(
                      'General tool, not exact for every role - use your judgment.\n'
                      'ابزار کلی است، برای هر نقش دقیق نیست - با نظر خودتان اعمال کنید.',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textSecondary, fontSize: 10),
                    ),
                    const SizedBox(height: 8),
                    OutlinedButton(
                      onPressed: () => setState(widget.gameState.clearAllNightMarks),
                      child: const Text('Clear All Marks / پاک کردن همه'),
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
