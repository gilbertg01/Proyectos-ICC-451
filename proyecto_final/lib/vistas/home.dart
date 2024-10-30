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
  List<PokemonData> pokemonsResult = [];

  Future<bool> getPokemonData({bool isRefresh = false}) async {
    if (isRefresh) {
      pokemonsResult.clear();
    }

    try {
      final List<PokemonData> fetchedPokemons = await graphQLCalls.getPokemonList(limit: 20, offset: pokemonsResult.length);
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
        title: const Text("Pokédex"),
        centerTitle: true,
      ),
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: true,
        onRefresh: () async {
          final result = await getPokemonData(isRefresh: true);
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: () async {
          final result = await getPokemonData();
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        },
        child: GridView.builder(
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
