class PokemonInfo {
  final int baseHappiness;
  final int captureRate;
  final String habitat;
  final String growthRate;
  final String flavorText;
  final List<String> eggGroups;

  PokemonInfo({
    required this.baseHappiness,
    required this.captureRate,
    required this.habitat,
    required this.growthRate,
    required this.flavorText,
    required this.eggGroups
  });
}