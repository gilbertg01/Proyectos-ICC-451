import 'package:flutter/material.dart';
import 'package:proyecto_final_flutter/widgets/row_widget.dart';
import '../entidades/pokemon_stats.dart';

class StatsWidget extends StatelessWidget {
  final PokemonStats statsData;
  final Color backgroundColor;

  const StatsWidget({
    super.key,
    required this.statsData,
    required this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final List<Map<String, dynamic>> stats = [
      {'title': 'HP', 'value': statsData.hp ?? 0},
      {'title': 'Attack', 'value': statsData.attack ?? 0},
      {'title': 'Defense', 'value': statsData.defense ?? 0},
      {'title': 'Sp. Attack', 'value': statsData.specialAttack ?? 0},
      {'title': 'Sp. Defense', 'value': statsData.specialDefence ?? 0},
      {'title': 'Speed', 'value': statsData.speed ?? 0},
    ];

    return Container(
      color: backgroundColor,
      child: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: stats.map((stat) {
            return RowWidget(
              statTitle: stat['title'] as String,
              statValue: stat['value'] as int,
            );
          }).toList(),
        ),
      ),
    );
  }
}
