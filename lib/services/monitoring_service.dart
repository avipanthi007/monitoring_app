import 'dart:io';
import 'package:workmanager/workmanager.dart';
import 'package:monitoring_app/services/battery_service.dart';
import 'package:monitoring_app/services/connectivity_service.dart';
import 'package:monitoring_app/services/app_usage_service.dart';
import 'package:monitoring_app/services/firebase_service.dart';

const String monitoringTaskName = 'com.monitoring_app.monitoring';

@pragma('vm:entry-point')
void callbackDispatcher() {
  Workmanager().executeTask((task, inputData) async {
    if (task == monitoringTaskName) {
      await FirebaseService.instance;

      final monitoringService = MonitoringService();
      await monitoringService.startMonitoring();

      // Allow some time for monitoring to run
      await Future.delayed(const Duration(seconds: 30));

      // Stop monitoring to clean up resources
      monitoringService.stopMonitoring();
    }
    return true;
  });
}

class MonitoringService {
  final BatteryService _batteryService = BatteryService();
  final ConnectivityService _connectivityService = ConnectivityService();
  final AppUsageService _appUsageService = AppUsageService();
  bool _isRunning = false;

  // Initialize background tasks
  Future<void> initialize() async {
    await Workmanager().initialize(callbackDispatcher, isInDebugMode: false);

    // Register periodic task
    await Workmanager().registerPeriodicTask(
      'monitoring-task',
      monitoringTaskName,
      frequency: const Duration(minutes: 15),
      constraints: Constraints(
        networkType: NetworkType.connected,
        requiresBatteryNotLow: false,
      ),
    );
  }

  Future<void> startMonitoring() async {
    if (_isRunning) return;

    await FirebaseService.instance;

    _batteryService.startMonitoring();
    _connectivityService.startMonitoring();

    if (Platform.isAndroid) {
      _appUsageService.startMonitoring();
    }

    _isRunning = true;
  }

  void stopMonitoring() {
    if (!_isRunning) return;

    _batteryService.stopMonitoring();
    _connectivityService.stopMonitoring();

    if (Platform.isAndroid) {
      _appUsageService.stopMonitoring();
    }

    _isRunning = false;
  }
}
