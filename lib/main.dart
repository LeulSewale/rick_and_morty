import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rick_and_morty_app/feature/main_tab/main_tab.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:graphql_flutter/graphql_flutter.dart';
import 'feature/onboarding/onboarding_screen.dart';
import 'core/services/graphql_service.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:flutter_i18n/loaders/file_translation_loader.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initHiveForFlutter();
  await GraphQLService.initialize();
  final prefs = await SharedPreferences.getInstance();
  final seenOnboarding = prefs.getBool('onboarding_seen') ?? false;
  final savedLanguage = prefs.getString('selected_language') ?? 'en';

  runApp(
    ProviderScope(
      child: MyApp(
        seenOnboarding: seenOnboarding,
        initialLocale: Locale(savedLanguage),
      ),
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool seenOnboarding;
  final Locale initialLocale;
  const MyApp({required this.seenOnboarding, required this.initialLocale});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late Locale _locale;

  @override
  void initState() {
    super.initState();
    _locale = widget.initialLocale;
  }

  void setLocale(Locale locale) {
    setState(() {
      _locale = locale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      key: ValueKey(_locale.languageCode),
      locale: _locale,
      home: widget.seenOnboarding
          ? MainTabScreen(
              key: ValueKey(_locale.languageCode),
              onLocaleChanged: setLocale,
            )
          : OnboardingScreen(onLocaleChanged: setLocale),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: [
        FlutterI18nDelegate(
          translationLoader: FileTranslationLoader(
            useCountryCode: false,
            fallbackFile: 'en',
            basePath: 'assets/i18n',
            forcedLocale: _locale,
          ),
        ),
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('am'),
      ],
    );
  }
}
