class MoveData {
  final String name;
  final int? accuracy;
  final int? power;
  final int? pp;
  final String? type;
  final String? damageClass;
  final String? effect;

  MoveData({
    required this.name,
    this.accuracy,
    this.power,
    this.pp,
    this.type,
    this.damageClass,
    this.effect,
  });
}
