import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_final_flutter/widgets/stats_widget.dart';
import '../entidades/pokemon_data.dart';
import 'evoluciones_widget.dart';
import 'infogeneral_widget.dart';
import 'mas_info_widget.dart';
import 'movimientos_widget.dart';

class MenuWidget extends StatefulWidget {
  final PokemonData pokemon;
  final Color menuColor;

  const MenuWidget({super.key, required this.pokemon, required this.menuColor});

  @override
  State<MenuWidget> createState() => _MenuWidgetState();
}

class _MenuWidgetState extends State<MenuWidget> {
  final PageController _tabController = PageController();
  int _currentTabIndex = 0;
  final List<String> _tabs = ['General Info', 'Statistics', 'Movements', 'More Info', 'Evolutions'];

  final List<IconData> _icons = [
    Icons.info_outline,
    Icons.bar_chart_outlined,
    Icons.fitness_center,
    Icons.info,
    Icons.timeline_outlined,
  ];

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;

    return SizedBox(
      height: screenHeight * 0.6,
      child: Stack(
        children: [
          Column(
            children: [
              Container(
                color: widget.menuColor,
                height: screenHeight * 0.06,
                alignment: Alignment.center,
                child: Text(
                  _tabs[_currentTabIndex],
                  style: const TextStyle(
                    fontSize: 25,
                    fontFamily: "PokemonNormal",
                    color: Colors.white,
                  ),
                ),
              ),
              Expanded(
                child: PageView(
                  controller: _tabController,
                  physics: const BouncingScrollPhysics(),
                  onPageChanged: (int index) {
                    setState(() {
                      _currentTabIndex = index;
                    });
                  },
                  children: [
                    InfoGeneral(
                      aboutData: widget.pokemon.info!,
                      backgroundColor: widget.menuColor,
                    ),
                    StatsWidget(
                      statsData: widget.pokemon.stats!,
                      backgroundColor: widget.menuColor,
                    ),
                    MovementsWidget(
                      moves: widget.pokemon.moves ?? [],
                      backgroundColor: widget.menuColor,
                    ),
                    MoreInfoWidget(
                      moreInfo: widget.pokemon.moreInfo!,
                      backgroundColor: widget.menuColor,
                    ),
                    EvolutionsWidget(
                      evolutions: widget.pokemon.evolution ?? [],
                      backgroundColor: widget.menuColor,
                      currentPokemonId: widget.pokemon.id,
                    ),
                  ],
                ),
              ),
            ],
          ),
          Positioned(
            bottom: 55,
            right: 16,
            child: SafeArea(
              child: SpeedDial(
                animatedIcon: AnimatedIcons.menu_close,
                backgroundColor: Colors.yellowAccent,
                overlayColor: Colors.black,
                overlayOpacity: 0.7,
                children: _tabs.asMap().entries.map((entry) {
                  int index = entry.key;
                  String tabName = entry.value;

                  return SpeedDialChild(
                    child: Icon(_icons[index], color: Colors.black),
                    backgroundColor: Colors.yellowAccent,
                    label: tabName,
                    onTap: () {
                      setState(() {
                        _currentTabIndex = index;
                        _tabController.jumpToPage(index);
                      });
                    },
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
