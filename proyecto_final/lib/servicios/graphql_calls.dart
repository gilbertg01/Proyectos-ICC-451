import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entidades/move_data.dart';
import '../entidades/pokemon_data.dart';
import '../entidades/pokemon_info.dart';
import '../entidades/pokemon_more_info.dart';
import '../entidades/pokemon_stats.dart';
import '../entidades/pokemon_evolution.dart';
import 'graphql_service.dart';
import 'dart:collection';

class GraphQLCalls {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<PokemonData>> getPokemonList({int limit = 20, int offset = 0, String filter = "all", String generation = ""}) async {
    String query;

    query = '''
    query GetPokemonList(\$limit: Int, \$offset: Int, \$type: String, \$generation: String) {
      pokemon_v2_pokemon(
        limit: \$limit,
        offset: \$offset,
        where: {
          _and: [
            {pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_eq: \$type}}}},
            {pokemon_v2_pokemonspecy: {pokemon_v2_generation: {name: {_eq: \$generation}}}}
          ]
        },
        order_by: {id: asc}
      ) {
        id
        name
        pokemon_v2_pokemonsprites {
          sprites
        }
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
    ''';

    Map<String, dynamic> variables = {
      'limit': limit,
      'offset': offset,
      'type': filter == "all" ? null : filter,
      'generation': generation.isEmpty ? null : generation,
    };

