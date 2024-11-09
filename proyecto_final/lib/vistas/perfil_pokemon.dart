import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../entidades/pokemon_data.dart';
import '../widgets/menu_widget.dart';

class PerfilPokemon extends StatefulWidget {
  final PokemonData pokemon;

  const PerfilPokemon({super.key, required this.pokemon});

  @override
  State<PerfilPokemon> createState() => _PerfilPokemonState();
}

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

class _PerfilPokemonState extends State<PerfilPokemon> {
  Color cardColor = Colors.transparent;

  @override
  void initState() {
    super.initState();
    _setCardColor();
  }

  void _setCardColor() {
    if (widget.pokemon.types.isNotEmpty) {
      final primaryType = widget.pokemon.types.first.toLowerCase();
      if (typeColors.containsKey(primaryType)) {
        cardColor = typeColors[primaryType]!;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          "${widget.pokemon.name} #${widget.pokemon.id}",
          style: const TextStyle(color: Colors.yellowAccent, fontFamily: 'PokemonBold'),
        ),
        centerTitle: true,
      ),
      body: ListView(
        padding: EdgeInsets.zero,
        children: <Widget>[
          Container(
            width: MediaQuery.of(context).size.width,
            color: cardColor,
            child: Column(
              children: [
                Hero(
                  tag: widget.pokemon.id,
                  child: CachedNetworkImage(
                    imageUrl: widget.pokemon.imageUrl,
                    height: 200,
                    width: 200,
                    fit: BoxFit.contain,
                    placeholder: (context, url) => const CircularProgressIndicator(),
                    errorWidget: (context, url, error) => const Icon(Icons.error),
                  ),
                ),
              ],
            ),
          ),
          MenuWidget(
            pokemon: widget.pokemon,
            menuColor: cardColor,
          ),
        ],
      ),
      backgroundColor: Colors.grey[900],
    );
  }
}
