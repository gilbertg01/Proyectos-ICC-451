import 'package:flutter/material.dart';
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
  List<String> pokemonTypes = [
    "all", "normal", "fighting", "flying", "poison", "ground", "rock",
    "bug", "ghost", "steel", "fire", "water", "grass", "electric",
    "psychic", "ice", "dragon", "dark", "fairy"
  ];

  Future<bool> getPokemonData({bool isRefresh = false, String filter = "all"}) async {
    if (isRefresh) {
      pokemonsResult.clear();
    }

    try {
      final List<PokemonData> fetchedPokemons = await graphQLCalls.getPokemonList(
          limit: 20, offset: pokemonsResult.length, filter: filter);

      setState(() {
        pokemonsResult.addAll(fetchedPokemons);
      });
      return true;
    } catch (error) {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: Row(
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
              "Pokédex    ",
              style: TextStyle(
                color: Colors.yellowAccent,
                fontFamily: 'PokemonNormal',
              ),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.vertical_align_top),
            color: Colors.white,
            onPressed: () {
              scrollController.animateTo(
                0,
                duration: const Duration(milliseconds: 500),
                curve: Curves.fastOutSlowIn,
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.search),
            color: Colors.white,
            onPressed: () {
              //Todo buscador de pokemones
            },
          ),
        ],
      ),
      backgroundColor: Colors.black,
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getPokemonData(isRefresh: true, filter: selectedFilter!);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getPokemonData(filter: selectedFilter!);
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
            return PokemonCard(pokemonResult: pokemonsResult[index]);
          },
          gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio: 9 / 14,
          ),
        ),
      ),
    );
  }
}
