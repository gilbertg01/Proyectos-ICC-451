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
    if (evolutions.isEmpty) {
      return const Center(
        child: Text(
          "No hay evoluciones",
          style: TextStyle(
            fontFamily: "PokemonBold",
            color: Colors.white,
            fontSize: 15,
          ),
        ),
      );
    }

    PokemonEvolution? currentPokemon;
    for (var evo in evolutions) {
      if (evo.id == currentPokemonId) {
        currentPokemon = evo;
        break;
      }
    }

    currentPokemon ??= evolutions.first;
    List<Widget> evolutionWidgets = [];
    _buildEvolutionWidgets(currentPokemon, evolutionWidgets);

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(vertical: 20),
        child: Center(
          child: Column(
            children: evolutionWidgets,
          ),
        ),
      ),
    );
  }

  void _buildEvolutionWidgets(
      PokemonEvolution species, List<Widget> widgets) {
    widgets.add(
      Column(
        children: [
          CachedNetworkImage(
            imageUrl: species.url,
            height: 100,
            width: 100,
            placeholder: (context, url) =>
            const CircularProgressIndicator(),
            errorWidget: (context, url, error) => const Icon(
              Icons.error,
              color: Colors.red,
            ),
          ),
          const SizedBox(height: 5),
          Text(
            '${species.name} #${species.id}',
            style: const TextStyle(
              fontFamily: "PokemonBold",
              color: Colors.white,
              fontSize: 20,
            ),
          ),
        ],
      ),
    );

    if (species.evolvesTo.isNotEmpty) {
      for (var evolvesTo in species.evolvesTo) {
        widgets.add(const Icon(
          Icons.arrow_downward,
          color: Colors.white,
          size: 30,
        ));
        _buildEvolutionWidgets(evolvesTo, widgets);
      }
    }
  }
}
