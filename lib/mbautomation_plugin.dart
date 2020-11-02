import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mpush/mp_android_notifications_settings.dart';
import 'package:mbmessages/push_notifications/mbpush.dart';
import 'package:mpush/mpush.dart';
import 'dart:convert';

class MBAutomationFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('mbautomation');

  //TODO: init callbacks

  static Future<bool> showLocalNotification({
    @required String id,
    @required DateTime date,
    @required String title,
    @required String body,
    @required int badge,
    @required launchImage,
    @required sound,
    @required media,
    @required mediaType,
  }) async {
    MPAndroidNotificationsSettings androidNotificationsSettings =
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
    arguments.addAll(androidNotificationsSettings.toMethodChannelArguments());
    bool result = await _channel.invokeMethod('showNotification', arguments);
    return result ?? false;
  }

  static Future<void> cancelLocalNotification({@required String id}) async {
    await _channel.invokeMethod('cancelNotification', {'id': id.hashCode});
  }

  /// If method call has been initialized or not
  static bool _methodCallInitialized = false;

  static initializeMethodCall() {
    if (!_methodCallInitialized) {
      _methodCallInitialized = true;
      _channel.setMethodCallHandler(_mbAutomationHandler);
    }
  }

  static Future<dynamic> _mbAutomationHandler(MethodCall methodCall) async {
    switch (methodCall.method) {
      case 'pushArrived':
        Function(Map<String, dynamic>) onNotificationArrival = MPush.onNotificationArrival;
        if (onNotificationArrival != null) {
          if (methodCall.arguments is Map<String, dynamic>) {
            onNotificationArrival(methodCall.arguments);
          } else if (methodCall.arguments is String) {
            Map<String, dynamic> map = json.decode(methodCall.arguments);
            onNotificationArrival(map);
          }
        }
        break;
      case 'pushTapped':
        Function(Map<String, dynamic>) onNotificationTap = MPush.onNotificationTap;
        if (onNotificationTap != null) {
          if (methodCall.arguments is Map<String, dynamic>) {
            onNotificationTap(methodCall.arguments);
          } else if (methodCall.arguments is String) {
            Map<String, dynamic> map = json.decode(methodCall.arguments);
            onNotificationTap(map);
          }
        }
        break;
      default:
        print('${methodCall.method} not implemented');
        return;
    }
  }

}
