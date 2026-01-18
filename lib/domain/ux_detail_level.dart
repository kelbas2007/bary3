/// Уровень подробности объяснений в UI.
///
/// - simple: коротко, по делу (для младших/не любящих много текста)
/// - pro: подробнее, с объяснениями \"почему\" (для старших/интересующихся)
enum UxDetailLevel {
  simple,
  pro,
}

extension UxDetailLevelX on UxDetailLevel {
  String get storageValue => name;

  static UxDetailLevel fromStorage(String? v) {
    return UxDetailLevel.values.firstWhere(
      (e) => e.name == v,
      orElse: () => UxDetailLevel.simple,
    );
  }
}

