import 'package:flutter/material.dart';
import 'package:graphql_flutter/graphql_flutter.dart';

class GraphQLService {
  static final HttpLink httpLink = HttpLink("https://rickandmortyapi.com/graphql");

  static ValueNotifier<GraphQLClient> initClient() {
    return ValueNotifier(GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    ));
  }
}
