import 'package:shared_preferences/shared_preferences.dart';

class PokemonFavoritesController {
  static final PokemonFavoritesController _instance = PokemonFavoritesController._internal();
  factory PokemonFavoritesController() {
    return _instance;
  }
  PokemonFavoritesController._internal();

  late SharedPreferences prefs;
  List<String> _favoritePokemonIds = [];

  List<String> get favoritePokemonIds => _favoritePokemonIds;

  Future<void> init() async {
    prefs = await SharedPreferences.getInstance();
    await loadFavoritePokemonsFromSharedPref();
  }

  Future<void> toggleFavoritePokemon(String pokemonId) async {
    prefs = await SharedPreferences.getInstance();
    List<String> savedPokemons = prefs.getStringList('favoritePokemons') ?? [];
    if (savedPokemons.contains(pokemonId)) {
      savedPokemons.remove(pokemonId);
    } else {
      savedPokemons.add(pokemonId);
    }
    await prefs.setStringList('favoritePokemons', savedPokemons);
    _favoritePokemonIds = savedPokemons;
  }

  Future<void> loadFavoritePokemonsFromSharedPref() async {
    prefs = await SharedPreferences.getInstance();
    _favoritePokemonIds = prefs.getStringList('favoritePokemons') ?? [];
  }

  Future<bool> isPokemonFavorite(String pokemonId) async {
    prefs = await SharedPreferences.getInstance();
    List<String> savedPokemons = prefs.getStringList('favoritePokemons') ?? [];
    return savedPokemons.contains(pokemonId);
  }

  List<String> getFavoritePokemonsIds() {
    return _favoritePokemonIds;
  }
}
