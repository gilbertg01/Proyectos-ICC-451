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
        Text(
          '$titulo:',
          style: TextStyle(fontWeight: FontWeight.bold, color: tituloColor, fontSize: 18
              , fontFamily: 'PokemonBold'),
        ),
        const SizedBox(height: 8),
        Text(
          subtitulo,
          style: const TextStyle(color: Colors.white70, fontSize: 18, fontFamily: 'PokemonNormal'),
        ),
        const Divider(height: 20, color: Colors.white24),
      ],
    );
  }
}
