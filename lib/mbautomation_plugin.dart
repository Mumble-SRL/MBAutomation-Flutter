import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mbmessages/push_notifications/mbpush.dart';
import 'dart:convert';

/// Interface to native code, used to present and schedule local notifications.
class MBAutomationFlutterPlugin {
  /// Native method channel, used to interact with the native part.
  static const MethodChannel _channel = MethodChannel('mbautomation');

  /// Presents a local notification.
  /// @param id The id of the notification.
  /// @param date The date when the notification will be presented.
  /// @param title The title of the notification.
  /// @param body The body of the notification.
  /// @param badge The badge of the notification.
  /// @param launchImage The launch image for the notification.
  /// @param sound A custom sound for the notification.
  /// @param media The path of a media that will be showed with the notification.
  /// @param mediaType The media type.
  static Future<bool> showLocalNotification({
    required String id,
    required DateTime date,
    required String title,
    required String body,
    required int? badge,
    required String? launchImage,
    required String? sound,
    required String? media,
    required String? mediaType,
  }) async {
    MPAndroidNotificationsSettings? androidNotificationsSettings =
        MBPush.androidPushNotificationsSettings;
    if (Platform.isAndroid && androidNotificationsSettings == null) {
      return false;
    }
    Map<String, dynamic> arguments = {
      'id': id.hashCode,
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'title': title,
      'body': body,
      'badge': badge,
      'launchImage': launchImage,
      'sound': sound,
      'media': media,
      'mediaType': mediaType,
      'channelId': androidNotificationsSettings?.channelId,
      'channelName': androidNotificationsSettings?.channelName,
      'channelDescription': androidNotificationsSettings?.channelDescription,
      'icon': androidNotificationsSettings?.icon,
    };
    if (androidNotificationsSettings != null) {
      arguments.addAll(androidNotificationsSettings.toMethodChannelArguments());
    }
    dynamic result = await _channel.invokeMethod('showNotification', arguments);
    bool booleanResult = result is bool ? result : false;
    return booleanResult;
  }

  /// Cancels the local notification with the specified id.
  /// @param id The id of the notification that will be cancelled
  static Future<void> cancelLocalNotification({required String id}) async {
    await _channel.invokeMethod('cancelNotification', {'id': id.hashCode});
  }

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  /// Initializes method calls from native to dart.
  static void initializeMethodCall() {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbAutomationHandler);
    }
  }

  /// Handler for the native codes, used when a notification arrives and when a notification is tapped.
  /// It calls the callbacks set in the `MBMessages` plugin.
  static Future<dynamic> _mbAutomationHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'pushArrived':
        Function(Map<String, dynamic>)? onNotificationArrival =
            MBPush.onNotificationArrival;
        if (onNotificationArrival != null) {
          _callOnNotificationArrival(
            methodCall.arguments,
            onNotificationArrival,
          );
        }
        break;
      case 'pushTapped':
        Function(Map<String, dynamic>)? onNotificationTap =
            MBPush.onNotificationTap;
        if (onNotificationTap != null) {
          _callOnNotificationTap(
            methodCall.arguments,
            onNotificationTap,
          );
        }
        break;
      default:
        debugPrint('${methodCall.method} not implemented');
        return;
    }
  }

  /// Parses the `arguments` and calls the `onNotificationArrival` callback.
  static void _callOnNotificationArrival(
    dynamic arguments,
    Function(Map<String, dynamic>) onNotificationArrival,
  ) {
    if (arguments is Map<String, dynamic>) {
      onNotificationArrival(arguments);
    } else if (arguments is Map) {
      Map<String, dynamic> map = Map<String, dynamic>.from(arguments);
      onNotificationArrival(map);
    } else if (arguments is String) {
      Map<String, dynamic> map = json.decode(arguments);
      onNotificationArrival(map);
    }
  }

  /// Parses the `arguments` and calls the `onNotificationTap` callback.
  static void _callOnNotificationTap(
    dynamic arguments,
    Function(Map<String, dynamic>) onNotificationTap,
  ) {
    if (arguments is Map<String, dynamic>) {
      onNotificationTap(arguments);
    } else if (arguments is Map) {
      Map<String, dynamic> map = Map<String, dynamic>.from(arguments);
      onNotificationTap(map);
    } else if (arguments is String) {
      Map<String, dynamic> map = json.decode(arguments);
      onNotificationTap(map);
    }
  }
}
