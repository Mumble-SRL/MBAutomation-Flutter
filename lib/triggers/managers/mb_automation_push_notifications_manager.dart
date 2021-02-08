import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:mbautomation/mbautomation_plugin.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path/path.dart';
import 'package:http/http.dart' as http;

/// This class is used by MBAutomation to manage push notification, save notification messages already showed
/// and call the Flutter plugin to schedule notifications.
class MBAutomationPushNotificationsManager {
  /// Shows a push notification for the messages, if they've not been already showed.
  /// @param messages The list of messages.
  static Future<void> showPushNotifications(List<MBMessage> messages) async {
    List<MBMessage> messagesToShow = [];
    for (MBMessage message in messagesToShow) {
      if (message.messageType == MBMessageType.push) {
        bool needsToShowMessage = await _needsToShowMessage(message);
        if (needsToShowMessage) {
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

  /// Cancels a push notification for the message passed.
  /// @param message The message for which cancel the push.
  static Future<void> cancelPushNotificationForMessage(
      MBMessage message) async {
    String identifier = _notificationIdentifierForMessage(message);
    await MBAutomationFlutterPlugin.cancelLocalNotification(id: identifier);
    await _unsetMessageShowed(message);
  }

  /// Shows a push notification for a message.
  /// @param message The message to show.
  static Future<void> _showPushNotificationForMessage(MBMessage message) async {
    if (message.pushMessage == null) {
      return;
    }

    MBPushMessage pushMessage = message.pushMessage;

    String id = _notificationIdentifierForMessage(message);
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

  /// Downloads the image for the notification.
  /// @param media The url of the media.
  /// @returns A Future that completes with the File of the downloaded media.
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

  /// The notification identifier string for the message passed.
  /// @param message The message for which the identifier will be created.
  static String _notificationIdentifierForMessage(MBMessage message) {
    return 'mburger.automation.push.' + (message.id?.toString() ?? '');
  }

  /// If a message has already been shoewd or not.
  /// @param The message to check.
  static Future<bool> _needsToShowMessage(MBMessage message) async {
    if (message.endDate.millisecondsSinceEpoch < DateTime.now().millisecondsSinceEpoch) {
      return false;
    }
    if (message.id == null) {
      return false;
    }
    Map<int, int> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
      Map<int, int>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id] ?? 0;
    return messageShowCount <= message.repeatTimes;
  }

  /// Set a message as showed.
  /// @param The message to set as showed.
  static Future<void> _setMessageShowed(MBMessage message) async {
    if (message.id == null) {
      return;
    }
    Map<int, int> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
      Map<int, int>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id] ?? 0;
    showedMessagesCount[message.id] = messageShowCount + 1;
    await prefs.setString(_showedMessagesKey, json.encode(showedMessagesCount));
  }

  /// Unset a message as showed.
  /// @param The message to unset as showed.
  static Future<void> _unsetMessageShowed(MBMessage message) async {
    if (message.id == null) {
      return;
    }
    Map<int, int> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
      Map<int, int>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id] ?? 0;
    showedMessagesCount[message.id] = max(0, messageShowCount - 1);
    await prefs.setString(_showedMessagesKey, json.encode(showedMessagesCount));
  }

  /// The key used to save showed messages in shared preferences.
  static String get _showedMessagesKey =>
      'com.mumble.mburger.automation.pushMessages.showedMessages.count';
}
