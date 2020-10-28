import 'dart:io';

import 'package:mbautomation/mbautomation_plugin.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

class MBAutomationPushNotificationsManager {
  static Future<void> showPushNotifications(List<MBMessage> messages) async {
    List<MBMessage> messagesToShow = [];
    for (MBMessage message in messagesToShow) {
      if (message.messageType == MBMessageType.push) {
        bool messageHasBeenShowed = await _messageHasBeenShowed(message);
        if (!messageHasBeenShowed) {
          messagesToShow.add(message);
        }
      }
    }
    if (messagesToShow.length != 0) {
      for (MBMessage message in messagesToShow) {
        await _showPushNotificationForMessage(message);
      }
    }
  }

  static Future<void> cancelPushNotificationForMessage(
      MBMessage message) async {
    String identifier = _notificatinIdentifierForMessage(message);
    await MBAutomationFlutterPlugin.cancelLocalNotification(id: identifier);
    await _unsetMessageShowed(message);
  }

  static Future<void> _showPushNotificationForMessage(MBMessage message) async {
    if (message.pushMessage == null) {
      return;
    }

    MBPushMessage pushMessage = message.pushMessage;

    String id = _notificatinIdentifierForMessage(message);
    String title = pushMessage.title;
    String body = pushMessage.body;
    int badge = pushMessage.badge;
    String launchImage = pushMessage.launchImage;
    String sound = pushMessage.sound;
    String media;
    String mediaType;
    if (pushMessage.userInfo != null) {
      String mediaUrl = pushMessage.userInfo['media_url'];
      if (mediaUrl != null) {
        mediaType = pushMessage.userInfo['media_type'];
        File mediaFile = await _downloadImage(mediaUrl);
        media = mediaFile.path;
      }
    }

    DateTime date = DateTime.now();
    if (message.sendAfterDays != null && message.sendAfterDays != 0) {
      date = date.add(Duration(days: message.sendAfterDays));
    }

    bool result = await MBAutomationFlutterPlugin.showLocalNotification(
      id: id,
      date: date,
      title: title,
      body: body,
      badge: badge,
      launchImage: launchImage,
      sound: sound,
      media: media,
      mediaType: mediaType,
    );
    if (result ?? false) {
      await _setMessageShowed(message);
    }
  }

  static Future<File> _downloadImage(String media) async {
    if (media != null) {
      return null;
    }
    final fileName = basename(media);
    final response = await http.get(media);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  static String _notificatinIdentifierForMessage(MBMessage message) {
    return 'mburger.automation.push.' + (message.id?.toString() ?? '');
  }

  static Future<bool> _messageHasBeenShowed(MBMessage message) async {
    if (message.id == null) {
      return false;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessagesKey) ?? [];
    return showedMessages.contains(message.id.toString());
  }

  static Future<void> _setMessageShowed(MBMessage message) async {
    if (message.id == null) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessagesKey) ?? [];
    if (!showedMessages.contains(message.id.toString())) {
      showedMessages.add(message.id.toString());
      await prefs.setStringList(_showedMessagesKey, showedMessages);
    }
  }

  static Future<void> _unsetMessageShowed(MBMessage message) async {
    if (message.id == null) {
      return;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> showedMessages = prefs.getStringList(_showedMessagesKey) ?? [];
    if (!showedMessages.contains(message.id.toString())) {
      showedMessages.remove(message.id.toString());
      await prefs.setStringList(_showedMessagesKey, showedMessages);
    }
  }

  static String get _showedMessagesKey =>
      'com.mumble.mburger.automation.pushMessages.showedMessages';
}
