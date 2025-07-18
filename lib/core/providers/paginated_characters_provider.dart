import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty_app/core/graphql/queries/get_character_query.dart';
import '../services/graphql_service.dart';
import '../../feature/characters/data/model/character.dart';

class CharacterPaginationNotifier extends StateNotifier<AsyncValue<List<Character>>> {
  CharacterPaginationNotifier() : super(const AsyncValue.loading());

  int currentPage = 1;
  bool isLoading = false;
  bool hasMore = true;
  List<Character> _characters = [];

  Future<void> fetchNextPage() async {
    if (isLoading || !hasMore) return;
    isLoading = true;
    if (_characters.isEmpty) state = const AsyncValue.loading();
    try {
      final service = GraphQLService.getInstance();
      final client = service.client;
      final result = await client.query(QueryOptions(
        document: gql(getCharactersQuery),
        variables: {'page': currentPage},
      ));
      if (result.hasException) {
        state = AsyncValue.error(result.exception!, StackTrace.current);
        isLoading = false;
        return;
      }
      final List newCharacters = result.data!['characters']['results'];
      final parsed = newCharacters.map((e) => Character.fromJson(Map<String, dynamic>.from(e))).toList();
      if (parsed.isEmpty) {
        hasMore = false;
      } else {
        _characters = [..._characters, ...parsed];
        state = AsyncValue.data(_characters);
        currentPage++;
      }
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    } finally {
      isLoading = false;
    }
  }
}

final paginatedCharactersProvider =
    StateNotifierProvider<CharacterPaginationNotifier, AsyncValue<List<Character>>>(
        (ref) => CharacterPaginationNotifier());
