import 'package:flutter/material.dart';
import '../entidades/pokemon_more_info.dart';
import 'titulos_widget.dart';

class MoreInfoWidget extends StatelessWidget {
  final PokemonMoreInfo moreInfo;
  final Color backgroundColor;

  const MoreInfoWidget({
    super.key,
    required this.moreInfo,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        scrollDirection: Axis.vertical,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              TituloWidget(
                titulo: 'Height',
                subtitulo: "${(moreInfo.height ?? 0) / 10} m",
                tituloColor: Colors.white,
              ),
              TituloWidget(
                titulo: 'Weight',
                subtitulo: "${(moreInfo.weight ?? 0) / 10} kg",
                tituloColor: Colors.white,
              ),
              TituloWidget(
                titulo: 'Types',
                subtitulo: moreInfo.types?.join(', ') ?? 'Unknown',
                tituloColor: Colors.white,
              ),
              TituloWidget(
                titulo: 'Abilities',
                subtitulo: moreInfo.abilities?.join(', ') ?? 'Unknown',
                tituloColor: Colors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
