import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:rick_and_morty_app/core/graphql/queries/get_character_query.dart';
import '../graphql/queries/get_character_by_id_query.dart';
import 'package:hive/hive.dart';
import '../services/graphql_service.dart';
import '../../feature/characters/data/model/character.dart';
import 'dart:async';

class CharacterPaginationNotifier extends StateNotifier<List<Character>> {
  CharacterPaginationNotifier(this.ref) : super([]) {
    fetchCharacters();
  }

  final Ref ref;
  int currentPage = 1;
  bool hasNext = true;
  bool isLoading = false;

  Future<void> fetchCharacters() async {
    if (!hasNext || isLoading) return;
    isLoading = true;
    try {
      final service = GraphQLService.getInstance();
      final client = service.client;
    final result = await client.query(
      QueryOptions(
        document: gql(getCharactersQuery),
        variables: {'page': currentPage},
      ),
    );
    if (result.hasException) {
        throw Exception('GraphQL error: ${result.exception}');
      }
      final data = result.data!['characters'];
      final List newCharacters = data['results'];
      hasNext = data['info']['next'] != null;
      final parsed = newCharacters.map((e) => Character.fromJson(Map<String, dynamic>.from(e))).toList();
      state = [...state, ...parsed];
      currentPage++;
    } catch (e) {
      // Optionally, you can log the error or show a message
      throw Exception('Failed to fetch characters: $e');
    } finally {
      isLoading = false;
    }
  }
}

final characterPaginationProvider =
    StateNotifierProvider<CharacterPaginationNotifier, List<Character>>(
        (ref) => CharacterPaginationNotifier(ref));

final characterByIdProvider = FutureProvider.family<Character, String>((ref, String id) async {
  return await (() async {
    final box = await Hive.openBox('character_details');
    final cached = box.get(id);
    if (cached != null) {
      return Character.fromJson(Map<String, dynamic>.from(cached));
    }
    final service = GraphQLService.getInstance();
    final result = await service.client.query(QueryOptions(
      document: gql(getCharacterByIdQuery),
      variables: {'id': id},
    ));
    if (result.hasException) throw result.exception!;
    final character = result.data!['character'];
    await box.put(id, character);
    return Character.fromJson(character);
  })().timeout(const Duration(seconds: 10));
});
