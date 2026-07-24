/// Every built-in role that can exist in the game.
///
/// [custom] is special: it marks a role written by the game master at
/// setup time. Its actual name/description/team live in the [Role] object
/// itself (constructed on the fly), not in `role_data.dart`.
///
/// To add a new *built-in* role: add it here, then add its entry in
/// `role_data.dart`.
enum RoleType {
  // Citizen team
  citizen,
  doctor,
  sniper,
  bartender,
  priest,
  detective,
  investigator,
  cowboy,
  bomber,
  gunman,
  invincible,
  commander,
  guard,
  freemason,
  tyler,
  spy,
  snowman,
  // Mafia team
  mafia,
  godfather,
  terrorist,
  thief,
  natasha,
  joker,
  enchanter,
  yakuza,
  strongman,
  psycho,
  // Independent
  nostradamus,
  // Game-master-authored role
  custom,
}
