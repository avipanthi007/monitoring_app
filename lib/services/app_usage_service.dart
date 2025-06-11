import 'dart:async';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:monitoring_app/services/firebase_service.dart';

class AppUsageService {
  final List<String> _unwantedApps = [
    'com.instagram.android',
    'com.zhiliaoapp.musically', // TikTok
    'com.google.android.youtube',
  ];

  Timer? _periodicTimer;
  final _checkInterval = const Duration(minutes: 1);
  final Map<String, DateTime> _lastLoggedTime = {};
  final AppUsage _appUsage = AppUsage();

  void startMonitoring() {
    if (!Platform.isAndroid) {
      print('App usage monitoring is only available on Android');
      return;
    }

    _checkRunningApps();

    _periodicTimer = Timer.periodic(_checkInterval, (_) {
      _checkRunningApps();
    });
  }

  Future<void> _checkRunningApps() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(minutes: 1));

      final usageStats = await _appUsage.getAppUsage(startDate, endDate);

      for (final usage in usageStats) {
        if (_unwantedApps.contains(usage.packageName)) {
          final lastLogged = _lastLoggedTime[usage.packageName];
          final now = DateTime.now();

          if (lastLogged == null ||
              now.difference(lastLogged).inMinutes >= 15) {
            String appName = _getReadableAppName(usage.packageName);

            final firebaseService = await FirebaseService.instance;
            await firebaseService.logAppUsageEvent(appName);

            _lastLoggedTime[usage.packageName] = now;
          }
        }
      }
    } catch (e) {
      print('Error checking app usage: $e');
    }
  }

  String _getReadableAppName(String packageName) {
    switch (packageName) {
      case 'com.instagram.android':
        return 'Instagram';
      case 'com.zhiliaoapp.musically':
        return 'TikTok';
      case 'com.google.android.youtube':
        return 'YouTube';
      default:
        return packageName;
    }
  }

  void stopMonitoring() {
    _periodicTimer?.cancel();
  }
}