    if (variables['type'] == null && variables['generation'] == null) {
      query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset, order_by: {id: asc}) {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
      ''';

      variables.remove('type');
      variables.remove('generation');
    } else if (variables['type'] == null) {
      query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int, \$generation: String) {
        pokemon_v2_pokemon(
          limit: \$limit,
          offset: \$offset,
          where: {
            pokemon_v2_pokemonspecy: {pokemon_v2_generation: {name: {_eq: \$generation}}}
          },
          order_by: {id: asc}
        ) {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
      ''';
      variables.remove('type');
    } else if (variables['generation'] == null) {
      query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int, \$type: String) {
        pokemon_v2_pokemon(
          limit: \$limit,
          offset: \$offset,
          where: {
            pokemon_v2_pokemontypes: {pokemon_v2_type: {name: {_eq: \$type}}}
          },
          order_by: {id: asc}
        ) {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
        }
      }
      ''';
      variables.remove('generation');
    }

    final GraphQLClient client = _graphQLService.getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List data = result.data?['pokemon_v2_pokemon'] ?? [];

    return data.map((item) {
      String imageUrl = '';
      List<String> types = [];

      if (item['pokemon_v2_pokemonsprites'] != null &&
          item['pokemon_v2_pokemonsprites'].isNotEmpty) {
        final spritesJson = item['pokemon_v2_pokemonsprites'][0]['sprites'];

        if (spritesJson is String) {
          final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
          imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? '';
        } else if (spritesJson is Map<String, dynamic>) {
          imageUrl = spritesJson['other']?['official-artwork']?['front_default'] ?? '';
        }
      }

      if (item['pokemon_v2_pokemontypes'] != null) {
        types = (item['pokemon_v2_pokemontypes'] as List)
            .map((typeItem) => typeItem['pokemon_v2_type']['name'] as String)
            .toList();
      }

      return PokemonData(
        id: item['id'].toString(),
        name: item['name'],
        imageUrl: imageUrl,
        types: types,
        info: null,
        moreInfo: null,
        stats: null,
        evolution: null,
        moves: [],
      );
    }).toList();
  }

  Future<PokemonData> getPokemonDetails(String id) async {
    String query = '''
  query GetPokemonDetails(\$id: Int!) {
    pokemon_v2_pokemon_by_pk(id: \$id) {
      id
      name
      height
      weight
      pokemon_v2_pokemonsprites {
        sprites
      }
      pokemon_v2_pokemontypes {
        pokemon_v2_type {
          name
        }
      }
      pokemon_v2_pokemonabilities {
        pokemon_v2_ability {
          name
        }
      }
      pokemon_v2_pokemonstats {
        base_stat
        pokemon_v2_stat {
          name
        }
      }
      pokemon_v2_pokemonmoves {
        pokemon_v2_move {
          name
          accuracy
          power
          pp
          pokemon_v2_type {
            name
          }
          pokemon_v2_movedamageclass {
            name
          }
          pokemon_v2_moveeffect {
            pokemon_v2_moveeffecteffecttexts(limit: 1, where: {language_id: {_eq: 9}}) {
              effect
            }
          }
        }
      }
      pokemon_v2_pokemonspecy {
        base_happiness
        capture_rate
        pokemon_v2_pokemonhabitat {
          name
        }
        growth_rate: pokemon_v2_growthrate {
          name
        }
        pokemon_v2_pokemonspeciesflavortexts(limit: 1, where: {language_id: {_eq: 9}}) {
          flavor_text
        }
        pokemon_v2_pokemonegggroups {
          pokemon_v2_egggroup {
            name
          }
        }
        id
        evolution_chain_id
      }
    }
  }
  ''';

    final variables = {
      'id': int.parse(id),
    };

    final GraphQLClient client = _graphQLService.getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final item = result.data?['pokemon_v2_pokemon_by_pk'];

    if (item == null) {
      throw Exception("Pokémon no encontrado");
    }

    String imageUrl = '';
    List<String> types = [];

    if (item['pokemon_v2_pokemonsprites'] != null &&
        item['pokemon_v2_pokemonsprites'].isNotEmpty) {
      final spritesJson = item['pokemon_v2_pokemonsprites'][0]['sprites'];

      if (spritesJson is String) {
        final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
        imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? '';
      } else if (spritesJson is Map<String, dynamic>) {
        imageUrl = spritesJson['other']?['official-artwork']?['front_default'] ?? '';
      }
    }

    if (item['pokemon_v2_pokemontypes'] != null) {
      types = (item['pokemon_v2_pokemontypes'] as List)
          .map((typeItem) => typeItem['pokemon_v2_type']['name'] as String)
          .toList();
    }

    final species = item['pokemon_v2_pokemonspecy'];
    final info = PokemonInfo(
      baseHappiness: species?['base_happiness'] ?? 0,
      captureRate: species?['capture_rate'] ?? 0,
      habitat: species?['pokemon_v2_pokemonhabitat']?['name'] ?? 'Desconocido',
      growthRate: species?['growth_rate']?['name'] ?? 'Desconocido',
      flavorText: (species?['pokemon_v2_pokemonspeciesflavortexts'] as List?)
          ?.first['flavor_text'] ??
          'No hay descripción disponible',
      eggGroups: (species?['pokemon_v2_pokemonegggroups'] as List<dynamic>?)
          ?.map((e) => e['pokemon_v2_egggroup']['name'] as String)
          .toList() ??
          [],
    );

    final abilities = item['pokemon_v2_pokemonabilities']
        ?.map<String>((ability) =>
    ability['pokemon_v2_ability']['name'] as String)
        .toList() ??
        [];

    final stats = PokemonStats(
      hp: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'hp',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      attack: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'attack',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      defense: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'defense',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      specialAttack: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'special-attack',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      specialDefence: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'special-defense',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      speed: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'speed',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
    );

    final evolutions = species != null
        ? await _getPokemonEvolutions(species['evolution_chain_id'])
        : <PokemonEvolution>[];

    Map<String, MoveData> movesMap = {};

    if (item['pokemon_v2_pokemonmoves'] != null) {
      for (var moveItem in item['pokemon_v2_pokemonmoves']) {
        final move = moveItem['pokemon_v2_move'];
        if (move != null) {
          final moveName = move['name'] ?? '';
          if (!movesMap.containsKey(moveName)) {
            movesMap[moveName] = MoveData(
              name: moveName,
              accuracy: move['accuracy'] as int?,
              power: move['power'] as int?,
              pp: move['pp'] as int?,
              type: move['pokemon_v2_type']?['name'],
              damageClass: move['pokemon_v2_movedamageclass']?['name'],
              effect: move['pokemon_v2_moveeffect'] != null &&
                  move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'] != null &&
                  (move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'] as List).isNotEmpty
                  ? move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'][0]['effect'] as String?
                  : null,
            );
          }
        }
      }
    }

    final List<MoveData> moves = movesMap.values.toList();

    return PokemonData(
      id: item['id'].toString(),
      name: item['name'],
      imageUrl: imageUrl,
      types: types,
      info: info,
      moreInfo: PokemonMoreInfo(
        height: item['height'] ?? 0,
        weight: item['weight'] ?? 0,
        types: types,
        abilities: abilities,
      ),
      stats: stats,
      evolution: evolutions,
      moves: moves,
    );
  }

  Future<List<PokemonEvolution>> _getPokemonEvolutions(int chainId) async {
    const query = '''
    query GetEvolutionChain(\$chainId: Int!) {
      pokemon_v2_pokemonspecies(
        where: {evolution_chain_id: {_eq: \$chainId}}
      ) {
        id
        name
        evolves_from_species_id
        pokemon_v2_pokemons {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
        }
      }
    }
  ''';

    final options = QueryOptions(
      document: gql(query),
      variables: {'chainId': chainId},
    );

    final result = await _graphQLService.getClient().query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final speciesList = result.data?['pokemon_v2_pokemonspecies'] ?? [];

    Map<int, PokemonEvolution> speciesMap = {};
    for (var species in speciesList) {
      int id = species['id'];
      String name = species['name'];
      int? evolvesFromId = species['evolves_from_species_id'];
      String url = '';

      if (species['pokemon_v2_pokemons'] != null &&
          species['pokemon_v2_pokemons'].isNotEmpty &&
          species['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'] != null &&
          species['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'].isNotEmpty) {
        final spritesJson =
        species['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'][0]['sprites'];

        if (spritesJson is String) {
          final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
          url = spritesMap['other']?['official-artwork']?['front_default'] ??
              spritesMap['front_default'] ?? '';
        } else if (spritesJson is Map<String, dynamic>) {
          url = spritesJson['other']?['official-artwork']?['front_default'] ??
              spritesJson['front_default'] ?? '';
        }
      }

      speciesMap[id] = PokemonEvolution(
        id: id.toString(),
        name: name,
        url: url.isNotEmpty ? url : 'https://via.placeholder.com/150',
        evolvesFromId: evolvesFromId?.toString(),
        evolvesTo: [],
      );
    }

    for (var species in speciesMap.values) {
      if (species.evolvesFromId != null) {
        int evolvesFromId = int.parse(species.evolvesFromId!);
        if (speciesMap.containsKey(evolvesFromId)) {
          speciesMap[evolvesFromId]!.evolvesTo.add(species);
        }
      }
    }

    PokemonEvolution? rootSpecies;
    for (var species in speciesMap.values) {
      if (species.evolvesFromId == null) {
        rootSpecies = species;
        break;
      }
    }

    if (rootSpecies == null) {
      throw Exception('No se pudo encontrar la especie raíz en la cadena evolutiva.');
    }

    List<PokemonEvolution> evolutionChain = _buildEvolutionChain(rootSpecies);

    return evolutionChain;
  }

  List<PokemonEvolution> _buildEvolutionChain(PokemonEvolution species) {
    List<PokemonEvolution> chain = [species];
    for (var evolvesTo in species.evolvesTo) {
      chain.addAll(_buildEvolutionChain(evolvesTo));
    }
    return chain;
  }

  Future<List<PokemonData>> getPokemonListByIds(List<String> ids) async {
    String query = '''
    query GetPokemonListByIds(\$ids: [Int!]) {
      pokemon_v2_pokemon(
        where: {id: {_in: \$ids}},
        order_by: {id: asc}
      ) {
        id
        name
        pokemon_v2_pokemonsprites {
          sprites
        }
        pokemon_v2_pokemontypes {
          pokemon_v2_type {
            name
          }
        }
      }
    }
    ''';

    final variables = {
      'ids': ids.map(int.parse).toList(),
    };

    final GraphQLClient client = _graphQLService.getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List data = result.data?['pokemon_v2_pokemon'] ?? [];

    return data.map((item) {
      String imageUrl = '';
      List<String> types = [];

      if (item['pokemon_v2_pokemonsprites'] != null &&
          item['pokemon_v2_pokemonsprites'].isNotEmpty) {
        final spritesJson = item['pokemon_v2_pokemonsprites'][0]['sprites'];

        if (spritesJson is String) {
          final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
          imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? '';
        } else if (spritesJson is Map<String, dynamic>) {
          imageUrl = spritesJson['other']?['official-artwork']?['front_default'] ?? '';
        }
      }

      if (item['pokemon_v2_pokemontypes'] != null) {
        types = (item['pokemon_v2_pokemontypes'] as List)
            .map((typeItem) => typeItem['pokemon_v2_type']['name'] as String)
            .toList();
      }

      return PokemonData(
        id: item['id'].toString(),
        name: item['name'],
        imageUrl: imageUrl,
        types: types,
        info: null,
        moreInfo: null,
        stats: null,
        evolution: null,
        moves: [],
      );
    }).toList();
  }

  Future<PokemonData?> getPokemonDetailsByName(String name) async {
    String query = '''
      query GetPokemonDetailsByName(\$name: String!) {
        pokemon_v2_pokemon(where: {name: {_eq: \$name}}) {
          id
          name
          height
          weight
          pokemon_v2_pokemonsprites {
            sprites
          }
          pokemon_v2_pokemontypes {
            pokemon_v2_type {
              name
            }
          }
          pokemon_v2_pokemonabilities {
            pokemon_v2_ability {
              name
            }
          }
          pokemon_v2_pokemonstats {
            base_stat
            pokemon_v2_stat {
              name
            }
          }
          pokemon_v2_pokemonmoves {
            pokemon_v2_move {
              name
              accuracy
              power
              pp
              pokemon_v2_type {
                name
              }
              pokemon_v2_movedamageclass {
                name
              }
              pokemon_v2_moveeffect {
                pokemon_v2_moveeffecteffecttexts(limit: 1, where: {language_id: {_eq: 9}}) {
                  effect
                }
              }
            }
          }
          pokemon_v2_pokemonspecy {
            base_happiness
            capture_rate
            pokemon_v2_pokemonhabitat {
              name
            }
            growth_rate: pokemon_v2_growthrate {
              name
            }
            pokemon_v2_pokemonspeciesflavortexts(limit: 1, where: {language_id: {_eq: 9}}) {
              flavor_text
            }
            pokemon_v2_pokemonegggroups {
              pokemon_v2_egggroup {
                name
              }
            }
            id
            evolution_chain_id
          }
        }
      }
    ''';

    final variables = {
      'name': name,
    };

    final GraphQLClient client = _graphQLService.getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: variables,
      fetchPolicy: FetchPolicy.networkOnly,
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List data = result.data?['pokemon_v2_pokemon'] ?? [];

    if (data.isEmpty) {
      return null;
    }

    final item = data.first;

    String imageUrl = '';
    List<String> types = [];

    if (item['pokemon_v2_pokemonsprites'] != null &&
        item['pokemon_v2_pokemonsprites'].isNotEmpty) {
      final spritesJson = item['pokemon_v2_pokemonsprites'][0]['sprites'];

      if (spritesJson is String) {
        final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
        imageUrl = spritesMap['other']?['official-artwork']?['front_default'] ?? '';
      } else if (spritesJson is Map<String, dynamic>) {
        imageUrl = spritesJson['other']?['official-artwork']?['front_default'] ?? '';
      }
    }

    if (item['pokemon_v2_pokemontypes'] != null) {
      types = (item['pokemon_v2_pokemontypes'] as List)
          .map((typeItem) => typeItem['pokemon_v2_type']['name'] as String)
          .toList();
    }

    final species = item['pokemon_v2_pokemonspecy'];
    final info = PokemonInfo(
      baseHappiness: species?['base_happiness'] ?? 0,
      captureRate: species?['capture_rate'] ?? 0,
      habitat: species?['pokemon_v2_pokemonhabitat']?['name'] ?? 'Desconocido',
      growthRate: species?['growth_rate']?['name'] ?? 'Desconocido',
      flavorText: (species?['pokemon_v2_pokemonspeciesflavortexts'] as List?)
          ?.first['flavor_text']
          ?.replaceAll('\n', ' ') ??
          'No hay descripción disponible',
      eggGroups: (species?['pokemon_v2_pokemonegggroups'] as List<dynamic>?)
          ?.map((e) => e['pokemon_v2_egggroup']['name'] as String)
          .toList() ??
          [],
    );

    final abilities = item['pokemon_v2_pokemonabilities']
        ?.map<String>((ability) =>
    ability['pokemon_v2_ability']['name'] as String)
        .toList() ??
        [];

    final stats = PokemonStats(
      hp: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'hp',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      attack: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'attack',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      defense: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'defense',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      specialAttack: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'special-attack',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      specialDefence: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'special-defense',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
      speed: item['pokemon_v2_pokemonstats']?.firstWhere(
            (s) => s['pokemon_v2_stat']['name'] == 'speed',
        orElse: () => {'base_stat': 0},
      )['base_stat'] ??
          0,
    );

    final evolutions = species != null
        ? await _getPokemonEvolutions(species['evolution_chain_id'])
        : <PokemonEvolution>[];

    Map<String, MoveData> movesMap = {};

    if (item['pokemon_v2_pokemonmoves'] != null) {
      for (var moveItem in item['pokemon_v2_pokemonmoves']) {
        final move = moveItem['pokemon_v2_move'];
        if (move != null) {
          final moveName = move['name'] ?? '';
          if (!movesMap.containsKey(moveName)) {
            movesMap[moveName] = MoveData(
              name: moveName,
              accuracy: move['accuracy'] as int?,
              power: move['power'] as int?,
              pp: move['pp'] as int?,
              type: move['pokemon_v2_type']?['name'],
              damageClass: move['pokemon_v2_movedamageclass']?['name'],
              effect: move['pokemon_v2_moveeffect'] != null &&
                  move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'] != null &&
                  (move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'] as List).isNotEmpty
                  ? move['pokemon_v2_moveeffect']['pokemon_v2_moveeffecteffecttexts'][0]
              ['effect'] as String?
                  : null,
            );
          }
        }
      }
    }

    final List<MoveData> moves = movesMap.values.toList();

    return PokemonData(
      id: item['id'].toString(),
      name: capitalize(item['name']),
      imageUrl: imageUrl,
      types: types,
      info: info,
      moreInfo: PokemonMoreInfo(
        height: item['height'] ?? 0,
        weight: item['weight'] ?? 0,
        types: types,
        abilities: abilities,
      ),
      stats: stats,
      evolution: evolutions,
      moves: moves,
    );
  }

  Future<PokemonData> getPokemonDataByIdOrName(String id, String name) async {
    PokemonData? pokemon;
    if (id.isNotEmpty) {
      pokemon = await getPokemonDetails(id);
    }
    if (pokemon == null && name.isNotEmpty) {
      pokemon = await getPokemonDetailsByName(name);
    }
    if (pokemon == null) {
      throw Exception('Pokémon no encontrado.');
    }
    return pokemon;
  }
  String capitalize(String s) => s[0].toUpperCase() + s.substring(1);

  Future<List<PokemonData>> getAllPokemons() async {
    return await getPokemonList(limit: 1000, offset: 0, filter: "all", generation: "");
  }
}
