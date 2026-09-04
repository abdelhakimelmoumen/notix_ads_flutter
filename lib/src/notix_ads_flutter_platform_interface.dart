import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'notix_ad_event.dart';
import 'notix_ads_flutter_method_channel.dart';

/// The interface that implementations of notix_ads_flutter must implement.
///
/// Platform implementations should extend this class rather than implement
/// it, so new methods added here don't break existing implementations.
abstract class NotixAdsFlutterPlatform extends PlatformInterface {
  NotixAdsFlutterPlatform() : super(token: _token);

  static final Object _token = Object();

  static NotixAdsFlutterPlatform _instance = MethodChannelNotixAdsFlutter();

  /// The default instance used by [NotixAdsFlutter]. Defaults to
  /// [MethodChannelNotixAdsFlutter].
  static NotixAdsFlutterPlatform get instance => _instance;

  static set instance(NotixAdsFlutterPlatform newInstance) {
    PlatformInterface.verifyToken(newInstance, _token);
    _instance = newInstance;
  }

  Stream<NotixAdEvent> get onAdEvent {
    throw UnimplementedError('onAdEvent has not been implemented.');
  }

  Future<void> initPush(String appId, String token) {
    throw UnimplementedError('initPush() has not been implemented.');
  }

  Future<void> loadInterstitial(String zoneId) {
    throw UnimplementedError('loadInterstitial() has not been implemented.');
  }

  Future<bool> showInterstitial() {
    throw UnimplementedError('showInterstitial() has not been implemented.');
  }

  Future<void> loadAppOpen(String zoneId) {
    throw UnimplementedError('loadAppOpen() has not been implemented.');
  }

  Future<void> startAutoShowAppOpen() {
    throw UnimplementedError(
        'startAutoShowAppOpen() has not been implemented.');
  }

  Future<void> stopAutoShowAppOpen() {
    throw UnimplementedError(
        'stopAutoShowAppOpen() has not been implemented.');
  }
}
