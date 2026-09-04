package com.notixads.notix_ads_flutter

import android.app.Activity
import android.content.Context
import androidx.annotation.NonNull
import co.notix.NotixAppOpen
import co.notix.NotixInterstitial
import co.notix.NotixPush
import co.notix.appopen.AppOpenLoader
import co.notix.interstitial.InterstitialLoader
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/**
 * NotixAdsFlutterPlugin
 *
 * Bridges Dart calls to the native `co.notix:android-sdk` (Monetag In-App SDK).
 *
 * NOTE: This wraps the public API documented at https://docs.inappi.co.
 * Callback/listener method names on [InterstitialLoader] / [AppOpenLoader]
 * can change between SDK versions -- if `co.notix:android-sdk` bumps a minor
 * version and compilation fails here, check the changelog for the loader
 * API and adjust the small `TODO` sections below accordingly.
 */
class NotixAdsFlutterPlugin :
    FlutterPlugin,
    MethodCallHandler,
    ActivityAware,
    EventChannel.StreamHandler {

    private lateinit var methodChannel: MethodChannel
    private lateinit var eventChannel: EventChannel
    private lateinit var appContext: Context
    private var activity: Activity? = null
    private var eventSink: EventChannel.EventSink? = null

    private var interstitialLoader: InterstitialLoader? = null
    private var interstitialZoneId: String? = null

    private var appOpenLoader: AppOpenLoader? = null
    private var appOpenZoneId: String? = null

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        appContext = binding.applicationContext
        methodChannel = MethodChannel(binding.binaryMessenger, "notix_ads_flutter/methods")
        methodChannel.setMethodCallHandler(this)
        eventChannel = EventChannel(binding.binaryMessenger, "notix_ads_flutter/events")
        eventChannel.setStreamHandler(this)
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        methodChannel.setMethodCallHandler(null)
        eventChannel.setStreamHandler(null)
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onListen(arguments: Any?, events: EventChannel.EventSink?) {
        eventSink = events
    }

    override fun onCancel(arguments: Any?) {
        eventSink = null
    }

    private fun emitEvent(
        format: String,
        type: String,
        zoneId: String? = null,
        message: String? = null,
    ) {
        eventSink?.success(
            mapOf(
                "format" to format,
                "type" to type,
                "zoneId" to zoneId,
                "message" to message,
            ),
        )
    }

    override fun onMethodCall(call: MethodCall, result: Result) {
        when (call.method) {
            "initPush" -> {
                val appId = call.argument<String>("appId")
                val token = call.argument<String>("token")
                if (appId == null || token == null) {
                    result.error("INVALID_ARGS", "appId and token are required", null)
                    return
                }
                try {
                    NotixPush.init(appContext, appId, token)
                    result.success(null)
                } catch (e: Exception) {
                    result.error("INIT_PUSH_FAILED", e.message, null)
                }
            }

            "loadInterstitial" -> {
                val zoneId = call.argument<String>("zoneId")
                if (zoneId == null) {
                    result.error("INVALID_ARGS", "zoneId is required", null)
                    return
                }
                interstitialZoneId = zoneId
                interstitialLoader = NotixInterstitial.createLoader(zoneId)
                // TODO: if InterstitialLoader exposes onLoaded/onFailedToLoad
                // callbacks in your SDK version, wire them here and forward
                // via emitEvent("interstitial", "loaded"/"failedToLoad", zoneId).
                interstitialLoader?.startLoading()
                emitEvent("interstitial", "loaded", zoneId, "load requested")
                result.success(null)
            }

            "showInterstitial" -> {
                val loader = interstitialLoader
                if (loader == null) {
                    result.success(false)
                    return
                }
                loader.doOnNextAvailable { ad ->
                    if (ad != null) {
                        NotixInterstitial.show(ad)
                        emitEvent("interstitial", "shown", interstitialZoneId)
                        result.success(true)
                    } else {
                        emitEvent("interstitial", "failedToShow", interstitialZoneId, "no ad ready")
                        result.success(false)
                    }
                }
            }

            "loadAppOpen" -> {
                val zoneId = call.argument<String>("zoneId")
                if (zoneId == null) {
                    result.error("INVALID_ARGS", "zoneId is required", null)
                    return
                }
                appOpenZoneId = zoneId
                appOpenLoader = NotixAppOpen.createLoader(zoneId)
                appOpenLoader?.startLoading()
                emitEvent("appOpen", "loaded", zoneId, "load requested")
                result.success(null)
            }

            "startAutoShowAppOpen" -> {
                val loader = appOpenLoader
                if (loader == null) {
                    result.error(
                        "NOT_LOADED",
                        "Call loadAppOpen() before startAutoShowAppOpen()",
                        null,
                    )
                    return
                }
                NotixAppOpen.startAutoShow(loader)
                result.success(null)
            }

            "stopAutoShowAppOpen" -> {
                // TODO: replace with the SDK's actual stop/teardown API if
                // available in your version (e.g. NotixAppOpen.stopAutoShow).
                appOpenLoader = null
                result.success(null)
            }

            else -> result.notImplemented()
        }
    }
}
