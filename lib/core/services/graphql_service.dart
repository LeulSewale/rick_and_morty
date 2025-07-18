import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:hive/hive.dart';

class GraphQLService {
  static GraphQLService? _instance;
  late final GraphQLClient _client;

  GraphQLService._internal() {
    final httpLink = HttpLink("https://rickandmortyapi.com/graphql");
    _client = GraphQLClient(
      link: httpLink,
      cache: GraphQLCache(store: HiveStore()),
    );
  }

  static Future<void> initialize() async {
    if (_instance == null) {
      await Hive.openBox('character_details');
      _instance = GraphQLService._internal();
    }
  }

  static GraphQLService getInstance() {
    if (_instance == null) {
      throw Exception('GraphQLService not initialized. Call initialize() first.');
    }
    return _instance!;
  }

  GraphQLClient get client => _client;
} 