import 'package:flutter/material.dart';
import 'role_type.dart';
import 'team.dart';

/// Immutable description of a role: how it looks and reads in the UI.
///
/// Built-in roles are constructed once in `role_data.dart`. Custom
/// (game-master-authored) roles are constructed on the fly at setup time
/// with `type: RoleType.custom`.
@immutable
class Role {
  final RoleType type;
  final Team team;
  final String name;
  final String description;
  final String nameFa;
  final String descriptionFa;
  final String iconAsset;
  final Color color;

  /// A one-sentence version of [description]/[descriptionFa], used on the
  /// fixed-size in-game reveal card so every card is the same size. The
  /// full, detailed version stays in the rulebook. Falls back to the full
  /// description if no short one was given (e.g. for custom roles).
  final String? shortDescription;
  final String? shortDescriptionFa;

  /// A stable identifier used to track selection/storage. Built-in roles
  /// use their [RoleType]'s name (unique already); custom roles get their
  /// own generated id, since many custom roles all share
  /// `type: RoleType.custom`.
  final String? customId;
  String get id => customId ?? type.name;

  String get displayShortDescription => shortDescription ?? description;
  String get displayShortDescriptionFa => shortDescriptionFa ?? descriptionFa;

  const Role({
    required this.type,
    required this.team,
    required this.name,
    required this.description,
    required this.nameFa,
    required this.descriptionFa,
    required this.iconAsset,
    required this.color,
    this.shortDescription,
    this.shortDescriptionFa,
    this.customId,
  });

  /// Serializes a *custom* role for local storage. Built-in roles are
  /// never saved this way - they already live in `role_data.dart`.
  Map<String, dynamic> toJson() => {
        'customId': customId,
        'team': team.name,
        'name': name,
        'description': description,
        'nameFa': nameFa,
        'descriptionFa': descriptionFa,
        'color': color.value,
      };

  factory Role.fromJson(Map<String, dynamic> json) {
    return Role(
      type: RoleType.custom,
      customId: json['customId'] as String,
      team: Team.values.byName(json['team'] as String),
      name: json['name'] as String,
      description: json['description'] as String,
      nameFa: json['nameFa'] as String,
      descriptionFa: json['descriptionFa'] as String,
      iconAsset: 'assets/icons/custom.svg',
      color: Color(json['color'] as int),
    );
  }
}
