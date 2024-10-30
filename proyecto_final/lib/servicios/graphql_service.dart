import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  final HttpLink httpLink = HttpLink('https://beta.pokeapi.co/graphql/v1beta');

  late GraphQLClient client;

  GraphQLService() {
    client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(),
    );
  }

  GraphQLClient getClient() {
    return client;
  }
}
