import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../entidades/pokemon_data.dart';
import '../widgets/menu_widget.dart';

class PerfilPokemon extends StatefulWidget {
  final List<PokemonData> pokemonList;
  final int currentIndex;

  const PerfilPokemon({super.key, required this.pokemonList, required this.currentIndex});

  @override
  State<PerfilPokemon> createState() => _PerfilPokemonState();
}

class _PerfilPokemonState extends State<PerfilPokemon> {
  late int currentIndex;
  late Color cardColor;

  final Map<String, Color> typeColors = {
    "normal": Colors.brown[400]!,
    "fighting": Colors.orange[800]!,
    "flying": Colors.blue[200]!,
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
    "dragon": Colors.indigo[800]!,
    "dark": Colors.black,
    "fairy": Colors.pinkAccent,
  };

  @override
  void initState() {
    super.initState();
    currentIndex = widget.currentIndex;
    _setCardColor();
  }

  void _setCardColor() {
    final pokemon = widget.pokemonList[currentIndex];
    if (pokemon.types.isNotEmpty) {
      final primaryType = pokemon.types.first.toLowerCase();
      cardColor = typeColors[primaryType] ?? Colors.grey;
    } else {
      cardColor = Colors.grey;
    }
  }

  void _goToNextPokemon() {
    if (currentIndex < widget.pokemonList.length - 1) {
      setState(() {
        currentIndex++;
        _setCardColor();
      });
    }
  }

  void _goToPreviousPokemon() {
    if (currentIndex > 0) {
      setState(() {
        currentIndex--;
        _setCardColor();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentPokemon = widget.pokemonList[currentIndex];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios, color: Colors.white),
        ),
        title: Text(
          "${currentPokemon.name} #${currentPokemon.id}",
          style: const TextStyle(color: Colors.yellowAccent, fontFamily: 'PokemonBold'),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          ListView(
            padding: EdgeInsets.zero,
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
                        placeholder: (context, url) => const CircularProgressIndicator(),
                        errorWidget: (context, url, error) => const Icon(Icons.error),
                      ),
                    ),
                  ],
                ),
              ),
              MenuWidget(
                pokemon: currentPokemon,
                menuColor: cardColor,
              ),
            ],
          ),
          Positioned(
            left: 16,
            top: 120,
            child: Visibility(
              visible: currentIndex > 0,
              child: FloatingActionButton(
                heroTag: "prev",
                onPressed: _goToPreviousPokemon,
                backgroundColor: Colors.yellowAccent,
                child: const Icon(Icons.arrow_back, color: Colors.black),
              ),
            ),
          ),
          Positioned(
            right: 16,
            top: 120,
            child: Visibility(
              visible: currentIndex < widget.pokemonList.length - 1,
              child: FloatingActionButton(
                heroTag: "next",
                onPressed: _goToNextPokemon,
                backgroundColor: Colors.yellowAccent,
                child: const Icon(Icons.arrow_forward, color: Colors.black),
              ),
            ),
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
