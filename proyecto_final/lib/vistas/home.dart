import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:proyecto_final_flutter/vistas/search.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';
import '../entidades/pokemon_data.dart';
import '../servicios/graphql_calls.dart';
import '../servicios/pokemon_favorites_controller.dart';
import '../widgets/pokemon_card.dart';

enum FilterSet {
  typeGeneration,
  abilityPower,
}

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
  bool showFavorites = false;
  final PokemonFavoritesController favoritesController = PokemonFavoritesController();

  String orderBy = "id";

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

  FilterSet activeFilterSet = FilterSet.typeGeneration;
  String? selectedAbility = "All";
  int? minPower = 0;

  List<String> pokemonAbilities = [
    "All",
  ];

  List<int> powerOptions = [0, 50, 100, 150, 200, 250];

  @override
  void initState() {
    super.initState();
    favoritesController.init();
    _fetchPokemonAbilities();
  }

  Future<void> _fetchPokemonAbilities() async {
    try {
      final abilities = await graphQLCalls.getPokemonAbilities();
      setState(() {
        pokemonAbilities = abilities;
      });
    } catch (error) {
      print("Error fetching abilities: $error");
    }
  }

  Future<bool> getPokemonData({bool isRefresh = false}) async {
    if (isRefresh) {
      pokemonsResult.clear();
    }

    try {
      if (showFavorites) {
        final favoriteIds = favoritesController.getFavoritePokemonsIds();
        if (favoriteIds.isEmpty) {
          setState(() {
            pokemonsResult = [];
          });
          return true;
        }
        final List<PokemonData> fetchedPokemons = await graphQLCalls.getPokemonListByIds(favoriteIds);
        setState(() {
          pokemonsResult = fetchedPokemons;
        });
      } else {
        List<PokemonData> fetchedPokemons = [];

        if (activeFilterSet == FilterSet.typeGeneration) {
          fetchedPokemons = await graphQLCalls.getPokemonList(
            limit: 20,
            offset: pokemonsResult.length,
            filter: selectedFilter!,
            generation: generations[selectedGenerationKey]!,
            orderBy: orderBy,
          );
        } else if (activeFilterSet == FilterSet.abilityPower) {
          bool applyAbilityFilter = selectedAbility != null && selectedAbility != "All";
          bool applyPowerFilter = minPower != null && minPower != 0;

          if (applyAbilityFilter && applyPowerFilter) {
            final List<PokemonData> pokemonsByAbility = await graphQLCalls.getPokemonByAbility(
              selectedAbility!,
              orderBy: orderBy,
            );

            final List<PokemonData> pokemonsByPower = await graphQLCalls.getPokemonByAttack(
              minPower!,
              orderBy: orderBy,
            );

            final favoriteIds = pokemonsByAbility.map((p) => p.id).toSet();
            final filteredPokemons = pokemonsByPower.where((p) => favoriteIds.contains(p.id)).toList();

            fetchedPokemons = filteredPokemons;
          } else if (applyAbilityFilter) {
            fetchedPokemons = await graphQLCalls.getPokemonByAbility(
              selectedAbility!,
              orderBy: orderBy,
            );
          } else if (applyPowerFilter) {
            fetchedPokemons = await graphQLCalls.getPokemonByAttack(
              minPower!,
              orderBy: orderBy,
            );
          } else {
            fetchedPokemons = await graphQLCalls.getPokemonList(
              limit: 20,
              offset: pokemonsResult.length,
              filter: "all",
              generation: "",
              orderBy: orderBy,
            );
          }
        }

        setState(() {
          pokemonsResult.addAll(fetchedPokemons);
        });
      }
      return true;
    } catch (error) {
      print("Error fetching Pokémon data: $error");
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

  void _changeOrderBy(String newOrderBy) {
    setState(() {
      orderBy = newOrderBy;
      pokemonsResult.clear();
      refreshController.requestRefresh(needMove: false);
    });
  }

  void _showOrderDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Order by'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.format_list_numbered),
              title: const Text('ID'),
              onTap: () {
                Navigator.pop(context);
                _changeOrderBy("id");
              },
            ),
            ListTile(
              leading: const Icon(Icons.text_fields),
              title: const Text('Name'),
              onTap: () {
                Navigator.pop(context);
                _changeOrderBy("name");
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            if (activeFilterSet == FilterSet.typeGeneration) ...[
              Flexible(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedFilter,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: Colors.black,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedFilter = newValue;
                        pokemonsResult.clear();
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
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: const Center(
                  child: Text(
                    "Pokedex",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontFamily: 'PokemonNormal',
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedGenerationKey,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: Colors.black,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedGenerationKey = newValue;
                        pokemonsResult.clear();
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
              ),
            ] else if (activeFilterSet == FilterSet.abilityPower) ...[
              Flexible(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<String>(
                    value: selectedAbility,
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: Colors.black,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        selectedAbility = newValue;
                        pokemonsResult.clear();
                        refreshController.requestRefresh(needMove: false);
                      });
                    },
                    items: pokemonAbilities.map((ability) {
                      return DropdownMenuItem(
                        value: ability,
                        child: Text(
                          ability == "All" ? "All" : ability.toUpperCase(),
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontFamily: "PokemonBold",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 3,
                child: const Center(
                  child: Text(
                    "Pokedex",
                    style: TextStyle(
                      color: Colors.yellowAccent,
                      fontFamily: 'PokemonNormal',
                      fontSize: 22,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                flex: 2,
                child: DropdownButtonHideUnderline(
                  child: DropdownButton<int>(
                    value: minPower ?? 0,
                    hint: const Text(
                      "All",
                      style: TextStyle(
                        color: Colors.yellowAccent,
                        fontFamily: "PokemonBold",
                      ),
                    ),
                    icon: const Icon(Icons.arrow_drop_down, color: Colors.white),
                    dropdownColor: Colors.black,
                    isExpanded: true,
                    onChanged: (newValue) {
                      setState(() {
                        minPower = newValue == 0 ? null : newValue;
                        pokemonsResult.clear();
                        refreshController.requestRefresh(needMove: false);
                      });
                    },
                    items: powerOptions.map((power) {
                      return DropdownMenuItem(
                        value: power,
                        child: Text(
                          power == 0 ? "All" : power.toString(),
                          style: const TextStyle(
                            color: Colors.yellowAccent,
                            fontFamily: "PokemonBold",
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ),
            ],
          ],
        ),
        backgroundColor: Colors.black,
        centerTitle: false,
      ),
      backgroundColor: Colors.black,
      body: SmartRefresher(
        controller: refreshController,
        enablePullUp: !showFavorites,
        onRefresh: () async {
          final result = await getPokemonData(
            isRefresh: true,
          );
          if (result) {
            refreshController.refreshCompleted();
          } else {
            refreshController.refreshFailed();
          }
        },
        onLoading: !showFavorites
            ? () async {
          final result = await getPokemonData();
          if (result) {
            refreshController.loadComplete();
          } else {
            refreshController.loadFailed();
          }
        }
            : null,
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
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const SearchScreen()),
              );
            },
          ),
          SpeedDialChild(
            child: Icon(showFavorites ? Icons.list : Icons.favorite, color: Colors.red),
            backgroundColor: Colors.yellowAccent,
            label: showFavorites ? 'Show all' : 'Favorites',
            onTap: () {
              setState(() {
                showFavorites = !showFavorites;
                pokemonsResult.clear();
                refreshController.requestRefresh(needMove: false);
              });
            },
          ),
          SpeedDialChild(
            child: const Icon(Icons.sort, color: Colors.black),
            backgroundColor: Colors.yellowAccent,
            label: 'Order',
            onTap: _showOrderDialog,
          ),
          SpeedDialChild(
            child: Icon(
              activeFilterSet == FilterSet.typeGeneration
                  ? Icons.filter_alt_off
                  : Icons.filter_alt,
              color: Colors.black,
            ),
            backgroundColor: Colors.yellowAccent,
            label: activeFilterSet == FilterSet.typeGeneration
                ? 'Use Ability and Power Filters'
                : 'Use Type and Generation Filters',
            onTap: () {
              setState(() {
                activeFilterSet = activeFilterSet == FilterSet.typeGeneration
                    ? FilterSet.abilityPower
                    : FilterSet.typeGeneration;

                if (activeFilterSet == FilterSet.abilityPower) {
                  selectedFilter = "all";
                  selectedGenerationKey = "None";
                } else {
                  selectedAbility = "All";
                  minPower = 0;
                }

                pokemonsResult.clear();
                refreshController.requestRefresh(needMove: false);
              });
            },
          ),
        ],
      ),
    );
  }
}
