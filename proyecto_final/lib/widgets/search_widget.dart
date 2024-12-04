import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../entidades/pokemon_basic_data.dart';
import '../entidades/pokemon_data.dart';
import '../servicios/pokemon_repository.dart';
import '../servicios/graphql_calls.dart';
import '../vistas/perfil_pokemon.dart';
import '../main.dart';

class SearchWidget extends StatefulWidget {
  final Function(String) onError;

  const SearchWidget({super.key, required this.onError});

  @override
  State<SearchWidget> createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final TextEditingController textEditController = TextEditingController();
  final GraphQLCalls graphQLCalls = GraphQLCalls();
  List<PokemonBasicData> searchResults = [];
  bool isLoading = false;
  String errorMessage = '';

  @override
  void dispose() {
    textEditController.dispose();
    super.dispose();
  }

  Future<void> performSearch(String query) async {
    if (query.isEmpty) {
      if (!mounted) return;
      setState(() {
        searchResults = [];
        errorMessage = '';
      });
      return;
    }

    if (!mounted) return;
    setState(() {
      isLoading = true;
      errorMessage = '';
      searchResults = [];
    });

    try {
      int? id = int.tryParse(query);
      String name = query.toLowerCase();

      PokemonData? pokemon;
      if (id != null) {
        pokemon = await graphQLCalls.getPokemonDetails(id.toString());
      } else {
        pokemon = await graphQLCalls.getPokemonDetailsByName(name);
      }

      if (pokemon != null) {
        if (!mounted) return;
        setState(() {
          searchResults = [
            PokemonBasicData(
              id: pokemon!.id,
              name: capitalize(pokemon.name),
              imageUrl: pokemon.imageUrl,
            )
          ];
        });
      } else {
        if (!mounted) return;
        setState(() {
          errorMessage = 'Pokémon no encontrado.';
        });
      }
    } catch (error) {
      widget.onError('Error al buscar Pokémon: ${error.toString()}');
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }

  String capitalize(String s) =>
      s.isNotEmpty ? '${s[0].toUpperCase()}${s.substring(1)}' : s;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          height: 64,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(235, 243, 245, 1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  style: const TextStyle(
                    color: Colors.black,
                    fontFamily: "PokemonSolid",
                      fontSize: 14
                  ),
                  controller: textEditController,
                  cursorColor: const Color.fromRGBO(90, 94, 121, 1),
                  decoration: const InputDecoration(
                    hintText: 'Type the name or ID of the Pokemon',
                    hintStyle:
                    TextStyle(color: Color.fromRGBO(149, 151, 174, 1)),
                    border: InputBorder.none,
                  ),
                  onSubmitted: performSearch,
                ),
              ),
              IconButton(
                icon: const Icon(
                  Icons.search,
                  color: Color.fromRGBO(90, 94, 121, 1),
                ),
                onPressed: () {
                  performSearch(textEditController.text.trim());
                },
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        if (isLoading)
          const Center(child: CircularProgressIndicator())
        else if (errorMessage.isNotEmpty)
          Text(
            errorMessage,
            style: const TextStyle(
                color: Colors.red, fontFamily: "PokemonNormal"),
          )
        else
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: searchResults.length,
              itemBuilder: (context, index) {
                final pokemon = searchResults[index];
                return InkWell(
                  key: Key(pokemon.id),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Text(
                            "#${pokemon.id} ${pokemon.name}",
                            style: const TextStyle(
                              fontFamily: "PokemonNormal",
                              color: Colors.white,
                              fontSize: 26,
                            ),
                          ),
                          const Spacer(),
                          SizedBox(
                            width: 90,
                            height: 90,
                            child: Hero(
                              tag: pokemon.id,
                              child: CachedNetworkImage(
                                fit: BoxFit.contain,
                                imageUrl: pokemon.imageUrl,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) =>
                                    CircularProgressIndicator(
                                      value: downloadProgress.progress,
                                      valueColor:
                                      const AlwaysStoppedAnimation<Color>(
                                          Colors.white),
                                    ),
                                errorWidget:
                                    (context, url, error) => const Icon(Icons.error),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Divider(height: 10),
                    ],
                  ),
                  onTap: () async {
                    setState(() {
                      isLoading = true;
                    });

                    try {
                      PokemonData pokemonData =
                      await graphQLCalls.getPokemonDataByIdOrName(
                          pokemon.id, pokemon.name);

                      List<PokemonData> allPokemons = PokemonRepository().allPokemons;
                      int selectedIndex = PokemonRepository().getIndexById(pokemonData.id);

                      if (selectedIndex == -1) {
                        widget.onError('Pokémon no encontrado en la lista.');
                        return;
                      }

                      navigatorKey.currentState?.push(
                        MaterialPageRoute(
                          builder: (context) => PerfilPokemon(
                            currentIndex: selectedIndex,
                            pokemonList: allPokemons,
                          ),
                        ),
                      );
                    } catch (error) {
                      widget.onError(
                          'Error al cargar el Pokémon: ${error.toString()}');
                    } finally {
                      if (mounted) {
                        setState(() {
                          isLoading = false;
                        });
                      }
                    }
                  },
                );
              },
            ),
          ),
      ],
    );
  }
}
