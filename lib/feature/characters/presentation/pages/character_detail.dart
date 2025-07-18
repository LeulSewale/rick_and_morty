import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/character_provider.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rick_and_morty_app/core/services/error_utils.dart';
import 'package:lottie/lottie.dart';

class CharacterDetail extends ConsumerWidget {
  final String id;
  const CharacterDetail({super.key, required this.id});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final characterAsync = ref.watch(characterByIdProvider(id));
    final retryLoading = ref.watch(_retryLoadingProvider(id));

    return Scaffold(
      appBar: AppBar(
        title: Text(FlutterI18n.translate(context, 'character_detail')),
      ),
      body: characterAsync.when(
        data:
            (character) => RefreshIndicator(
              onRefresh: () async {
                ref.invalidate(characterByIdProvider(id));
                await ref.read(characterByIdProvider(id).future);
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Center(
                      child: Container(
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context).colorScheme.primary,
                            width: 3,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 12,
                              offset: Offset(0, 6),
                            ),
                          ],
                        ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(16),
                          child: CachedNetworkImage(
                            imageUrl: character.image,
                            height: 220,
                            width: 220,
                            fit: BoxFit.cover,
                            placeholder:
                                (context, url) => CircularProgressIndicator(),
                            errorWidget:
                                (context, url, error) => Icon(Icons.error),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 24),
                    Text(
                      character.name,
                      style: Theme.of(context).textTheme.headlineMedium
                          ?.copyWith(fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 24),
                    Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      color: Theme.of(context).colorScheme.surfaceVariant,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          vertical: 20,
                          horizontal: 24,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _InfoRow(
                              label: FlutterI18n.translate(context, 'status'),
                              value: character.status,
                              icon: Icons.info_outline,
                            ),
                            _InfoRow(
                              label: FlutterI18n.translate(context, 'species'),
                              value: character.species,
                              icon: Icons.pets,
                            ),
                            if (character.type.isNotEmpty)
                              _InfoRow(
                                label: FlutterI18n.translate(context, 'type'),
                                value: character.type,
                                icon: Icons.category,
                              ),
                            _InfoRow(
                              label: FlutterI18n.translate(context, 'gender'),
                              value: character.gender,
                              icon: Icons.wc,
                            ),
                            _InfoRow(
                              label: FlutterI18n.translate(context, 'origin'),
                              value:
                                  character.origin.isNotEmpty
                                      ? character.origin
                                      : FlutterI18n.translate(
                                        context,
                                        'unknown',
                                      ),
                              icon: Icons.public,
                            ),
                            _InfoRow(
                              label: FlutterI18n.translate(context, 'location'),
                              value:
                                  character.location.isNotEmpty
                                      ? character.location
                                      : FlutterI18n.translate(
                                        context,
                                        'unknown',
                                      ),
                              icon: Icons.place,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
        loading: () => const Center(child: CircularProgressIndicator()),
        error:
            (error, _) => Consumer(
              builder: (context, ref, _) {
                final retryLoading = ref.watch(_retryLoadingProvider(id));
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (retryLoading)
                        const Padding(
                          padding: EdgeInsets.only(bottom: 16),
                          child: CircularProgressIndicator(),
                        ),
                      if (!retryLoading &&
                          parseError(context, error) ==
                              FlutterI18n.translate(context, 'no_internet'))
                        Lottie.asset(
                          'assets/lottie/No Connection.json',
                          width: 180,
                          repeat: true,
                        ),
                      if (!retryLoading)
                        Text(
                          _getFriendlyErrorMessage(context, error),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: Colors.red,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed:
                            retryLoading
                                ? null
                                : () async {
                                  final notifier = ref.read(
                                    _retryLoadingProvider(id).notifier,
                                  );
                                  notifier.state = true;
                                  ref.invalidate(characterByIdProvider(id));
                                  try {
                                    await ref.read(
                                      characterByIdProvider(id).future,
                                    );
                                  } catch (_) {}
                                  notifier.state = false;
                                },

                        child: Text(
                          FlutterI18n.translate(context, 'retry') ?? 'Retry',
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      ),
    );
  }
}

final _retryLoadingProvider = StateProvider.family<bool, String>(
  (ref, id) => false,
);

class _InfoRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  const _InfoRow({
    required this.label,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0),
      child: Row(
        children: [
          Icon(icon, size: 22, color: Theme.of(context).colorScheme.primary),
          SizedBox(width: 10),
          Text(
            '$label: ',
            style: Theme.of(
              context,
            ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          Expanded(
            child: Text(value, style: Theme.of(context).textTheme.bodyMedium),
          ),
        ],
      ),
    );
  }
}

// Helper to ensure only user-friendly error messages are shown
String _getFriendlyErrorMessage(BuildContext context, Object error) {
  final parsed = parseError(context, error);
  // If parseError returns a technical message, fallback to a generic one
  if (parsed == FlutterI18n.translate(context, 'no_internet')) {
    return parsed;
  } else if (parsed == FlutterI18n.translate(context, 'server_error')) {
    return parsed;
  } else if (parsed == FlutterI18n.translate(context, 'timeout_error')) {
    return parsed;
  } else if (parsed == FlutterI18n.translate(context, 'data_format_error')) {
    return parsed;
  } else if (parsed == FlutterI18n.translate(context, 'unknown_error')) {
    return parsed;
  } else if (parsed == FlutterI18n.translate(context, 'something_went_wrong')) {
    return parsed;
  } else {
    // fallback to a generic message for anything else
    return FlutterI18n.translate(context, 'something_went_wrong') ??
        'Something went wrong. Please try again.';
  }
}
