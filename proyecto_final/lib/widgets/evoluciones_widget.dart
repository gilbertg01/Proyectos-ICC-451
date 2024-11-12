import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../entidades/pokemon_evolution.dart';

class EvolutionsWidget extends StatelessWidget {
  final List<PokemonEvolution> evolutions;
  final Color backgroundColor;
  final String currentPokemonId;

  const EvolutionsWidget({
    super.key,
    required this.evolutions,
    required this.backgroundColor,
    required this.currentPokemonId,
  });

  @override
  Widget build(BuildContext context) {
    final filteredEvolutions = evolutions
        .where((evolution) => evolution.id != currentPokemonId)
        .toList();

    if (filteredEvolutions.isEmpty) {
      return const Center(
        child: Text(
          "No Evolutions",
          style: TextStyle(
            fontFamily: "PokemonBold",
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );
    }

    return Container(
      color: backgroundColor,
      child: ListView.builder(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.only(bottom: 100),
        itemCount: filteredEvolutions.length,
        itemBuilder: (context, index) {
          final evolution = filteredEvolutions[index];
          final imageUrl = evolution.url ?? '';
          return InkWell(
            child: Column(
              children: [
                Row(
                  children: [
                    Text(
                      "  ${evolution.name} #${evolution.id} ",
                      style: const TextStyle(
                        fontFamily: "PokemonBold",
                        color: Colors.white,
                        fontSize: 20,
                      ),
                    ),
                    const Spacer(),
                    CachedNetworkImage(
                      imageUrl: imageUrl,
                      height: 75,
                      width: 75,
                      placeholder: (context, url) =>
                      const CircularProgressIndicator(),
                      errorWidget: (context, url, error) => const Icon(
                        Icons.error,
                        color: Colors.red,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.white, height: 20),
              ],
            ),
          );
        },
      ),
    );
  }
}
