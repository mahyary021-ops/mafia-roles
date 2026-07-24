import 'package:flutter/material.dart';

import '../constants/app_colors.dart';
import '../constants/app_text_styles.dart';
import '../constants/role_data.dart';
import '../models/role.dart';
import '../models/team.dart';
import '../widgets/app_background.dart';
import '../widgets/neon_dot_frame.dart';

/// Full bilingual rulebook: every built-in role's name and ability in both
/// English and Persian, the general mafia "no-shot" rule, and a credit
/// block for the academy and developer.
class RulebookScreen extends StatelessWidget {
  const RulebookScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final mafiaRoles = RoleData.forTeam(Team.mafia);
    final citizenRoles = RoleData.forTeam(Team.citizen);
    final independentRoles = RoleData.forTeam(Team.independent);

    return AppBackground(
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: AppBar(title: const Text('Rulebook / رول‌بوک')),
        body: SafeArea(
          child: ListView(
            padding: const EdgeInsets.all(20),
            children: [
              _SectionHeader(title: 'مافیا / Mafia', color: AppColors.mafiaTeam),
              for (final role in mafiaRoles) _RoleRuleTile(role: role),
              const SizedBox(height: 20),
              _SectionHeader(
                  title: 'شهروند / Citizen', color: AppColors.citizenTeam),
              for (final role in citizenRoles) _RoleRuleTile(role: role),
              if (independentRoles.isNotEmpty) ...[
                const SizedBox(height: 20),
                _SectionHeader(
                  title: 'مستقل / Independent',
                  color: AppColors.independentTeam,
                ),
                for (final role in independentRoles) _RoleRuleTile(role: role),
              ],
              const SizedBox(height: 24),
              _RuleBlock(
                titleEn: 'General Rule — "No-Shot" / Slaughter',
                titleFa: 'قانون کلی — «ناتویی» / سلاخی',
                bodyEn:
                    "Once per game, the mafia's shooter may guess a "
                    'target\'s role and, instead of a normal shot, declare '
                    '"ناتویی" (unable to identify the role) - this even '
                    "works against Nostradamus. The target is eliminated "
                    'outright ("slaughtered"), ignoring their role, the '
                    "Doctor's save, and any shield entirely.",
                bodyFa:
                    'مافیای شات‌زننده در کل بازی یک‌بار می‌تواند با حدس نقش '
                    'یک بازیکن، به‌جای شات معمولی، «ناتویی» (ناتوانی در '
                    'تشخیص نقش) اعلام کند - این حتی روی نوستراداموس هم اثر '
                    'می‌کند. فرد بدون در نظر گرفتن نقش، سیو دکتر، یا هر '
                    'شیلدی، به‌صورت اصطلاحاً «سلاخی» از بازی خارج می‌شود.',
              ),
              const SizedBox(height: 12),
              _RuleBlock(
                titleEn: 'Day One — Blind Round',
                titleFa: 'روز اول — دور بلایند',
                bodyEn:
                    'In games of 12 players or fewer, day one is a "blind" '
                    "introduction round: players don't yet recognize each "
                    "other's behavior. The Cowboy and Terrorist have no "
                    'action on day one.',
                bodyFa:
                    'در تعداد 12 نفر و پایین‌تر، روز اول یک دور «بلایند» و '
                    'معارفه است؛ بازیکن‌ها هنوز همدیگر را نمی‌شناسند. کابوی و '
                    'تروریست در روز اول اکت (اقدام) ندارند.',
              ),
              const SizedBox(height: 12),
              _RuleBlock(
                titleEn: 'Wake Order at Night',
                titleFa: 'ترتیب بیدار کردن نقش‌ها در شب',
                bodyEn:
                    'If present in the game, roles wake in this order:\n\n'
                    '1. Bartender - alone, before anyone else, since his '
                    'ability can block any player, even a mafia member.\n'
                    '2. Thief - alone.\n'
                    '3. The rest of the mafia group (everyone except the '
                    'Thief) - they see the Thief\'s "like", but the Thief '
                    'does not wake with them.\n'
                    '4. Citizen-team named roles.',
                bodyFa:
                    'اگر در بازی حضور داشته باشند، نقش‌ها به این ترتیب بیدار '
                    'می‌شوند:\n\n'
                    '1. ساقی - تنها، زودتر از همه، چون توانایی‌اش می‌تواند '
                    'روی هر بازیکنی، حتی یک مافیا، اعمال شود.\n'
                    '2. دزد - به‌تنهایی.\n'
                    '3. باقی گروه مافیا (به‌جز دزد) - آن‌ها لایک دزد را '
                    'می‌بینند، اما دزد با آن‌ها بیدار نمی‌شود.\n'
                    '4. شهروندان نقش‌دار.',
              ),
              const SizedBox(height: 12),
              _RuleBlock(
                titleEn: 'Advanced Mafia (15+ players)',
                titleFa: 'مافیای پیشرفته (15 نفر به بالا)',
                bodyEn:
                    'Games with 15 or more players follow the "Advanced '
                    'Mafia" ruleset - richer role combinations and more '
                    'night-action interactions. Typical additions: '
                    'Invincible, Strongman, Psycho, Commander, and the '
                    "Sniper's larger bullet count (see their own entries "
                    'above for details).',
                bodyFa:
                    'قوانین بازی‌های 15 نفر به بالا بر اساس «مافیای پیشرفته» '
                    'است - ترکیب نقش‌های بیشتر و تعامل پیچیده‌تر بین '
                    'توانایی‌ها. نقش‌های رایج اضافه‌شده: رویین‌تن، مرد قوی، '
                    'روانی، فرمانده، و افزایش تعداد گلوله‌های اسنایپر (برای '
                    'جزئیات، توضیح خود آن نقش‌ها را در بالا ببینید).',
              ),
              const SizedBox(height: 32),
              const _CreditBlock(),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}

class _RuleBlock extends StatelessWidget {
  final String titleEn;
  final String titleFa;
  final String bodyEn;
  final String bodyFa;

  const _RuleBlock({
    required this.titleEn,
    required this.titleFa,
    required this.bodyEn,
    required this.bodyFa,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.surfaceVariant,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: AppColors.textGold.withOpacity(0.4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(titleEn, style: AppTextStyles.englishFlashy),
          Text(titleFa, style: AppTextStyles.persianGold),
          const SizedBox(height: 8),
          Text(bodyEn, style: const TextStyle(color: AppColors.textSecondary)),
          const SizedBox(height: 6),
          Text(
            bodyFa,
            style: const TextStyle(color: AppColors.textGold, height: 1.7),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({required this.title, required this.color});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoleRuleTile extends StatelessWidget {
  final Role role;

  const _RoleRuleTile({required this.role});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(role.name, style: AppTextStyles.englishFlashy.copyWith(fontSize: 15)),
          Text(role.nameFa, style: AppTextStyles.persianGold.copyWith(fontSize: 14)),
          const SizedBox(height: 4),
          Text(
            role.description,
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          ),
          const SizedBox(height: 2),
          Text(
            role.descriptionFa,
            style: const TextStyle(
              color: AppColors.textGold,
              fontSize: 12,
              height: 1.6,
            ),
          ),
          const Divider(height: 16),
        ],
      ),
    );
  }
}

class _CreditBlock extends StatelessWidget {
  const _CreditBlock();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        children: [
          const TwinklingStarRow(),
          const SizedBox(height: 10),
          const Text('Mafia Psychology Academy', style: AppTextStyles.englishFlashy),
          const Text('آکادمی روان‌شناسی مافیا', style: AppTextStyles.persianGold),
          const SizedBox(height: 10),
          const Text('Developer: Mahyar Yaghoobalipour', style: AppTextStyles.englishFlashy),
          const Text(
            'توسعه‌دهنده و بنیان‌گذار آکادمی روان‌شناسی مافیا: مهیار یعقوبعلی‌پور',
            style: AppTextStyles.persianGold,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 6),
          const Text(
            'mahyary021@gmail.com',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 12),
          ),
          const SizedBox(height: 10),
          const TwinklingStarRow(),
        ],
      ),
    );
  }
}
