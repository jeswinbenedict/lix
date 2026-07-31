import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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
            // Apple macOS Sonoma / iPadOS 18 Glass Sidebar
            Container(
              width: 104,
              decoration: BoxDecoration(
                color: AppTheme.surface.withAlpha(245),
                border: const Border(
                  right: BorderSide(color: AppTheme.border, width: 1),
                ),
                boxShadow: AppTheme.shadowSM,
              ),
              child: Column(
                children: [
                  const SizedBox(height: 24),
                  // App Brand Logo Badge
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      gradient: AppTheme.primaryGradient,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: AppTheme.shadowPrimary,
                    ),
                    child: const Center(
                      child: Text(
                        'L',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'LIX',
                    style: TextStyle(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 2.5,
                      fontSize: 11,
                      color: AppTheme.primary,
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Navigation Items List
                  Expanded(
                    child: ListView.builder(
                      itemCount: widget.destinations.length,
                      physics: const NeverScrollableScrollPhysics(),
                      itemBuilder: (context, index) {
                        final destination = widget.destinations[index];
                        final isSelected = index == widget.selectedIndex;

                        return _SidebarTile(
                          destination: destination,
                          isSelected: isSelected,
                          onTap: () {
                            HapticFeedback.lightImpact();
                            widget.onDestinationSelected(index);
                          },
                        );
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
            // Main App Body
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

    // Mobile Layout with Floating Glass Capsule Navbar
    return Scaffold(
      backgroundColor: AppTheme.background,
      body: Container(
        decoration: BoxDecoration(
          gradient: AppTheme.auroraBackgroundGradient,
        ),
        child: widget.body,
      ),
      bottomNavigationBar: Container(
        color: Colors.transparent,
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: SafeArea(
          child: Container(
            height: 66,
            decoration: BoxDecoration(
              color: AppTheme.surface.withAlpha(245),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
              border: Border.all(color: AppTheme.border, width: 1),
              boxShadow: AppTheme.shadowMD,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: List.generate(widget.destinations.length, (index) {
                final destination = widget.destinations[index];
                final isSelected = index == widget.selectedIndex;

                return Expanded(
                  child: _MobileNavTile(
                    destination: destination,
                    isSelected: isSelected,
                    onTap: () {
                      HapticFeedback.lightImpact();
                      widget.onDestinationSelected(index);
                    },
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Desktop Sidebar Tile Component with Tap Effects ────────────────
class _SidebarTile extends StatefulWidget {
  final AdaptiveDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _SidebarTile({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_SidebarTile> createState() => _SidebarTileState();
}

class _SidebarTileState extends State<_SidebarTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.92 : (widget.isSelected ? 1.05 : 1.0),
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          margin: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryLight
                : (_isPressed ? Colors.black.withAlpha(8) : Colors.transparent),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: widget.isSelected
                  ? AppTheme.primary.withAlpha(30)
                  : Colors.transparent,
              width: 1,
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: widget.isSelected ? 38 : 32,
                height: widget.isSelected ? 38 : 32,
                decoration: BoxDecoration(
                  gradient: widget.isSelected ? AppTheme.primaryGradient : null,
                  borderRadius: BorderRadius.circular(11),
                  boxShadow: widget.isSelected ? AppTheme.shadowSM : null,
                ),
                child: Center(
                  child: Icon(
                    widget.isSelected
                        ? widget.destination.selectedIcon
                        : widget.destination.icon,
                    color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
                    size: widget.isSelected ? 20 : 22,
                  ),
                ),
              ),
              const SizedBox(height: 6),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: widget.isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w600,
                  fontSize: 11,
                  letterSpacing: -0.2,
                ),
                child: Text(widget.destination.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Mobile Capsule Navbar Tile Component with Tap Effects ──────────
class _MobileNavTile extends StatefulWidget {
  final AdaptiveDestination destination;
  final bool isSelected;
  final VoidCallback onTap;

  const _MobileNavTile({
    required this.destination,
    required this.isSelected,
    required this.onTap,
  });

  @override
  State<_MobileNavTile> createState() => _MobileNavTileState();
}

class _MobileNavTileState extends State<_MobileNavTile> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: AnimatedScale(
        scale: _isPressed ? 0.90 : 1.0,
        duration: const Duration(milliseconds: 150),
        curve: Curves.easeOutCubic,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.symmetric(vertical: 8),
          decoration: BoxDecoration(
            color: widget.isSelected
                ? AppTheme.primaryLight
                : (_isPressed ? Colors.black.withAlpha(8) : Colors.transparent),
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: widget.isSelected ? AppTheme.primary : Colors.transparent,
                  shape: BoxShape.circle,
                  boxShadow: widget.isSelected ? AppTheme.shadowSM : null,
                ),
                child: Icon(
                  widget.isSelected
                      ? widget.destination.selectedIcon
                      : widget.destination.icon,
                  color: widget.isSelected ? Colors.white : AppTheme.textSecondary,
                  size: widget.isSelected ? 20 : 22,
                ),
              ),
              const SizedBox(height: 2),
              AnimatedDefaultTextStyle(
                duration: const Duration(milliseconds: 200),
                style: TextStyle(
                  color: widget.isSelected ? AppTheme.primary : AppTheme.textSecondary,
                  fontWeight: widget.isSelected ? FontWeight.w800 : FontWeight.w500,
                  fontSize: 10,
                  letterSpacing: -0.2,
                ),
                child: Text(widget.destination.label),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
