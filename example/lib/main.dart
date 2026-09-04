import 'package:flutter/material.dart';
import 'package:notix_ads_flutter/notix_ads_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1) Push notifications (optional) — do this once, as early as possible.
  await NotixAdsFlutter.initPush(
    appId: 'YOUR_NOTIX_APP_ID',
    token: 'YOUR_NOTIX_TOKEN',
  );

  // 2) Start preloading an interstitial so it's ready when you need it.
  await NotixAdsFlutter.loadInterstitial(zoneId: 'YOUR_INTERSTITIAL_ZONE_ID');

  // 3) Preload + auto-show App Open ads whenever the app is foregrounded.
  await NotixAdsFlutter.loadAppOpen(zoneId: 'YOUR_APP_OPEN_ZONE_ID');
  await NotixAdsFlutter.startAutoShowAppOpen();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  void initState() {
    super.initState();
    // Optional: listen to ad lifecycle events for analytics/logging.
    NotixAdsFlutter.onAdEvent.listen((event) {
      debugPrint('Monetag event: $event');
    });
  }

  Future<void> _showInterstitial() async {
    final shown = await NotixAdsFlutter.showInterstitial();
    if (!shown && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No interstitial ready yet')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Monetag Flutter example')),
        body: Center(
          child: ElevatedButton(
            onPressed: _showInterstitial,
            child: const Text('Show Interstitial'),
          ),
        ),
      ),
    );
  }
}
