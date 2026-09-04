# notix_ads_flutter

Unofficial Flutter plugin that wraps the **Monetag (Notix) In-App Android SDK**
(`co.notix:android-sdk`, published on Maven Central) so you can call it from
Dart. Supports **Interstitial**, **App Open**, and **Push Notification** ad
formats.

> ⚠️ Android only for now. Monetag does not currently publish an official
> Flutter or iOS in-app SDK — if you need iOS or a WebView-based Flutter app
> (Telegram Mini App style), use Monetag's `monetag-tg-sdk` JS package inside
> a `webview_flutter` view instead, or their SmartLink URLs via
> `url_launcher`.

## 1. Add the plugin

Since this isn't published on pub.dev, add it as a local or git path
dependency in your app's `pubspec.yaml`:

```yaml
dependencies:
  notix_ads_flutter:
    path: ../notix_ads_flutter   # or git: { url: ..., path: ... }
```

## 2. Get your credentials from Monetag

1. Register / log in at the Monetag self-service platform.
2. Go to **Android Apps → Add app**, fill in your app info.
3. Create a placement for each format you want:
   - **Interstitial** → copy the `zoneId`.
   - **App Open** → copy the `zoneId`.
   - **Push Notifications** → only one placement per app; you'll need your
     **Notix App ID** and **Notix Token** (found on the In-App Android
     source page). Push also requires FCM Server Key + Sender ID, entered
     on Monetag's side, from your Firebase project settings.

## 3. Android project setup

No manual Gradle edits needed beyond the plugin itself — `co.notix:android-sdk`
is pulled in automatically as a transitive dependency. Just make sure your
app's `android/build.gradle` (or `settings.gradle` repositories block on
AGP 8+) includes `mavenCentral()`, which is the default in new Flutter
projects.

Minimum `minSdkVersion` is 21.

## 4. Usage

```dart
import 'package:notix_ads_flutter/notix_ads_flutter.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Push notifications (optional, once at startup)
  await NotixAdsFlutter.initPush(appId: 'YOUR_APP_ID', token: 'YOUR_TOKEN');

  // Interstitial: preload early, show later
  await NotixAdsFlutter.loadInterstitial(zoneId: 'YOUR_ZONE_ID');
  // ... later, e.g. on a button tap or screen transition:
  final shown = await NotixAdsFlutter.showInterstitial();

  // App Open: preload + auto-show on every app foreground
  await NotixAdsFlutter.loadAppOpen(zoneId: 'YOUR_APP_OPEN_ZONE_ID');
  await NotixAdsFlutter.startAutoShowAppOpen();

  // Optional: listen to ad lifecycle events
  NotixAdsFlutter.onAdEvent.listen((event) => print(event));

  runApp(const MyApp());
}
```

See `example/lib/main.dart` for a full runnable snippet.

## API summary

| Method | Description |
|---|---|
| `initPush({appId, token})` | Initializes push notification ads. |
| `loadInterstitial({zoneId})` | Creates a loader and preloads an interstitial. |
| `showInterstitial()` | Shows the preloaded interstitial if ready; returns `bool`. |
| `loadAppOpen({zoneId})` | Creates a loader and preloads an App Open ad. |
| `startAutoShowAppOpen()` | Auto-shows App Open ads on every app foreground. |
| `stopAutoShowAppOpen()` | Stops the auto-show behavior. |
| `onAdEvent` | Broadcast stream of `NotixAdEvent` (loaded/shown/clicked/closed/...). |

## Notes & caveats

- This plugin was hand-written against Monetag's published documentation
  (docs.inappi.co) rather than generated from an official Flutter SDK,
  because Monetag doesn't ship one. **Test it against the current
  `co.notix:android-sdk` version** before shipping — if the SDK's loader
  API differs slightly (method/callback names), check
  `android/src/main/kotlin/.../NotixAdsFlutterPlugin.kt`, the `TODO` comments
  mark the spots most likely to need a tweak.
- Native Ads (custom-rendered native ad units) aren't wrapped yet since they
  require exposing bitmaps/text across the platform channel or a
  `PlatformView` — open an issue/extend `NotixAdsFlutterPlugin.kt` following
  the same pattern if you need this format.
- Always test with a real device/emulator with Play Services + internet
  access; ad loads can silently no-op on emulators without Play Store.
