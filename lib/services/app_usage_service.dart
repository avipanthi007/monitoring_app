import 'dart:async';
import 'dart:io';
import 'package:app_usage/app_usage.dart';
import 'package:monitoring_app/services/firebase_service.dart';

class AppUsageService {
  final List<String> unwantedApps = [
    'com.instagram.android',
    'com.zhiliaoapp.musically',
    'com.google.android.youtube',
  ];

  Timer? periodicTimer;
  final checkInterval = const Duration(minutes: 1);
  final Map<String, DateTime> lastLoggedTime = {};
  final AppUsage appUsage = AppUsage();

  void startMonitoring() {
    if (!Platform.isAndroid) {
      print('App usage monitoring is only available on Android');
      return;
    }
    checkRunningApps();
    periodicTimer = Timer.periodic(checkInterval, (_) {
      checkRunningApps();
    });
  }

  Future<void> checkRunningApps() async {
    try {
      final endDate = DateTime.now();
      final startDate = endDate.subtract(const Duration(minutes: 1));
      final usageStats = await appUsage.getAppUsage(startDate, endDate);
      for (final usage in usageStats) {
        if (unwantedApps.contains(usage.packageName)) {
          final lastLogged = lastLoggedTime[usage.packageName];
          final now = DateTime.now();
          if (lastLogged == null ||
              now.difference(lastLogged).inMinutes >= 15) {
            String appName = getReadableAppName(usage.packageName);
            final firebaseService = await FirebaseService.instance;
            await firebaseService.logAppUsageEvent(appName);
            lastLoggedTime[usage.packageName] = now;
          }
        }
      }
    } catch (e) {
      print('Error checking app usage: \$e');
    }
  }

  String getReadableAppName(String packageName) {
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
    periodicTimer?.cancel();
  }
}
