import 'dart:async';
import 'package:battery_plus/battery_plus.dart';
import 'package:monitoring_app/services/firebase_service.dart';

class BatteryService {
  final Battery _battery = Battery();
  StreamSubscription<BatteryState>? _batteryStateSubscription;
  bool _hasLoggedLowBattery = false;
  final int _lowBatteryThreshold = 15;

  void startMonitoring() async {
    await _checkBatteryLevel();

    _batteryStateSubscription = _battery.onBatteryStateChanged.listen((
      _,
    ) async {
      await _checkBatteryLevel();
    });

    Timer.periodic(const Duration(minutes: 5), (_) async {
      await _checkBatteryLevel();
    });
  }

  Future<void> _checkBatteryLevel() async {
    final batteryLevel = await _battery.batteryLevel;

    if (batteryLevel <= _lowBatteryThreshold && !_hasLoggedLowBattery) {
      final firebaseService = await FirebaseService.instance;
      await firebaseService.logBatteryEvent(batteryLevel);
      _hasLoggedLowBattery = true;
    }
    else if (batteryLevel > _lowBatteryThreshold + 5) {
      _hasLoggedLowBattery = false;
    }
  }

  void stopMonitoring() {
    _batteryStateSubscription?.cancel();
  }
}
