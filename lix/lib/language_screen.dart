import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'language_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});
  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen> {
  // ✅ Fixed: use singleton instead of orphan instance
  LanguageService get _lang => LanguageService.instance;

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';
  int _selectedTab = 0;

  static const List<String> _indianLanguages = [
    'Hindi',
    'Tamil',
    'Telugu',
    'Kannada',
    'Malayalam',
    'Bengali',
    'Marathi',
    'Gujarati',
    'Punjabi',
    'Odia',
    'Urdu',
    'Assamese',
    'Kashmiri',
    'Konkani',
    'Maithili',
    'Manipuri',
    'Nepali',
    'Sanskrit',
    'Santali',
    'Sindhi',
    'Bodo',
    'Dogri',
    'English',
  ];

  static const List<String> _foreignLanguages = [
    'Mandarin',
    'Spanish',
    'French',
    'Arabic',
    'Portuguese',
    'Russian',
    'Japanese',
    'German',
    'Korean',
    'Italian',
    'Turkish',
    'Dutch',
    'Polish',
    'Swedish',
    'Greek',
    'Hebrew',
    'Thai',
    'Vietnamese',
    'Indonesian',
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
        final hPad = AppTheme.horizontalPadding(context);
        return Scaffold(
          backgroundColor: AppTheme.background,
          body: Column(
            children: [
              // ── Header ───────────────────────────────────────
              Container(
                width: double.infinity,
                padding: EdgeInsets.fromLTRB(hPad, 56, hPad, 20),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  border: Border(bottom: BorderSide(color: AppTheme.border)),
                  boxShadow: AppTheme.shadowSM,
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            HapticFeedback.lightImpact();
                            Navigator.pop(context);
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTheme.background,
                              borderRadius: BorderRadius.circular(
                                AppTheme.radiusMD,
                              ),
                              border: Border.all(color: AppTheme.border),
                            ),
                            child: const Icon(
                              Icons.arrow_back_ios_new,
                              size: 16,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        const Spacer(),
                        Text(
                          _lang.translate('Language'),
                          style: TextStyle(
                            color: AppTheme.textPrimary,
                            fontSize: AppTheme.heading2(context),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        const SizedBox(width: 40),
                      ],
                    ),
                    SizedBox(height: AppTheme.sectionGap(context) * 0.6),
                    // Search bar
                    Container(
                      height: 44,
                      decoration: BoxDecoration(
                        color: AppTheme.background,
                        borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                        border: Border.all(color: AppTheme.border),
                      ),
                      child: TextField(
                        controller: _searchController,
                        style: TextStyle(
                          color: AppTheme.textPrimary,
                          fontSize: AppTheme.bodyRegular(context),
                        ),
                        decoration: InputDecoration(
                          hintText: 'Search language...',
                          hintStyle: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                          prefixIcon: const Icon(
                            Icons.search,
                            color: AppTheme.textSecondary,
                            size: 20,
                          ),
                          border: InputBorder.none,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12,
                          ),
                        ),
                        onChanged: (v) => setState(() => _searchQuery = v),
                      ),
                    ),
                    SizedBox(height: AppTheme.sectionGap(context) * 0.5),
                    // Tabs
                    Row(
                      children: [
                        _buildTab(context, 0, 'Indian'),
                        const SizedBox(width: 10),
                        _buildTab(context, 1, 'Foreign'),
                      ],
                    ),
                  ],
                ),
              ),

              // ── Language List ─────────────────────────────────
              Expanded(
                child: _filteredLanguages.isEmpty
                    ? Center(
                        child: Text(
                          'No language found',
                          style: TextStyle(
                            color: AppTheme.textSecondary,
                            fontSize: AppTheme.bodyRegular(context),
                          ),
                        ),
                      )
                    : ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.symmetric(
                          horizontal: hPad,
                          vertical: 12,
                        ),
                        itemCount: _filteredLanguages.length,
                        itemBuilder: (ctx, i) {
                          final language = _filteredLanguages[i];
                          final isSelected = _lang.language == language;
                          return GestureDetector(
                            onTap: () {
                              HapticFeedback.lightImpact();
                              _lang.setLanguage(language);
                            },
                            child: Container(
                              margin: const EdgeInsets.only(bottom: 10),
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                                vertical: 14,
                              ),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTheme.primary.withValues(alpha: 0.08)
                                    : AppTheme.surface,
                                borderRadius: BorderRadius.circular(
                                  AppTheme.radiusMD,
                                ),
                                border: Border.all(
                                  color: isSelected
                                      ? AppTheme.primary.withValues(alpha: 0.5)
                                      : AppTheme.border,
                                  width: isSelected ? 1.5 : 1,
                                ),
                                boxShadow: AppTheme.shadowSM,
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 36,
                                    height: 36,
                                    decoration: BoxDecoration(
                                      color: isSelected
                                          ? AppTheme.primary.withValues(
                                              alpha: 0.15,
                                            )
                                          : AppTheme.background,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: isSelected
                                            ? AppTheme.primary.withValues(
                                                alpha: 0.4,
                                              )
                                            : AppTheme.border,
                                      ),
                                    ),
                                    child: Center(
                                      child: Text(
                                        language[0],
                                        style: TextStyle(
                                          color: isSelected
                                              ? AppTheme.primary
                                              : AppTheme.textSecondary,
                                          fontWeight: FontWeight.bold,
                                          fontSize: AppTheme.bodyRegular(
                                            context,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Text(
                                      language,
                                      style: TextStyle(
                                        color: isSelected
                                            ? AppTheme.primary
                                            : AppTheme.textPrimary,
                                        fontSize: AppTheme.bodyRegular(context),
                                        fontWeight: isSelected
                                            ? FontWeight.bold
                                            : FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                  if (isSelected)
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 10,
                                        vertical: 4,
                                      ),
                                      decoration: BoxDecoration(
                                        color: AppTheme.primary.withValues(
                                          alpha: 0.12,
                                        ),
                                        borderRadius: BorderRadius.circular(
                                          AppTheme.radiusFull,
                                        ),
                                      ),
                                      child: Text(
                                        'Selected',
                                        style: TextStyle(
                                          color: AppTheme.primary,
                                          fontSize: AppTheme.caption(context),
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                    )
                                  else
                                    const Icon(
                                      Icons.chevron_right,
                                      color: AppTheme.textSecondary,
                                      size: 20,
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
        );
      },
    );
  }

  Widget _buildTab(BuildContext context, int index, String label) {
    final isActive = _selectedTab == index;
    return Expanded(
      child: GestureDetector(
        onTap: () {
          HapticFeedback.lightImpact();
          setState(() {
            _selectedTab = index;
            _searchQuery = '';
            _searchController.clear();
          });
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isActive ? AppTheme.primary : AppTheme.background,
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
            border: Border.all(
              color: isActive ? AppTheme.primary : AppTheme.border,
            ),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: isActive ? Colors.white : AppTheme.textSecondary,
              fontWeight: FontWeight.bold,
              fontSize: AppTheme.bodyRegular(context),
            ),
          ),
        ),
      ),
    );
  }
}
