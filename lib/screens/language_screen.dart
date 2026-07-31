import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../core/responsive.dart';
import '../services/language_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  LanguageService get _lang => LanguageService.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  static const List<String> _indianLanguages = [
    'Hindi', 'Tamil', 'Telugu', 'Kannada', 'Malayalam', 'Bengali', 'Marathi',
    'Gujarati', 'Punjabi', 'Odia', 'Urdu', 'Assamese', 'English'
  ];

  static const List<String> _foreignLanguages = [
    'Mandarin', 'Spanish', 'French', 'Arabic', 'Portuguese', 'Russian',
    'Japanese', 'German', 'Korean', 'Italian', 'Turkish', 'Dutch', 'Polish',
    'Swedish', 'Greek', 'Hebrew', 'Thai', 'Vietnamese', 'Indonesian'
  ];

  List<String> get _filteredLanguages {
    final list = _selectedTab == 0 ? _indianLanguages : _foreignLanguages;
    if (_searchQuery.isEmpty) return list;
    return list
        .where((l) => l.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: _lang,
      builder: (context, _) {
        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.surface,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary, size: 18),
            ),
            title: Text(
              _lang.translate('Language'),
              style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold),
            ),
          ),
          body: CenteredContent(
            maxWidth: 800,
            child: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: TextField(
                    controller: _searchController,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w500,
                    ),
                    decoration: InputDecoration(
                      hintText: _lang.translate('Search language...'),
                      hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 15),
                      prefixIcon: const Icon(Icons.search_rounded, color: AppTheme.primary, size: 22),
                      filled: true,
                      fillColor: Colors.white,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: const BorderSide(color: AppTheme.border, width: 1),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        borderSide: const BorderSide(color: AppTheme.primary, width: 1.8),
                      ),
                    ),
                    onChanged: (v) => setState(() => _searchQuery = v),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ChoiceChip(
                      label: Text(_lang.translate('Indian')),
                      selected: _selectedTab == 0,
                      onSelected: (sel) => setState(() => _selectedTab = 0),
                    ),
                    const SizedBox(width: 12),
                    ChoiceChip(
                      label: Text(_lang.translate('Foreign')),
                      selected: _selectedTab == 1,
                      onSelected: (sel) => setState(() => _selectedTab = 1),
                    ),
                  ],
                ),
                Expanded(
                  child: ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: _filteredLanguages.length,
                    itemBuilder: (context, index) {
                      final language = _filteredLanguages[index];
                      final isSelected = _lang.language == language;
                      return ListTile(
                        title: Text(language, style: TextStyle(fontWeight: isSelected ? FontWeight.bold : FontWeight.normal)),
                        trailing: isSelected ? const Icon(Icons.check_circle, color: AppTheme.primary) : null,
                        onTap: () => _lang.setLanguage(language),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
