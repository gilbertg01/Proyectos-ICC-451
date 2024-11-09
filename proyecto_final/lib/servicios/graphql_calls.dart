import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entidades/pokemon_data.dart';
import '../entidades/pokemon_info.dart';
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
            pokemon_v2_pokemonsprites {
              sprites
            }
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
                name
              }
            }
            pokemon_v2_pokemonspecy {  # Corregido a "pokemon_v2_pokemonspecy"
              base_happiness
              capture_rate
              pokemon_v2_pokemonhabitat {  # Corregido a "pokemon_v2_pokemonhabitat"
                name
              }
              growth_rate: pokemon_v2_growthrate {  # Corregido a "pokemon_v2_growthrate"
                name
              }
              pokemon_v2_pokemonspeciesflavortexts(limit: 1, where: {language_id: {_eq: 9}}) {  # Ajuste en "flavor_text"
                flavor_text
              }
              pokemon_v2_pokemonegggroups {  # Corregido a "pokemon_v2_pokemonegggroups"
                pokemon_v2_egggroup {
                  name
                }
              }
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
            pokemon_v2_pokemonsprites {
              sprites
            }
            pokemon_v2_pokemontypes {
              pokemon_v2_type {
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
        types = (item['pokemon_v2_pokemontypes'] as List).map((typeItem) {
          return typeItem['pokemon_v2_type']['name'] as String;
        }).toList();
      }

      final species = item['pokemon_v2_pokemonspecy'];
      final info = PokemonInfo(
        baseHappiness: species['base_happiness'] ?? 0,
        captureRate: species['capture_rate'] ?? 0,
        habitat: species['pokemon_v2_pokemonhabitat']?['name'] ?? 'Unknown',
        growthRate: species['growth_rate']?['name'] ?? 'Unknown',
        flavorText: (species['pokemon_v2_pokemonspeciesflavortexts'] as List?)?.first['flavor_text'] ?? 'No description available',
        eggGroups: (species['pokemon_v2_pokemonegggroups'] as List<dynamic>?)
            ?.map((e) => e['pokemon_v2_egggroup']['name'] as String)
            .toList() ?? [],
      );

      return PokemonData(
        id: item['id'].toString(),
        name: item['name'],
        imageUrl: imageUrl,
        types: types,
        info: info
      );
    }).toList();
  }
}
