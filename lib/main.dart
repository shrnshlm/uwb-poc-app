import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const UwbPocApp());
}

class UwbPocApp extends StatelessWidget {
  const UwbPocApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'UWB POC',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const UwbHomePage(title: 'UWB Proof of Concept'),
    );
  }
}

class UwbHomePage extends StatefulWidget {
  const UwbHomePage({super.key, required this.title});

  final String title;

  @override
  State<UwbHomePage> createState() => _UwbHomePageState();
}

class _UwbHomePageState extends State<UwbHomePage> {
  static const platform = MethodChannel('com.uwbpoc/uwb');

  String _status = 'Not started';
  String _distance = 'N/A';
  String _direction = 'N/A';
  bool _isScanning = false;

  Future<void> _checkUwbSupport() async {
    try {
      final bool isSupported = await platform.invokeMethod('checkUwbSupport');
      setState(() {
        _status = isSupported ? 'UWB is supported on this device' : 'UWB is NOT supported';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error: ${e.message}';
      });
    }
  }

  Future<void> _startUwbSession() async {
    try {
      await platform.invokeMethod('startUwbSession');
      setState(() {
        _isScanning = true;
        _status = 'UWB session started';
      });

      // Listen for UWB updates
      platform.setMethodCallHandler((call) async {
        if (call.method == 'onDistanceUpdate') {
          setState(() {
            _distance = '${call.arguments['distance']} meters';
            _direction = call.arguments['direction'] ?? 'N/A';
          });
        }
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error starting session: ${e.message}';
      });
    }
  }

  Future<void> _stopUwbSession() async {
    try {
      await platform.invokeMethod('stopUwbSession');
      setState(() {
        _isScanning = false;
        _status = 'UWB session stopped';
        _distance = 'N/A';
        _direction = 'N/A';
      });
    } on PlatformException catch (e) {
      setState(() {
        _status = 'Error stopping session: ${e.message}';
      });
    }
  }

  @override
  void initState() {
    super.initState();
    _checkUwbSupport();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Status',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text(_status),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Measurements',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 8),
                    Text('Distance: $_distance'),
                    Text('Direction: $_direction'),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _checkUwbSupport,
              child: const Text('Check UWB Support'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isScanning ? null : _startUwbSession,
              child: const Text('Start UWB Session'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: _isScanning ? _stopUwbSession : null,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Stop UWB Session'),
            ),
          ],
        ),
      ),
    );
  }
}
