import 'package:flutter/material.dart';
import '../core/app_theme.dart';
import '../services/connectivity_service.dart';

/// Animated offline banner that slides in when device loses internet connectivity
class OfflineBanner extends StatelessWidget {
  const OfflineBanner({super.key});

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: ConnectivityService.instance,
      builder: (context, _) {
        final isOnline = ConnectivityService.instance.isOnline;

        return AnimatedCrossFade(
          duration: const Duration(milliseconds: 300),
          crossFadeState: isOnline ? CrossFadeState.showFirst : CrossFadeState.showSecond,
          firstChild: const SizedBox.shrink(),
          secondChild: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            decoration: BoxDecoration(
              color: AppTheme.error.withAlpha(230),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.error.withAlpha(50),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.wifi_off_rounded, color: Colors.white, size: 16),
                SizedBox(width: 8),
                Text(
                  'Offline Mode — Showing Cached Content',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.2,
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
