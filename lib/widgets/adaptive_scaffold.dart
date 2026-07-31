import 'package:flutter/material.dart';
import '../core/responsive.dart';
import '../core/app_theme.dart';

class AdaptiveScaffold extends StatefulWidget {
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<AdaptiveDestination> destinations;
  final Widget body;

  const AdaptiveScaffold({
    super.key,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.body,
  });

  @override
  State<AdaptiveScaffold> createState() => _AdaptiveScaffoldState();
}

class AdaptiveDestination {
  final String label;
  final IconData icon;
  final IconData selectedIcon;

  const AdaptiveDestination({
    required this.label,
    required this.icon,
    required this.selectedIcon,
  });
}

class _AdaptiveScaffoldState extends State<AdaptiveScaffold> {
  @override
  Widget build(BuildContext context) {
    final isDesktop = Responsive.isDesktop(context) || Responsive.isTablet(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor: AppTheme.background,
        body: Row(
          children: [
            Container(
              decoration: const BoxDecoration(
                color: AppTheme.surface,
                border: Border(right: BorderSide(color: AppTheme.border, width: 1)),
              ),
              child: NavigationRail(
                selectedIndex: widget.selectedIndex,
                onDestinationSelected: widget.onDestinationSelected,
                labelType: NavigationRailLabelType.all,
                backgroundColor: AppTheme.surface,
                indicatorColor: AppTheme.primaryLight,
                selectedIconTheme: const IconThemeData(color: AppTheme.primary, size: 26),
                unselectedIconTheme: const IconThemeData(color: AppTheme.textSecondary, size: 22),
                selectedLabelTextStyle: const TextStyle(
                  color: AppTheme.primary,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 24.0),
                  child: Column(
                    children: [
                      Container(
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          gradient: AppTheme.primaryGradient,
                          shape: BoxShape.circle,
                          boxShadow: AppTheme.shadowPrimary,
                        ),
                        child: const Center(
                          child: Text(
                            'L',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'LIX',
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          letterSpacing: 2.0,
                          fontSize: 11,
                          color: AppTheme.primary,
                        ),
                      ),
                    ],
                  ),
                ),
                destinations: widget.destinations.map((d) {
                  return NavigationRailDestination(
                    icon: Icon(d.icon),
                    selectedIcon: Icon(d.selectedIcon),
                    label: Text(d.label),
                  );
                }).toList(),
              ),
            ),
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  gradient: AppTheme.auroraBackgroundGradient,
                ),
                child: widget.body,
              ),
            ),
          ],
        ),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.auroraBackgroundGradient,
        ),
        child: widget.body,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppTheme.surface,
          border: Border(top: BorderSide(color: AppTheme.border, width: 1)),
        ),
        child: BottomNavigationBar(
          currentIndex: widget.selectedIndex,
          onTap: widget.onDestinationSelected,
          type: BottomNavigationBarType.fixed,
          elevation: 0,
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: AppTheme.textSecondary,
          backgroundColor: AppTheme.surface,
          selectedLabelStyle: const TextStyle(fontWeight: FontWeight.w700, fontSize: 11),
          unselectedLabelStyle: const TextStyle(fontWeight: FontWeight.w500, fontSize: 11),
          items: widget.destinations.map((d) {
            return BottomNavigationBarItem(
              icon: Icon(d.icon),
              activeIcon: Icon(d.selectedIcon),
              label: d.label,
            );
          }).toList(),
        ),
      ),
    );
  }
}
