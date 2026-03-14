import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_theme.dart';
import 'language_service.dart';

class LanguageScreen extends StatefulWidget {
  const LanguageScreen({super.key});

  @override
  State<LanguageScreen> createState() => _LanguageScreenState();
}

class _LanguageScreenState extends State<LanguageScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  String _selected = 'English';
  String _search = '';
  final TextEditingController _searchCtrl = TextEditingController();
  final LanguageService _langService = LanguageService(); // ✅ single instance

  // ── 22 Indian scheduled languages ─────────────────────
  final List<Map<String, String>> _indianLanguages = const [
    {'name': 'Hindi', 'native': 'हिन्दी', 'flag': '🇮🇳'},
    {'name': 'Tamil', 'native': 'தமிழ்', 'flag': '🇮🇳'},
    {'name': 'Telugu', 'native': 'తెలుగు', 'flag': '🇮🇳'},
    {'name': 'Kannada', 'native': 'ಕನ್ನಡ', 'flag': '🇮🇳'},
    {'name': 'Malayalam', 'native': 'മലയാളം', 'flag': '🇮🇳'},
    {'name': 'Bengali', 'native': 'বাংলা', 'flag': '🇮🇳'},
    {'name': 'Marathi', 'native': 'मराठी', 'flag': '🇮🇳'},
    {'name': 'Gujarati', 'native': 'ગુજરાતી', 'flag': '🇮🇳'},
    {'name': 'Punjabi', 'native': 'ਪੰਜਾਬੀ', 'flag': '🇮🇳'},
    {'name': 'Odia', 'native': 'ଓଡ଼ିଆ', 'flag': '🇮🇳'},
    {'name': 'Urdu', 'native': 'اردو', 'flag': '🇮🇳'},
    {'name': 'Assamese', 'native': 'অসমীয়া', 'flag': '🇮🇳'},
    {'name': 'Kashmiri', 'native': 'कॉशुर', 'flag': '🇮🇳'},
    {'name': 'Konkani', 'native': 'कोंकणी', 'flag': '🇮🇳'},
    {'name': 'Maithili', 'native': 'मैथिली', 'flag': '🇮🇳'},
    {'name': 'Manipuri', 'native': 'মৈতৈলোন্', 'flag': '🇮🇳'},
    {'name': 'Nepali', 'native': 'नेपाली', 'flag': '🇮🇳'},
    {'name': 'Sanskrit', 'native': 'संस्कृतम्', 'flag': '🇮🇳'},
    {'name': 'Santali', 'native': 'ᱥᱟᱱᱛᱟᱲᱤ', 'flag': '🇮🇳'},
    {'name': 'Sindhi', 'native': 'سنڌي', 'flag': '🇮🇳'},
    {'name': 'Bodo', 'native': 'बर\'', 'flag': '🇮🇳'},
    {'name': 'Dogri', 'native': 'डोगरी', 'flag': '🇮🇳'},
  ];

  // ── Major foreign languages ────────────────────────────
  final List<Map<String, String>> _foreignLanguages = const [
    {'name': 'English', 'native': 'English', 'flag': '🇬🇧'},
    {'name': 'Mandarin', 'native': '普通话', 'flag': '🇨🇳'},
    {'name': 'Spanish', 'native': 'Español', 'flag': '🇪🇸'},
    {'name': 'French', 'native': 'Français', 'flag': '🇫🇷'},
    {'name': 'Arabic', 'native': 'العربية', 'flag': '🇸🇦'},
    {'name': 'Portuguese', 'native': 'Português', 'flag': '🇵🇹'},
    {'name': 'Russian', 'native': 'Русский', 'flag': '🇷🇺'},
    {'name': 'Japanese', 'native': '日本語', 'flag': '🇯🇵'},
    {'name': 'German', 'native': 'Deutsch', 'flag': '🇩🇪'},
    {'name': 'Korean', 'native': '한국어', 'flag': '🇰🇷'},
    {'name': 'Italian', 'native': 'Italiano', 'flag': '🇮🇹'},
    {'name': 'Turkish', 'native': 'Türkçe', 'flag': '🇹🇷'},
    {'name': 'Dutch', 'native': 'Nederlands', 'flag': '🇳🇱'},
    {'name': 'Polish', 'native': 'Polski', 'flag': '🇵🇱'},
    {'name': 'Swedish', 'native': 'Svenska', 'flag': '🇸🇪'},
    {'name': 'Greek', 'native': 'Ελληνικά', 'flag': '🇬🇷'},
    {'name': 'Hebrew', 'native': 'עברית', 'flag': '🇮🇱'},
    {'name': 'Thai', 'native': 'ภาษาไทย', 'flag': '🇹🇭'},
    {'name': 'Vietnamese', 'native': 'Tiếng Việt', 'flag': '🇻🇳'},
    {'name': 'Indonesian', 'native': 'Bahasa Indonesia', 'flag': '🇮🇩'},
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    // ✅ Read current language directly from the singleton — no async needed
    _selected = _langService.language;
  }

  Future<void> _selectLanguage(String name) async {
    HapticFeedback.lightImpact();
    await _langService.setLanguage(name); // ✅ notifies ALL listeners app-wide
    setState(() => _selected = name); // ✅ updates tick mark on this screen
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('🌐 ${_langService.translate('Language')}: $name'),
          backgroundColor: AppTheme.primary,
          duration: const Duration(seconds: 1),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          ),
        ),
      );
    }
  }

  List<Map<String, String>> _filterList(List<Map<String, String>> list) {
    if (_search.isEmpty) return list;
    return list
        .where(
          (l) =>
              l['name']!.toLowerCase().contains(_search.toLowerCase()) ||
              l['native']!.toLowerCase().contains(_search.toLowerCase()),
        )
        .toList();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // ✅ ListenableBuilder — this screen rebuilds whenever language changes
    return ListenableBuilder(
      listenable: _langService,
      builder: (context, _) {
        final indianFiltered = _filterList(_indianLanguages);
        final foreignFiltered = _filterList(_foreignLanguages);

        return Scaffold(
          backgroundColor: AppTheme.background,
          appBar: AppBar(
            backgroundColor: AppTheme.background,
            elevation: 0,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.border),
                ),
                child: const Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: AppTheme.textPrimary,
                  size: 22,
                ),
              ),
            ),
            title: Text(
              _langService.translate('Language'), // ✅ translated
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
              ),
            ),
            centerTitle: true,
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.primary,
              labelColor: AppTheme.primary,
              unselectedLabelColor: AppTheme.textSecondary,
              labelStyle: const TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
              tabs: [
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🇮🇳 '),
                      Text(_langService.translate('Indian')), // ✅ translated
                    ],
                  ),
                ),
                Tab(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('🌐 '),
                      Text(_langService.translate('Foreign')), // ✅ translated
                    ],
                  ),
                ),
              ],
            ),
          ),
          body: Column(
            children: [
              // ── Search Bar ──────────────────────────────
              Padding(
                padding: EdgeInsets.fromLTRB(
                  AppTheme.horizontalPadding(context),
                  14,
                  AppTheme.horizontalPadding(context),
                  8,
                ),
                child: Container(
                  decoration: BoxDecoration(
                    color: AppTheme.surface,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(color: AppTheme.border),
                  ),
                  child: TextField(
                    controller: _searchCtrl,
                    onChanged: (v) => setState(() => _search = v),
                    style: const TextStyle(color: AppTheme.textPrimary),
                    decoration: InputDecoration(
                      hintText: _langService.translate(
                        'Search language...',
                      ), // ✅
                      hintStyle: const TextStyle(color: AppTheme.textSecondary),
                      prefixIcon: const Icon(
                        Icons.search_rounded,
                        color: AppTheme.textSecondary,
                        size: 20,
                      ),
                      suffixIcon: _search.isNotEmpty
                          ? GestureDetector(
                              onTap: () {
                                _searchCtrl.clear();
                                setState(() => _search = '');
                              },
                              child: const Icon(
                                Icons.close_rounded,
                                color: AppTheme.textSecondary,
                                size: 18,
                              ),
                            )
                          : null,
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                    ),
                  ),
                ),
              ),

              // ── Currently selected banner ────────────────
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppTheme.horizontalPadding(context),
                ),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primary.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMD),
                    border: Border.all(
                      color: AppTheme.primary.withOpacity(0.25),
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.check_circle_rounded,
                        color: AppTheme.primary,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '${_langService.translate('Selected')}: ', // ✅
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: AppTheme.caption(context),
                        ),
                      ),
                      Text(
                        _selected,
                        style: TextStyle(
                          color: AppTheme.primary,
                          fontSize: AppTheme.caption(context),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 8),

              // ── Tab content ──────────────────────────────
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    _buildList(indianFiltered),
                    _buildList(foreignFiltered),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildList(List<Map<String, String>> list) {
    if (list.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off_rounded,
              size: 52,
              color: AppTheme.textSecondary.withOpacity(0.3),
            ),
            const SizedBox(height: 12),
            Text(
              _langService.translate('No language found'), // ✅
              style: TextStyle(
                color: AppTheme.textSecondary,
                fontSize: AppTheme.bodyRegular(context),
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: EdgeInsets.symmetric(
        horizontal: AppTheme.horizontalPadding(context),
        vertical: 8,
      ),
      itemCount: list.length,
      itemBuilder: (_, i) => _buildTile(list[i]),
    );
  }

  Widget _buildTile(Map<String, String> lang) {
    final isSelected = _selected == lang['name'];

    return GestureDetector(
      onTap: () => _selectLanguage(lang['name']!),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: isSelected
              ? AppTheme.primary.withOpacity(0.08)
              : AppTheme.surface,
          borderRadius: BorderRadius.circular(AppTheme.radiusMD),
          border: Border.all(
            color: isSelected
                ? AppTheme.primary.withOpacity(0.4)
                : AppTheme.border,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: AppTheme.shadowSM,
        ),
        child: Row(
          children: [
            Text(lang['flag']!, style: const TextStyle(fontSize: 26)),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    lang['name']!,
                    style: TextStyle(
                      color: AppTheme.textPrimary,
                      fontSize: AppTheme.bodyRegular(context),
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    lang['native']!,
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: AppTheme.caption(context),
                    ),
                  ),
                ],
              ),
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: isSelected ? AppTheme.primary : Colors.transparent,
                border: Border.all(
                  color: isSelected ? AppTheme.primary : AppTheme.border,
                  width: 2,
                ),
              ),
              child: isSelected
                  ? const Icon(
                      Icons.check_rounded,
                      color: Colors.white,
                      size: 13,
                    )
                  : null,
            ),
          ],
        ),
      ),
    );
  }
}
