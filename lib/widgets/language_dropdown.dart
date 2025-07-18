import 'package:flutter/material.dart';
import 'package:flutter_i18n/flutter_i18n.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageDropdown extends StatefulWidget {
  final void Function(Locale)? onLocaleChanged;
  const LanguageDropdown({Key? key, this.onLocaleChanged}) : super(key: key);

  @override
  State<LanguageDropdown> createState() => _LanguageDropdownState();
}

class _LanguageDropdownState extends State<LanguageDropdown> {
  String _selectedLanguage = 'en';

  @override
  void initState() {
    super.initState();
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _selectedLanguage = prefs.getString('app_language') ?? 'en';
    });
  }

  Future<void> _changeLanguage(String value) async {
    setState(() {
      _selectedLanguage = value;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('app_language', value);
    await FlutterI18n.refresh(context, Locale(value));
    widget.onLocaleChanged?.call(Locale(value));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DropdownButtonHideUnderline(
      child: DropdownButton<String>(
        value: _selectedLanguage,
        icon: Icon(Icons.language, color: theme.colorScheme.primary),
        items: const [
          DropdownMenuItem(value: 'en', child: Text('English')),
          DropdownMenuItem(value: 'am', child: Text('አማርኛ')),
        ],
        onChanged: (value) {
          if (value != null) {
            _changeLanguage(value);
          }
        },
        dropdownColor: theme.scaffoldBackgroundColor,
      ),
    );
  }
} 