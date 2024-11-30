import '../entidades/pokemon_data.dart';
import 'graphql_calls.dart';

class PokemonRepository {
  static final PokemonRepository _instance = PokemonRepository._internal();

  factory PokemonRepository() {
    return _instance;
  }

  PokemonRepository._internal();

  final GraphQLCalls _graphqlCalls = GraphQLCalls();
  List<PokemonData> _allPokemons = [];

  Future<void> loadAllPokemons() async {
    if (_allPokemons.isNotEmpty) return;
    _allPokemons = await _graphqlCalls.getAllPokemons();
  }

  List<PokemonData> get allPokemons => _allPokemons;

  int getIndexById(String id) {
    return _allPokemons.indexWhere((pokemon) => pokemon.id == id);
  }
}
