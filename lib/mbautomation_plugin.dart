
import 'dart:async';

import 'package:flutter/services.dart';

class MBAutomationFlutterPlugin {
  static const MethodChannel _channel =
      const MethodChannel('mbautomation');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }
}
