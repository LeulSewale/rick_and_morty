import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/providers/location_provider.dart';
import 'package:rick_and_morty_app/core/services/error_utils.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:lottie/lottie.dart';

final _retryLoadingProvider = StateProvider<bool>((ref) => false);

class LocationsList extends ConsumerWidget {
  final void Function(Locale)? onLocaleChanged;
  const LocationsList({super.key, this.onLocaleChanged});
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locationsAsync = ref.watch(locationsProvider);
    Theme.of(context);
    return Scaffold(
      // Remove appBar here, only provide body
      body: locationsAsync.when(
        data: (locations) => RefreshIndicator(
          onRefresh: () async {
            ref.refresh(locationsProvider);
            await Future.delayed(const Duration(milliseconds: 500));
          },
          child: ListView.builder(
            itemCount: locations.length,
            itemBuilder: (_, index) => ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.asset(
                  'assets/images/location.jpg',
                  width: 48,
                  height: 48,
                  fit: BoxFit.cover,
                ),
              ),
              title: Text(locations[index].name),
              subtitle: Text('${locations[index].type} • ${locations[index].dimension}'),
            ),
          ),
        ),
        loading: () => Center(child: CircularProgressIndicator()),
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
                            ref.refresh(locationsProvider);
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
      ),
    );
  }
}
