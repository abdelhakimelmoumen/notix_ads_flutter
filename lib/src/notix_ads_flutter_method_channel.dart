import 'package:flutter/services.dart';

import 'notix_ad_event.dart';
import 'notix_ads_flutter_platform_interface.dart';

/// MethodChannel + EventChannel implementation of [NotixAdsFlutterPlatform].
class MethodChannelNotixAdsFlutter extends NotixAdsFlutterPlatform {
  final MethodChannel methodChannel =
      const MethodChannel('notix_ads_flutter/methods');

  final EventChannel eventChannel =
      const EventChannel('notix_ads_flutter/events');

  Stream<NotixAdEvent>? _adEventStream;

  @override
  Stream<NotixAdEvent> get onAdEvent {
    _adEventStream ??= eventChannel.receiveBroadcastStream().map(
          (dynamic event) => NotixAdEvent.fromMap(event as Map),
        );
    return _adEventStream!;
  }

  @override
  Future<void> initPush(String appId, String token) async {
    await methodChannel.invokeMethod<void>('initPush', {
      'appId': appId,
      'token': token,
    });
  }

  @override
  Future<void> loadInterstitial(String zoneId) async {
    await methodChannel.invokeMethod<void>('loadInterstitial', {
      'zoneId': zoneId,
    });
  }

  @override
  Future<bool> showInterstitial() async {
    final result = await methodChannel.invokeMethod<bool>('showInterstitial');
    return result ?? false;
  }

  @override
  Future<void> loadAppOpen(String zoneId) async {
    await methodChannel.invokeMethod<void>('loadAppOpen', {
      'zoneId': zoneId,
    });
  }

  @override
  Future<void> startAutoShowAppOpen() async {
    await methodChannel.invokeMethod<void>('startAutoShowAppOpen');
  }

  @override
  Future<void> stopAutoShowAppOpen() async {
    await methodChannel.invokeMethod<void>('stopAutoShowAppOpen');
  }
}
