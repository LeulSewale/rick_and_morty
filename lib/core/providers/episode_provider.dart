import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty_app/core/graphql/queries/get_episodes_query.dart';
import '../services/graphql_service.dart';
import '../../feature/episodes/data/model/episode.dart';

final episodesProvider = FutureProvider<List<Episode>>((ref) async {
  final service = GraphQLService.getInstance();
  final client = service.client;
  final result =
      await client.query(QueryOptions(document: gql(getEpisodesQuery)));

  if (result.hasException) throw result.exception!;
  final List episodes = result.data!['episodes']['results'];
  return episodes.map((e) => Episode.fromJson(Map<String, dynamic>.from(e))).toList();
});
