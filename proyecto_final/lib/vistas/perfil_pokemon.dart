import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../entidades/pokemon_data.dart';
import '../servicios/pokemon_favorites_controller.dart';
import '../widgets/menu_widget.dart';
import '../servicios/graphql_calls.dart';

class PerfilPokemon extends StatefulWidget {
  final int currentIndex;
  final List<PokemonData> pokemonList;

  const PerfilPokemon({super.key, required this.currentIndex, required this.pokemonList});

  @override
  State<PerfilPokemon> createState() => _PerfilPokemonState();
}

class _PerfilPokemonState extends State<PerfilPokemon> {
  late int currentPokemonIndex;
  late PokemonData currentPokemon;
  late Color cardColor;
  bool isLoading = true;
  bool isFavorite = false;
  final PokemonFavoritesController favoritesController = PokemonFavoritesController();

  final Map<String, Color> typeColors = {
    "normal": Colors.brown,
    "fighting": Colors.orange,
    "flying": Colors.blue,
    "poison": Colors.purple,
    "ground": Colors.brown,
    "rock": Colors.grey,
    "bug": Colors.lightGreen,
    "ghost": Colors.indigo,
    "steel": Colors.blueGrey,
    "fire": Colors.redAccent,
    "water": Colors.blue,
    "grass": Colors.green,
    "electric": Colors.yellow,
    "psychic": Colors.pink,
    "ice": Colors.cyan,
    "dragon": Colors.indigo,
    "dark": Colors.black,
    "fairy": Colors.pinkAccent,
  };

  final GraphQLCalls _graphqlCalls = GraphQLCalls();

  @override
  void initState() {
    super.initState();
    currentPokemonIndex = widget.currentIndex;
    currentPokemon = widget.pokemonList[currentPokemonIndex];
    _setCardColor();
    favoritesController.init().then((_) {
      _checkIfFavorite();
    });
    _fetchPokemonDetails();
  }

  void _setCardColor() {
    if (currentPokemon.types.isNotEmpty) {
      final primaryType = currentPokemon.types.first.toLowerCase();
      cardColor = typeColors[primaryType] ?? Colors.grey;
    } else {
      cardColor = Colors.grey;
    }
  }

  Future<void> _fetchPokemonDetails() async {
    setState(() {
      isLoading = true;
    });

    try {
      final details = await _graphqlCalls.getPokemonDetails(currentPokemon.id);
      setState(() {
        currentPokemon = details;
        _setCardColor();
      });
      _checkIfFavorite();
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void _checkIfFavorite() async {
    bool favoriteStatus = await favoritesController.isPokemonFavorite(currentPokemon.id);
    setState(() {
      isFavorite = favoriteStatus;
    });
  }

  void _toggleFavorite() async {
    await favoritesController.toggleFavoritePokemon(currentPokemon.id);
    _checkIfFavorite();
  }

  void _goToNextPokemon() {
    if (currentPokemonIndex < widget.pokemonList.length - 1) {
      setState(() {
        currentPokemonIndex++;
        currentPokemon = widget.pokemonList[currentPokemonIndex];
        _setCardColor();
      });
      _fetchPokemonDetails();
    }
  }

  void _goToPreviousPokemon() {
    if (currentPokemonIndex > 0) {
      setState(() {
        currentPokemonIndex--;
        currentPokemon = widget.pokemonList[currentPokemonIndex];
        _setCardColor();
      });
      _fetchPokemonDetails();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "${currentPokemon.name} #${currentPokemon.id}",
          style: const TextStyle(
              color: Colors.yellowAccent, fontFamily: 'PokemonBold'),
        ),
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isFavorite ? Icons.favorite : Icons.favorite_border,
              color: Colors.red,
            ),
            onPressed: _toggleFavorite,
          ),
        ],
        centerTitle: true,
      ),
      backgroundColor: cardColor,
      body: Stack(
        children: [
          Container(
            color: cardColor,
          ),
          Column(
            children: <Widget>[
              Container(
                color: cardColor,
                width: double.infinity,
                child: Column(
                  children: [
                    Hero(
                      tag: currentPokemon.id,
                      child: CachedNetworkImage(
                        imageUrl: currentPokemon.imageUrl,
                        height: 200,
                        width: 200,
                        placeholder: (context, url) =>
                        const CircularProgressIndicator(),
                        errorWidget: (context, url, error) =>
                        const Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: isLoading
                    ? Container(
                  color: cardColor,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                )
                    : MenuWidget(
                  pokemon: currentPokemon,
                  menuColor: cardColor,
                ),
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: 120,
            child: Visibility(
              visible: currentPokemonIndex > 0,
              child: FloatingActionButton(
                heroTag: "prev_$currentPokemonIndex",
                onPressed: _goToPreviousPokemon,
                backgroundColor: Colors.yellowAccent,
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 120,
            child: FloatingActionButton(
              heroTag: "next_$currentPokemonIndex",
              onPressed: _goToNextPokemon,
              backgroundColor: Colors.yellowAccent,
              child: const Icon(Icons.arrow_forward, color: Colors.black),
            ),
          ),
          if (isLoading)
            Container(
              color: cardColor.withOpacity(0.8),
              child: const Center(child: CircularProgressIndicator()),
            ),
        ],
      ),
    );
  }
}
