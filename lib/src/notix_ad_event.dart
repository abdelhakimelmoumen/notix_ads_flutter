/// Ad formats supported by the plugin.
enum NotixAdFormat { interstitial, appOpen, push, unknown }

/// Lifecycle event types reported by the native SDK.
enum NotixAdEventType {
  loaded,
  failedToLoad,
  shown,
  failedToShow,
  clicked,
  closed,
  unknown,
}

/// A single ad lifecycle event coming from the native side.
class NotixAdEvent {
  final NotixAdFormat format;
  final NotixAdEventType type;
  final String? zoneId;
  final String? message;

  const NotixAdEvent({
    required this.format,
    required this.type,
    this.zoneId,
    this.message,
  });

  factory NotixAdEvent.fromMap(Map<dynamic, dynamic> map) {
    return NotixAdEvent(
      format: _formatFromString(map['format'] as String?),
      type: _typeFromString(map['type'] as String?),
      zoneId: map['zoneId'] as String?,
      message: map['message'] as String?,
    );
  }

  static NotixAdFormat _formatFromString(String? value) {
    switch (value) {
      case 'interstitial':
        return NotixAdFormat.interstitial;
      case 'appOpen':
        return NotixAdFormat.appOpen;
      case 'push':
        return NotixAdFormat.push;
      default:
        return NotixAdFormat.unknown;
    }
  }

  static NotixAdEventType _typeFromString(String? value) {
    switch (value) {
      case 'loaded':
        return NotixAdEventType.loaded;
      case 'failedToLoad':
        return NotixAdEventType.failedToLoad;
      case 'shown':
        return NotixAdEventType.shown;
      case 'failedToShow':
        return NotixAdEventType.failedToShow;
      case 'clicked':
        return NotixAdEventType.clicked;
      case 'closed':
        return NotixAdEventType.closed;
      default:
        return NotixAdEventType.unknown;
    }
  }

  @override
  String toString() =>
      'NotixAdEvent(format: $format, type: $type, zoneId: $zoneId, message: $message)';
}

