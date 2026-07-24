import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../models/role.dart';
import '../models/role_type.dart';
import '../models/team.dart';

/// Shows a form where the game master types a name + description for a
/// one-off custom role, and picks which side it belongs to. Returns the
/// finished [Role], or null if cancelled.
///
/// Custom roles use a neutral icon (a generic mask) since there's no
/// artwork for arbitrary game-master text.
Future<Role?> showCustomRoleDialog(BuildContext context) {
  final nameController = TextEditingController();
  final descriptionController = TextEditingController();
  Team selectedTeam = Team.citizen;

  return showDialog<Role>(
    context: context,
    builder: (context) {
      return StatefulBuilder(
        builder: (context, setState) {
          return AlertDialog(
            backgroundColor: AppColors.surface,
            title: const _BilingualLabel(en: 'Custom Role', fa: 'نقش سفارشی'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextField(
                    controller: nameController,
                    decoration: const InputDecoration(
                      labelText: 'Role name / اسم نقش',
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    controller: descriptionController,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Ability / توضیح توانایی',
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _BilingualLabel(
                    en: 'Which side is this role on?',
                    fa: 'این نقش برای کدوم تیمه؟',
                    color: AppColors.textSecondary,
                    weight: FontWeight.normal,
                  ),
                  const SizedBox(height: 8),
                  SegmentedButton<Team>(
                    segments: const [
                      ButtonSegment(
                        value: Team.citizen,
                        label: Text('Citizen'),
                      ),
                      ButtonSegment(value: Team.mafia, label: Text('Mafia')),
                      ButtonSegment(
                        value: Team.independent,
                        label: Text('Independent'),
                      ),
                    ],
                    selected: {selectedTeam},
                    onSelectionChanged: (selection) {
                      setState(() => selectedTeam = selection.first);
                    },
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Cancel / انصراف'),
              ),
              ElevatedButton(
                onPressed: () {
                  final name = nameController.text.trim();
                  final description = descriptionController.text.trim();
                  if (name.isEmpty) return;

                  final color = switch (selectedTeam) {
                    Team.mafia => AppColors.mafiaTeam,
                    Team.citizen => AppColors.citizenTeam,
                    Team.independent => AppColors.independentTeam,
                  };

                  Navigator.of(context).pop(
                    Role(
                      type: RoleType.custom,
                      customId: 'custom_${DateTime.now().microsecondsSinceEpoch}',
                      team: selectedTeam,
                      name: name,
                      description: description.isEmpty ? '—' : description,
                      nameFa: name,
                      descriptionFa: description.isEmpty ? '—' : description,
                      iconAsset: 'assets/icons/custom.svg',
                      color: color,
                    ),
                  );
                },
                child: const Text('Add / افزودن'),
              ),
            ],
          );
        },
      );
    },
  );
}

/// English on top (bigger), Persian underneath (smaller) - the app-wide
/// bilingual label convention, prioritizing the English-speaking reader.
class _BilingualLabel extends StatelessWidget {
  final String en;
  final String fa;
  final Color? color;
  final FontWeight weight;

  const _BilingualLabel({
    required this.en,
    required this.fa,
    this.color,
    this.weight = FontWeight.bold,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(en, style: TextStyle(fontSize: 17, fontWeight: weight, color: color)),
        Text(
          fa,
          style: TextStyle(fontSize: 12, color: color ?? AppColors.textGold),
        ),
      ],
    );
  }
}
