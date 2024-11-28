import 'package:proyecto_final_flutter/entidades/pokemon_evolution.dart';
import 'package:proyecto_final_flutter/entidades/pokemon_info.dart';
import 'package:proyecto_final_flutter/entidades/pokemon_more_info.dart';
import 'package:proyecto_final_flutter/entidades/pokemon_stats.dart';
import 'move_data.dart';

class PokemonData {
  final String id;
  final String name;
  final String imageUrl;
  final List<String> types;
  final PokemonInfo? info;
  final PokemonMoreInfo? moreInfo;
  final PokemonStats? stats;
  final List<PokemonEvolution>? evolution;
  final List<MoveData>? moves;

  PokemonData({
    required this.id,
    required this.name,
    required this.imageUrl,
    this.types = const [],
    this.info,
    this.moreInfo,
    this.stats,
    this.evolution,
    this.moves,
  });
}


