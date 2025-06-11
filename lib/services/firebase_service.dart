import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:intl/intl.dart';

class FirebaseService {
  static FirebaseService? _instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  FirebaseService._();

  static Future<FirebaseService> get instance async {
    if (_instance == null) {
      await Firebase.initializeApp();
      _instance = FirebaseService._();
    }
    return _instance!;
  }

  Future<void> logBatteryEvent(int batteryLevel) async {
    try {
      await _firestore.collection('monitoring_logs').add({
        'event': 'Battery Low',
        'batteryLevel': batteryLevel,
        'timestamp': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging battery event: $e');
    }
  }

  Future<void> logNetworkEvent() async {
    try {
      await _firestore.collection('monitoring_logs').add({
        'event': 'Network Disconnected',
        'timestamp': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging network event: $e');
    }
  }

  Future<void> logAppUsageEvent(String appName) async {
    try {
      await _firestore.collection('monitoring_logs').add({
        'event': 'Unwanted App Opened',
        'appName': appName,
        'timestamp': DateFormat("yyyy-MM-dd'T'HH:mm:ss").format(DateTime.now()),
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error logging app usage event: $e');
    }
  }
}
