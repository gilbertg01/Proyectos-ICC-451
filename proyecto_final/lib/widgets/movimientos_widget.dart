import 'package:flutter/material.dart';
import '../entidades/move_data.dart';

class MovementsWidget extends StatelessWidget {
  final List<MoveData> moves;
  final Color backgroundColor;

  const MovementsWidget({
    Key? key,
    required this.moves,
    required this.backgroundColor,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: moves.isEmpty
          ? const Center(
        child: Text(
          "No hay movimientos disponibles",
          style: TextStyle(
            fontFamily: 'PokemonBold',
            fontSize: 20,
            color: Colors.white,
          ),
        ),
      )
          : SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        child: Padding(
          padding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: moves.map((move) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Card(
                  color: Colors.white.withOpacity(0.2),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          move.name,
                          style: const TextStyle(
                            fontSize: 24,
                            color: Colors.white,
                            fontFamily: 'PokemonBold',
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Power: ${move.power ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'PokemonSolid',
                          ),
                        ),
                        Text(
                          'Accuracy: ${move.accuracy ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'PokemonSolid',
                          ),
                        ),
                        Text(
                          'Type: ${move.type ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'PokemonSolid',
                          ),
                        ),
                        Text(
                          'PP: ${move.pp ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 16,
                            color: Colors.white,
                            fontFamily: 'PokemonSolid',
                          ),
                        ),
                        if (move.effect != null)
                          Text(
                            'Effect: ${move.effect}',
                            style: const TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                              fontFamily: 'PokemonSolid',
                            ),
                          ),
                      ],
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
}
