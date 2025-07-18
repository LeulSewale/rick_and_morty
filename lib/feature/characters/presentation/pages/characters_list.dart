import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/feature/characters/presentation/pages/character_detail.dart';
import '../../../../core/providers/paginated_characters_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:rick_and_morty_app/core/services/error_utils.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';

class CharactersList extends ConsumerStatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const CharactersList({Key? key, this.onLocaleChanged}) : super(key: key);
  @override
  _CharactersListState createState() => _CharactersListState();
}

class _CharactersListState extends ConsumerState<CharactersList> {
  late ScrollController _scrollController;
  final _retryLoadingProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_pagination);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedCharactersProvider.notifier).fetchNextPage();
    });
  }

  void _pagination() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedCharactersProvider.notifier).fetchNextPage();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_pagination);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final charactersAsync = ref.watch(paginatedCharactersProvider);
    Theme.of(context);
    // Try to get onLocaleChanged from ancestor if provided
    return Scaffold(
      // Remove appBar here, only provide body
      body: charactersAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (error, _) => Consumer(
          builder: (context, ref, _) {
            final retryLoading = ref.watch(_retryLoadingProvider);
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (retryLoading)
                    const Padding(
                      padding: EdgeInsets.only(bottom: 16),
                      child: CircularProgressIndicator(),
                    ),
                  if (!retryLoading && parseError(context, error) == FlutterI18n.translate(context, 'no_internet'))
                    Lottie.asset('assets/lottie/No Connection.json', width: 180, repeat: true),
                  if (!retryLoading)
                    Text(parseError(context, error), textAlign: TextAlign.center),
                  SizedBox(height: 16),
                  ElevatedButton(
                   onPressed: retryLoading
    ? null
    : () async {
        final notifier = ref.read(_retryLoadingProvider.notifier);
        notifier.state = true;
        try {
          ref.invalidate(paginatedCharactersProvider); // clear previous error state
          await ref.read(paginatedCharactersProvider.notifier).fetchNextPage();
        } catch (_) {
          // Optional: Log or show toast/snackbar
        } finally {
          notifier.state = false;
        }
      },

                    child: Text(FlutterI18n.translate(context, 'retry') ?? 'Retry'),
                  ),
                ],
              ),
            );
          },
        ),
       data: (characters) => RefreshIndicator(
  onRefresh: () async {
    ref.invalidate(paginatedCharactersProvider);
    await ref.read(paginatedCharactersProvider.notifier).fetchNextPage();
  },
  child: GridView.builder(
    controller: _scrollController,
    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
      crossAxisCount: 2,
      crossAxisSpacing: 10,
      mainAxisSpacing: 10,
      childAspectRatio: 0.7,
    ),
    padding: const EdgeInsets.all(10),
    itemCount: characters.length,
    itemBuilder: (_, index) {
      final character = characters[index];
      return GestureDetector(
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => CharacterDetail(id: character.id),
          ),
        ),
        child: Card(
          elevation: 5,
          clipBehavior: Clip.hardEdge,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              CachedNetworkImage(
                imageUrl: character.image,
                fit: BoxFit.cover,
                placeholder: (context, url) => Center(child: CircularProgressIndicator()),
                errorWidget: (context, url, error) => Icon(Icons.error),
              ),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  width: double.infinity,
                  padding: EdgeInsets.symmetric(vertical: 8),
                  color: Colors.black54,
                  child: Text(
                    character.name,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  ),
),
  ),
    );
  }
}
