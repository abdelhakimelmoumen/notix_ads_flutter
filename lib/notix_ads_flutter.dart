library notix_ads_flutter;

import 'src/notix_ads_flutter_platform_interface.dart';

export 'src/notix_ad_event.dart';

/// Public API for the Monetag (Notix) Flutter plugin.
///
/// Currently supports Android via the native `co.notix:android-sdk`.
/// Call [initPush] once at app startup if you plan to use push ads,
/// and use [loadInterstitial]/[showInterstitial] or
/// [loadAppOpen]/[startAutoShowAppOpen] for the other formats.
class NotixAdsFlutter {
  NotixAdsFlutter._();

  /// Stream of ad lifecycle events (loaded / failed / shown / clicked / closed)
  /// for every ad format. Each event carries a `format` and `type` field so
  /// you can filter as needed.
  static Stream<NotixAdEvent> get onAdEvent =>
      NotixAdsFlutterPlatform.instance.onAdEvent;

  /// Initializes Push Notifications. Call this once, as early as possible
  /// (e.g. in `main()` after `WidgetsFlutterBinding.ensureInitialized()`).
  ///
  /// [appId] and [token] come from your Monetag In-App Android source page.
  static Future<void> initPush({
    required String appId,
    required String token,
  }) {
    return NotixAdsFlutterPlatform.instance.initPush(appId, token);
  }

  /// Creates a loader and starts preloading an Interstitial ad for [zoneId].
  /// Call this well before you intend to show the ad (e.g. on app start or
  /// screen entry) so it's ready when you need it.
  static Future<void> loadInterstitial({required String zoneId}) {
    return NotixAdsFlutterPlatform.instance.loadInterstitial(zoneId);
  }

  /// Shows the previously loaded Interstitial ad, if one is ready.
  /// Returns `true` if an ad was shown, `false` if none was available.
  /// After showing, a new ad automatically starts preloading.
  static Future<bool> showInterstitial() {
    return NotixAdsFlutterPlatform.instance.showInterstitial();
  }

  /// Creates a loader and starts preloading an App Open ad for [zoneId].
  static Future<void> loadAppOpen({required String zoneId}) {
    return NotixAdsFlutterPlatform.instance.loadAppOpen(zoneId);
  }

  /// Enables automatic App Open ad display every time the user re-opens
  /// (foregrounds) the app. Call [loadAppOpen] first.
  static Future<void> startAutoShowAppOpen() {
    return NotixAdsFlutterPlatform.instance.startAutoShowAppOpen();
  }

  /// Disables the automatic App Open behavior started by
  /// [startAutoShowAppOpen].
  static Future<void> stopAutoShowAppOpen() {
    return NotixAdsFlutterPlatform.instance.stopAutoShowAppOpen();
  }
}
