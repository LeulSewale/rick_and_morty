import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty_app/core/graphql/queries/get_location_query.dart';
import '../services/graphql_service.dart';
import '../../feature/locations/data/model/location.dart';

final locationsProvider = FutureProvider<List<Location>>((ref) async {
  final service = GraphQLService.getInstance();
  final client = service.client;
  final result =
      await client.query(QueryOptions(document: gql(getLocationsQuery)));

  if (result.hasException) throw result.exception!;
  final List locations = result.data!['locations']['results'];
  return locations.map((e) => Location.fromJson(Map<String, dynamic>.from(e))).toList();
});
