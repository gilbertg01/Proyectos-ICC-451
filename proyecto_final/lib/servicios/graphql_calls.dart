import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entidades/pokemon_data.dart';
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

      return PokemonData(
        id: item['id'].toString(),
        name: item['name'],
        imageUrl: imageUrl,
        types: types,
      );
    }).toList();
  }
}
