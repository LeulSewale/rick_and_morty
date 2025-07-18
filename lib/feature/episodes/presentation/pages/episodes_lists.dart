import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/paginated_episodes_provider.dart';
import 'package:rick_and_morty_app/core/services/error_utils.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';

class EpisodesGrid extends ConsumerStatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const EpisodesGrid({super.key, this.onLocaleChanged});

  @override
  _EpisodesGridState createState() => _EpisodesGridState();
}

class _EpisodesGridState extends ConsumerState<EpisodesGrid> {
  late ScrollController _scrollController;
  final _retryLoadingProvider = StateProvider<bool>((ref) => false);

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_pagination);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(paginatedEpisodesProvider.notifier).fetchAllEpisodes();
    });
  }

  void _pagination() {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {
      ref.read(paginatedEpisodesProvider.notifier).fetchNextPage();
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
    final episodesAsync = ref.watch(paginatedEpisodesProvider);
    Theme.of(context);
    return Scaffold(
      body: episodesAsync.when(
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
                            ref.refresh(paginatedEpisodesProvider);
                            await Future.delayed(const Duration(milliseconds: 500));
                            notifier.state = false;
                          },
                    child: Text(FlutterI18n.translate(context, 'retry') ?? 'Retry'),
                  ),
                ],
              ),
            );
          },
        ),
        data: (episodes) => RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(paginatedEpisodesProvider);
            await ref
                .read(paginatedEpisodesProvider.notifier)
                .fetchAllEpisodes();
          },
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.only(
                    top: 16, left: 16, right: 16, bottom: 8),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.asset(
                        'assets/images/move1.jpg',
                        height: 250,
                        width: double.infinity,
                        fit: BoxFit.cover,
                      ),
                    ),
                    Icon(
                      Icons.play_circle_fill,
                      size: 64,
                      color: Colors.white,
                    ),
                  ],
                ),
              ),
              Expanded(
                child: ListView.builder(
                  controller: _scrollController,
                  itemCount: episodes.length,
                  itemBuilder: (_, index) {
                    final episode = episodes[index];
                    return Card(
                      elevation: 1,
                      clipBehavior: Clip.hardEdge,
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              episode.name,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 18,
                              ),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Text(
                                  episode.episode,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                                SizedBox(width: 16),
                                Text(
                                  episode.airDate,
                                  style: const TextStyle(
                                    color: Colors.grey,
                                    fontSize: 14,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
