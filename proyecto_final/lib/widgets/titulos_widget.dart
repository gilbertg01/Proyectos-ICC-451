import 'package:flutter/material.dart';

class TituloWidget extends StatelessWidget {
  final String titulo;
  final String subtitulo;
  final Color tituloColor;

  const TituloWidget({super.key, required this.titulo, required this.subtitulo, required this.tituloColor});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Card(
          color: Colors.white.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '$titulo:',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: tituloColor,
                    fontSize: 20,
                    fontFamily: 'PokemonBold',
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  subtitulo,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontFamily: 'PokemonSolid',
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 10),
        const Divider(height: 20, color: Colors.white24),
      ],
    );
  }
}
