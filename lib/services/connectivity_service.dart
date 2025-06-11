import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:monitoring_app/services/firebase_service.dart';

class ConnectivityService {
  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;
  bool _wasConnected = true;

  void startMonitoring() async {
    // Check initial connectivity
    await _checkConnectivity();

    // Listen for connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((
      results,
    ) async {
      await _handleConnectivityChange(results.first);
    });
  }

  Future<void> _checkConnectivity() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    await _handleConnectivityChange(connectivityResults.first);
  }

  Future<void> _handleConnectivityChange(ConnectivityResult result) async {
    final bool isConnected = result != ConnectivityResult.none;

    // If we were connected before but now disconnected
    if (_wasConnected && !isConnected) {
      final firebaseService = await FirebaseService.instance;
      await firebaseService.logNetworkEvent();
    }

    // Update the connection state
    _wasConnected = isConnected;
  }

  void stopMonitoring() {
    _connectivitySubscription?.cancel();
  }
}
