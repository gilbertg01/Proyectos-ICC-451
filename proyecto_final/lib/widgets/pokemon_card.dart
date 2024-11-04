import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../entidades/pokemon_data.dart';

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

class PokemonCard extends StatelessWidget {
  final PokemonData pokemonResult;

  const PokemonCard({super.key, required this.pokemonResult});

  @override
  Widget build(BuildContext context) {
    final String id = pokemonResult.id;
    String imageUrl = pokemonResult.imageUrl;
    Color cardColor = Colors.grey;

    if (pokemonResult.types.isNotEmpty && typeColors.containsKey(pokemonResult.types[0])) {
      cardColor = typeColors[pokemonResult.types[0]]!;
    }

    return InkWell(
      onTap: () {
        //todo perfil de pokemones
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        color: cardColor.withOpacity(0.9),
        elevation: 4.0,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(16.0),
                topRight: Radius.circular(16.0),
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Opacity(
                    opacity: 0.8,
                    child: SvgPicture.asset(
                      "lib/images/pokeball.svg",
                      width: MediaQuery.of(context).size.width / 3.5,
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(
                    width: MediaQuery.of(context).size.width / 3,
                    child: Hero(
                      tag: id,
                      child: CachedNetworkImage(
                        imageUrl: imageUrl.isNotEmpty ? imageUrl : 'https://via.placeholder.com/150',
                        fit: BoxFit.cover,
                        placeholder: (context, url) => Center(
                          child: CircularProgressIndicator(
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.blueAccent,
                            ),
                          ),
                        ),
                        errorWidget: (context, url, error) {
                          return Column(
                            children: [
                              Icon(Icons.error, color: Colors.red, size: 40),
                              const SizedBox(height: 4),
                              const Text(
                                'Imagen no disponible',
                                style: TextStyle(color: Colors.grey),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8.0),
            Text(
              pokemonResult.name,
              style: Theme.of(context).textTheme.titleMedium!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            Text(
              "#${id.padLeft(5, '0')}",
              style: Theme.of(context).textTheme.titleSmall!.copyWith(
                fontWeight: FontWeight.w700,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 8.0),
          ],
        ),
      ),
    );
  }
}
