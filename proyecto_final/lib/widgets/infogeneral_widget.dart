import 'package:flutter/material.dart';
import '../entidades/pokemon_info.dart';
import 'titulos_widget.dart';

class InfoGeneral extends StatelessWidget {
  final PokemonInfo aboutData;
  final Color backgroundColor;
  const InfoGeneral({super.key, required this.aboutData, required this.backgroundColor});

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
                  titulo: 'Description',
                  subtitulo: aboutData.flavorText ?? 'Unknown',
                  tituloColor: Colors.white
              ),
              TituloWidget(
                  titulo: 'Growth Rate',
                  subtitulo: aboutData.growthRate ?? 'Unknown',
                  tituloColor: Colors.white
              ),
              TituloWidget(
                  titulo: 'Habitat',
                  subtitulo: aboutData.habitat ?? 'Unknown',
                  tituloColor: Colors.white
              ),
              TituloWidget(
                  titulo: 'Capture Rate',
                  subtitulo: "${aboutData.captureRate ?? 0} %",
                  tituloColor: Colors.white
              ),
              TituloWidget(
                  titulo: 'Base Happiness',
                  subtitulo: "${aboutData.baseHappiness ?? 0} points",
                  tituloColor: Colors.white
              ),
              TituloWidget(
                  titulo: 'Egg Groups',
                  subtitulo: aboutData.eggGroups.join(', ') ?? 'Unknown',
                  tituloColor: Colors.white
              ),
            ],
          ),
        ),
      ),
    );
  }
}
