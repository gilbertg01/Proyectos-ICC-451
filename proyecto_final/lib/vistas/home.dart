import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../entidades/pokemon_data.dart';
import '../servicios/graphql_calls.dart';
import '../widgets/pokemon_card.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final RefreshController refreshController = RefreshController(initialRefresh: true);
  final GraphQLCalls graphQLCalls = GraphQLCalls();
  final ScrollController scrollController = ScrollController();
  List<PokemonData> pokemonsResult = [];
  String? selectedFilter = "all";
  String? selectedGenerationKey = "None";

  List<String> pokemonTypes = [
    "all", "normal", "fighting", "flying", "poison", "ground", "rock",
    "bug", "ghost", "steel", "fire", "water", "grass", "electric",
    "psychic", "ice", "dragon", "dark", "fairy"
  ];

  final Map<String, String> generations = {
    "None": "",
    "Gen-I": "generation-i",
    "Gen-II": "generation-ii",
    "Gen-III": "generation-iii",
    "Gen-IV": "generation-iv",
    "Gen-V": "generation-v",
    "Gen-VI": "generation-vi",
    "Gen-VII": "generation-vii",
    "Gen-VIII": "generation-viii",
    "Gen-IX": "generation-ix",
  };

  Future<bool> getPokemonData({bool isRefresh = false, String filter = "all", String generation = ""}) async {
    if (isRefresh) {
      pokemonsResult.clear();
    }

    try {
      final List<PokemonData> fetchedPokemons = await graphQLCalls.getPokemonList(
        limit: 20,
        offset: pokemonsResult.length,
        filter: filter,
        generation: generation,
      );

      setState(() {
        pokemonsResult.addAll(fetchedPokemons);
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  void _scrollToTop() {
    scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 500),
      curve: Curves.fastOutSlowIn,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedFilter,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.black,
                onChanged: (newValue) {
                  setState(() {
                    selectedFilter = newValue;
                    refreshController.requestRefresh(needMove: false);
                  });
                },
                items: pokemonTypes.map((valueItem) {
                  return DropdownMenuItem(
                    value: valueItem,
                    child: Text(
                      valueItem.toUpperCase(),
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontFamily: "PokemonBold",
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
            const Spacer(),
            const Text(
              "   Pokédex      ",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontFamily: 'PokemonNormal',
                fontSize: 24,
              ),
            ),
            const Spacer(),
            DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedGenerationKey,
                icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                dropdownColor: Colors.black,
                onChanged: (newValue) {
                  setState(() {
                    selectedGenerationKey = newValue;
                    refreshController.requestRefresh(needMove: false);
                  });
                },
                items: generations.keys.map((key) {
                  return DropdownMenuItem(
                    value: key,
                    child: Text(
                      key,
                      style: const TextStyle(
                        color: Colors.yellowAccent,
                        fontFamily: "PokemonBold",
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
        centerTitle: true,
      ),
      backgroundColor: Colors.black,
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getPokemonData(
            isRefresh: true,
            filter: selectedFilter!,
            generation: generations[selectedGenerationKey]!,
          );
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getPokemonData(
            filter: selectedFilter!,
            generation: generations[selectedGenerationKey]!,
          );
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        },
        child: GridView.builder(
          controller: scrollController,
          itemCount: pokemonsResult.length,
          itemBuilder: (context, index) {
            return PokemonCard(
              pokemonResult: pokemonsResult[index],
              index: index,
              pokemonList: pokemonsResult,
            );
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 9 / 14,
          ),
        ),
      ),
      floatingActionButton: SpeedDial(
        animatedIcon: AnimatedIcons.menu_close,
        backgroundColor: Colors.yellowAccent,
        overlayColor: Colors.black,
        overlayOpacity: 0.7,
        children: [
          SpeedDialChild(
            child: const Icon(Icons.vertical_align_top, color: Colors.black),
            backgroundColor: Colors.yellowAccent,
            label: 'Scroll to Top',
            onTap: _scrollToTop,
          ),
          SpeedDialChild(
            child: const Icon(Icons.search, color: Colors.black),
            backgroundColor: Colors.yellowAccent,
            label: 'Search',
            onTap: () {
              //Todo buscador de pokemones
            },
          ),
        ],
      ),
    );
  }
}
