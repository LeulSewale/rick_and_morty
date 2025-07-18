import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty_app/core/graphql/queries/get_episodes_query.dart';
import '../services/graphql_service.dart';
import '../../feature/episodes/data/model/episode.dart';

class EpisodePaginationNotifier extends StateNotifier<AsyncValue<List<Episode>>> {
  EpisodePaginationNotifier() : super(const AsyncValue.loading());

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Episode> _episodes = [];

  Future<void> fetchNextPage() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    if (_episodes.isEmpty) state = const AsyncValue.loading();
    try {
      final service = GraphQLService.getInstance();
      final client = service.client;
      final result = await client.query(QueryOptions(
        document: gql(getEpisodesQuery),
        variables: {'page': currentPage},
      ));
      if (result.hasException) {
        state = AsyncValue.error(result.exception!, StackTrace.current);
        isLoading = false;
        return;
      }
      final data = result.data!['episodes'];
      final List newEpisodes = data['results'];
      hasMore = data['info']['next'] != null;
      final parsed = newEpisodes.map((e) => Episode.fromJson(Map<String, dynamic>.from(e))).toList();
      if (parsed.isEmpty) {
        hasMore = false;
      } else {
        _episodes = [..._episodes, ...parsed];
        state = AsyncValue.data(_episodes);
        currentPage++;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      isLoading = false;
    }
  }

  /// Fetch all episodes from all pages and update state with the complete list.
  Future<void> fetchAllEpisodes() async {
    if (isLoading) return;
    isLoading = true;
    state = const AsyncValue.loading();
    final service = GraphQLService.getInstance();
    final client = service.client;
    int page = 1;
    List<Episode> allEpisodes = [];
    bool more = true;
    try {
      while (more) {
        final result = await client.query(QueryOptions(
          document: gql(getEpisodesQuery),
          variables: {'page': page},
        ));
        if (result.hasException) {
          state = AsyncValue.error(result.exception!, StackTrace.current);
          isLoading = false;
          return;
        }
        final data = result.data!['episodes'];
        final List newEpisodes = data['results'];
        more = data['info']['next'] != null;
        final parsed = newEpisodes.map((e) => Episode.fromJson(Map<String, dynamic>.from(e))).toList();
        allEpisodes.addAll(parsed);
        page++;
      }
      _episodes = allEpisodes;
      state = AsyncValue.data(_episodes);
      currentPage = page;
      hasMore = false;
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      isLoading = false;
    }
  }
}

final paginatedEpisodesProvider =
    StateNotifierProvider<EpisodePaginationNotifier, AsyncValue<List<Episode>>>(
        (ref) => EpisodePaginationNotifier()); 