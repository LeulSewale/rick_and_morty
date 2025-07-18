

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:rick_and_morty_app/feature/main_tab/main_tab.dart';

class OnboardingScreen extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const OnboardingScreen({super.key, this.onLocaleChanged});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  bool _isLoading = false;
  String _selectedLanguage = 'en';
  bool _isLangLoading = false;

  final List<_PageData> _pages = [
    _PageData(
      image: 'assets/images/character.jpg',
      titleKey: 'characters',
      descriptionKey: 'onboarding_characters_desc',
    ),
    _PageData(
      image: 'assets/images/episode.jpg',
      titleKey: 'episodes',
      descriptionKey: 'onboarding_episodes_desc',
    ),
    _PageData(
      image: 'assets/images/locations.jpg',
      titleKey: 'locations',
      descriptionKey: 'onboarding_locations_desc',
    ),
  ];

  Future<void> _onGetStarted() async {
    setState(() => _isLoading = true);
    HapticFeedback.lightImpact();
    await Future.delayed(Duration(milliseconds: 400));
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('onboarding_seen', true);
    if (!mounted) return;
    widget.onLocaleChanged?.call(Locale(_selectedLanguage));
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (_) => MainTabScreen()),
    );
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final size = MediaQuery.of(context).size;

    return Stack(
      children: [
        Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_currentPage < _pages.length - 1)
            TextButton(
              onPressed: () {
                _pageController.jumpToPage(_pages.length - 1);
              },
              child: Text(FlutterI18n.translate(context, 'skip') ?? '', style: theme.textTheme.labelLarge?.copyWith(color: theme.colorScheme.primary)),
            ),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: _selectedLanguage,
              icon: Icon(Icons.language, color: theme.colorScheme.primary),
              items: [
                DropdownMenuItem(value: 'en', child: Text('English')),
                DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
              ],
              onChanged: (value) async {
                if (value != null) {
                      setState(() => _isLangLoading = true);
                  await FlutterI18n.refresh(context, Locale(value));
                      setState(() {
                        _selectedLanguage = value;
                        _isLangLoading = false;
                      });
                      final prefs = await SharedPreferences.getInstance();
                      await prefs.setString('selected_language', value);
                }
              },
              dropdownColor: theme.scaffoldBackgroundColor,
            ),
          ),
        ],
      ),
      body: PageView.builder(
        controller: _pageController,
        itemCount: _pages.length,
        onPageChanged: (index) => setState(() => _currentPage = index),
        itemBuilder: (context, index) {
          final page = _pages[index];
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: size.width * 0.08, vertical: 32),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Image.asset(
                  page.image,
                  height: 180,
                  fit: BoxFit.contain,
                ),
                SizedBox(height: 32),
                Text(
                  FlutterI18n.translate(context, page.titleKey) ?? '',
                  style: theme.textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 16),
                Text(
                  FlutterI18n.translate(context, page.descriptionKey) ?? '',
                  style: theme.textTheme.bodyLarge,
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        },
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: ElevatedButton(
            onPressed: _isLoading
                ? null
                : () {
                    if (_currentPage < _pages.length - 1) {
                      _pageController.nextPage(
                        duration: Duration(milliseconds: 300),
                        curve: Curves.easeInOut,
                      );
                    } else {
                      _onGetStarted();
                    }
                  },
            style: ElevatedButton.styleFrom(
              padding: EdgeInsets.symmetric(vertical: 18),
              textStyle: theme.textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: _isLoading
                ? CircularProgressIndicator(color: Colors.white, strokeWidth: 2.5)
                : Text(_currentPage == _pages.length - 1
                    ? (FlutterI18n.translate(context, 'get_started') ?? '')
                    : (FlutterI18n.translate(context, 'next') ?? '')),
          ),
        ),
      ),
        ),
        if (_isLangLoading)
          Container(
            color: Colors.black.withOpacity(0.2),
            child: Center(child: CircularProgressIndicator()),
          ),
      ],
    );
  }
}

class _PageData {
  final String image;
  final String titleKey;
  final String descriptionKey;

  _PageData({required this.image, required this.titleKey, required this.descriptionKey});
}
