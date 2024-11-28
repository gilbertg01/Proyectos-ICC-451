class PokemonEvolution {
  final String id;
  final String name;
  final String url;
  final String? evolvesFromId;
  final List<PokemonEvolution> evolvesTo;

  PokemonEvolution({
    required this.id,
    required this.name,
    required this.url,
    this.evolvesFromId,
    this.evolvesTo = const [],
  });
}
