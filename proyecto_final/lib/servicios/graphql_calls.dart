import 'dart:convert';
import 'package:graphql_flutter/graphql_flutter.dart';
import '../entidades/pokemon_data.dart';
import 'graphql_service.dart';

class GraphQLCalls {
  final GraphQLService _graphQLService = GraphQLService();

  Future<List<PokemonData>> getPokemonList({int limit = 20, int offset = 0}) async {
    const String query = '''
      query GetPokemonList(\$limit: Int, \$offset: Int) {
        pokemon_v2_pokemon(limit: \$limit, offset: \$offset) {
          id
          name
          pokemon_v2_pokemonsprites {
            sprites
          }
        }
      }
    ''';

    final GraphQLClient client = _graphQLService.getClient();
    final QueryOptions options = QueryOptions(
      document: gql(query),
      variables: {
        'limit': limit,
        'offset': offset,
      },
      fetchPolicy: FetchPolicy.networkOnly, // Obtener siempre datos en tiempo real
    );

    final QueryResult result = await client.query(options);

    if (result.hasException) {
      throw Exception(result.exception.toString());
    }

    final List data = result.data?['pokemon_v2_pokemon'] ?? [];
    return data.map((item) {
      String imageUrl = '';
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

      return PokemonData(
        id: item['id'].toString(),
        name: item['name'],
        imageUrl: imageUrl,
      );
    }).toList();
  }
}
