class PokemonData {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> types;

  PokemonData({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
  });
}

