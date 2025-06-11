import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:monitoring_app/services/firebase_service.dart';

class BatteryService {
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  bool _hasLoggedLowBattery = false;
  final int _lowBatteryThreshold = 15;

  void startMonitoring() async {
    // Initial check
    await _checkBatteryLevel();

    // Listen for battery state changes
    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      _,
    ) async {
      await _checkBatteryLevel();
    });

    // Set up a periodic check every 5 minutes
    Timer.periodic(const Duration(minutes: 5), (_) async {
      await _checkBatteryLevel();
    });
  }

  Future<void> _checkBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;

    // If battery is below threshold and we haven't logged it yet
    if (batteryLevel <= _lowBatteryThreshold && !_hasLoggedLowBattery) {
      final firebaseService = await FirebaseService.instance;
      await firebaseService.logBatteryEvent(batteryLevel);
      _hasLoggedLowBattery = true;
    }
    // Reset the flag if battery level goes back above threshold + 5%
    else if (batteryLevel > _lowBatteryThreshold + 5) {
      _hasLoggedLowBattery = false;
    }
  }

  void stopMonitoring() {
    _batteryStateSubscription?.cancel();
  }
}
