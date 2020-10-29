import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:mpush/mp_android_notifications_settings.dart';
import 'package:mbmessages/push_notifications/mbpush.dart';

class MBAutomationFlutterPlugin {
  static const MethodChannel _channel = const MethodChannel('mbautomation');

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
}
