import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:monitoring_app/services/monitoring_service.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Initialize monitoring service
  final monitoringService = MonitoringService();
  await monitoringService.initialize();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Phone Monitoring App',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MonitoringHomePage(title: 'Phone Monitoring'),
    );
  }
}

class MonitoringHomePage extends StatefulWidget {
  const MonitoringHomePage({super.key, required this.title});

  final String title;

  @override
  State<MonitoringHomePage> createState() => _MonitoringHomePageState();
}

class _MonitoringHomePageState extends State<MonitoringHomePage> {
  final MonitoringService _monitoringService = MonitoringService();
  bool _isMonitoring = false;

  @override
  void initState() {
    super.initState();
    _startMonitoring();
  }

  Future<void> _startMonitoring() async {
    await _monitoringService.startMonitoring();
    setState(() {
      _isMonitoring = true;
    });
  }

  void _stopMonitoring() {
    _monitoringService.stopMonitoring();
    setState(() {
      _isMonitoring = false;
    });
  }

  @override
  void dispose() {
    _stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(
              _isMonitoring ? Icons.visibility : Icons.visibility_off,
              size: 80,
              color: _isMonitoring ? Colors.green : Colors.red,
            ),
            const SizedBox(height: 20),
            Text(
              _isMonitoring ? 'Monitoring Active' : 'Monitoring Inactive',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 40),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  MonitoringFeatureItem(
                    icon: Icons.battery_alert,
                    title: 'Battery Monitoring',
                    description: 'Logs when battery drops below 15%',
                  ),
                  SizedBox(height: 16),
                  MonitoringFeatureItem(
                    icon: Icons.signal_wifi_off,
                    title: 'Network Monitoring',
                    description: 'Logs when device disconnects from network',
                  ),
                  SizedBox(height: 16),
                  MonitoringFeatureItem(
                    icon: Icons.app_blocking,
                    title: 'App Usage Monitoring',
                    description: 'Logs when unwanted apps are opened',
                    androidOnly: true,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
        tooltip: _isMonitoring ? 'Stop Monitoring' : 'Start Monitoring',
        child: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
      ),
    );
  }
}

class MonitoringFeatureItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final bool androidOnly;

  const MonitoringFeatureItem({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.androidOnly = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 24, color: Theme.of(context).colorScheme.primary),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(description, style: const TextStyle(fontSize: 14)),
              if (androidOnly)
                const Text(
                  '(Android Only)',
                  style: TextStyle(
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                    color: Colors.grey,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }
}
