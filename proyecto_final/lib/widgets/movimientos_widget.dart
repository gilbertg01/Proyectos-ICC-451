import 'package:flutter/material.dart';

class MovementsWidget extends StatelessWidget {
  final List<String> moves;
  final Color backgroundColor;

  const MovementsWidget({
    super.key,
    required this.moves,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: moves.isEmpty
          ? const Center(
        child: Text(
          "No Moves Available",
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
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 10),
              ...moves.map((move) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 5),
                child: Text(
                  move,
                  style: const TextStyle(
                    fontSize: 20,
                    color: Colors.white,
                    fontFamily: 'PokemonBold',
                  ),
                ),
              )),
            ],
          ),
        ),
      ),
    );
  }
}
