import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entidades/pokemon_data.dart';
import '../entidades/pokemon_info.dart';
import '../entidades/pokemon_more_info.dart';
import '../entidades/pokemon_stats.dart';
import '../entidades/pokemon_evolution.dart';
import 'graphql_service.dart';

class GraphQLCalls {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<PokemonData>> getPokemonList({int limit = 20, int offset = 0, String filter = "all"}) async {
    String query;
    if (filter == "all") {
      query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset) {
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
    } else {
      query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int, \$type: String) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset, where: {
          pokemon_v2_pokemontypes: {
            pokemon_v2_type: {
              name: {
                _eq: \$type
              }
            }
          }
        }) {
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
    }

    Map<String, dynamic> variables = {
      'limit': limit,
      'offset': offset,
      if (filter != "all") 'type': filter,
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

    return Future.wait(data.map((item) async {
      String imageUrl = '';
      List<String> types = [];
      Set<String> moves = Set();

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

      if (item['pokemon_v2_pokemonmoves'] != null) {
        item['pokemon_v2_pokemonmoves'].forEach((moveItem) {
          moves.add(moveItem['pokemon_v2_move']['name'] as String);
        });
      }

      final List<String> uniqueMoves = moves.toList();

      final species = item['pokemon_v2_pokemonspecy'];
      final info = PokemonInfo(
        baseHappiness: species?['base_happiness'] ?? 0,
        captureRate: species?['capture_rate'] ?? 0,
        habitat: species?['pokemon_v2_pokemonhabitat']?['name'] ?? 'Unknown',
        growthRate: species?['growth_rate']?['name'] ?? 'Unknown',
        flavorText: (species?['pokemon_v2_pokemonspeciesflavortexts'] as List?)
            ?.first['flavor_text'] ??
            'No description available',
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
        moves: uniqueMoves,
      );
    }).toList());
  }

  Future<List<PokemonEvolution>> _getPokemonEvolutions(int chainId) async {
    const query = '''
    query GetEvolutionChain(\$chainId: Int!) {
      pokemon_v2_evolutionchain(where: {id: {_eq: \$chainId}}) {
        pokemon_v2_pokemonspecies(order_by: {id: asc}) {
          id
          name
          evolves_from_species_id
          pokemon_v2_pokemons {
            pokemon_v2_pokemonsprites {
              sprites
            }
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

    final evolutions = result.data?['pokemon_v2_evolutionchain']?[0]
    ?['pokemon_v2_pokemonspecies'] ?? [];

    return evolutions.map<PokemonEvolution>((e) {
      String url = '';
      if (e['pokemon_v2_pokemons'] != null &&
          e['pokemon_v2_pokemons'].isNotEmpty &&
          e['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'] != null &&
          e['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'].isNotEmpty) {
        final spritesJson =
        e['pokemon_v2_pokemons'][0]['pokemon_v2_pokemonsprites'][0]['sprites'];

        if (spritesJson is String) {
          final spritesMap = jsonDecode(spritesJson) as Map<String, dynamic>;
          url = spritesMap['other']?['official-artwork']?['front_default'] ??
              spritesMap['front_default'] ?? '';
        } else if (spritesJson is Map<String, dynamic>) {
          url = spritesJson['other']?['official-artwork']?['front_default'] ??
              spritesJson['front_default'] ?? '';
        }
      }

      return PokemonEvolution(
        id: e['id'].toString(),
        name: e['name'],
        url: url.isNotEmpty ? url : 'https://via.placeholder.com/150',
      );
    }).toList();
  }
}
