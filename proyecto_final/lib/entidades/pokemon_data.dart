import 'package:proyecto_final_flutter/entidades/pokemon_info.dart';

class PokemonData {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final PokemonInfo? info;

  PokemonData({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.info
  });
}

