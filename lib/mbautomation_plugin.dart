import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';

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
    MBMessages messages =
    bool result = await _channel.invokeMethod('showNotification', {
      'id': id,
      'date': date.millisecondsSinceEpoch ~/ 1000,
      'title': title,
      'body': body,
      'badge': badge,
      'launchImage': launchImage,
      'sound': sound,
      'media': media,
      'mediaType': mediaType,
    });
    return result ?? false;
  }

  static Future<void> cancelLocalNotification({@required String id}) async {
    await _channel.invokeMethod('cancelNotification', {'id': id});
  }
}
