import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rick_and_morty_app/feature/characters/presentation/pages/characters_list.dart';
import 'package:rick_and_morty_app/feature/episodes/presentation/pages/episodes_lists.dart';
import 'package:rick_and_morty_app/feature/locations/presentation/pages/location_list.dart';

class MainTabScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const MainTabScreen({super.key, this.onLocaleChanged});

  @override
  _MainTabScreenState createState() => _MainTabScreenState();
}

class _MainTabScreenState extends State<MainTabScreen> {
  int currentIndex = 0;
  String _selectedLanguage = 'en';

  final screens = [
    CharactersList(),
    EpisodesGrid(),
    LocationsList(),
  ];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final locale = Localizations.localeOf(context);
    _selectedLanguage = locale.languageCode;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitleForTab(currentIndex, context)),
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: Icon(Icons.language, color: Theme.of(context).colorScheme.primary),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
              ],
              onChanged: (value) async {
                if (value != null) {
                  setState(() => _selectedLanguage = value);
                  await FlutterI18n.refresh(context, Locale(value));
                }
              },
              style: Theme.of(context).textTheme.bodyMedium,
              dropdownColor: Theme.of(context).scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
      body: screens[currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: currentIndex,
        onTap: (index) => setState(() => currentIndex = index),
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.people),
            label: FlutterI18n.translate(context, 'characters'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.tv),
            label: FlutterI18n.translate(context, 'episodes'),
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.location_on),
            label: FlutterI18n.translate(context, 'locations'),
          ),
        ],
      ),
    );
  }

  String _getTitleForTab(int index, BuildContext context) {
    switch (index) {
      case 0:
        return FlutterI18n.translate(context, 'characters');
      case 1:
        return FlutterI18n.translate(context, 'episodes');
      case 2:
        return FlutterI18n.translate(context, 'locations');
      default:
        return '';
    }
  }
} 