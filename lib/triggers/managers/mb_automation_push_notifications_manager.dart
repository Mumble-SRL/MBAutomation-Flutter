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
    for (MBMessage message in messages) {
      if (message.messageType == MBMessageType.push) {
        bool needsToShowMessage = await _needsToShowMessage(message);
        if (needsToShowMessage) {
          messagesToShow.add(message);
        }
      }
    }
    if (messagesToShow.isNotEmpty) {
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
    await _unsetMessageShowDate(message);
    await _unsetMessageShowed(message);
  }

  /// Shows a push notification for a message.
  /// @param message The message to show.
  static Future<void> _showPushNotificationForMessage(MBMessage message) async {
    if (message.pushMessage == null) {
      return;
    }

    MBPushMessage pushMessage = message.pushMessage!;

    String id = _notificationIdentifierForMessage(message);
    String title = pushMessage.title;
    String body = pushMessage.body;
    int? badge = pushMessage.badge;
    String? launchImage = pushMessage.launchImage;
    String? sound = pushMessage.sound;
    String? media;
    String? mediaType;
    if (pushMessage.userInfo != null) {
      String? mediaUrl = pushMessage.userInfo!['media_url'];
      if (mediaUrl != null) {
        mediaType = pushMessage.userInfo!['media_type'];
        File? mediaFile = await _downloadImage(mediaUrl);
        media = mediaFile?.path;
      }
    }

    DateTime date = DateTime.now();
    if (message.sendAfterDays != 0) {
      // If we have already a notification in the future don't schedule a new notification
      DateTime? notificationDate = await _messageShowDate(message);
      if (notificationDate != null) {
        bool dateHasPassed = notificationDate.isBefore(DateTime.now());
        if (!dateHasPassed) {
          return;
        }
      }

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
    if (result) {
      await _setMessageShowDate(message, date);
      await _setMessageShowed(message);
    }
  }

  /// Downloads the image for the notification.
  /// @param media The url of the media.
  /// @returns A Future that completes with the File of the downloaded media.
  static Future<File?> _downloadImage(String media) async {
    Uri? uri = Uri.tryParse(media);
    if (uri == null) {
      return null;
    }
    final fileName = basename(media);
    final response = await http.get(uri);
    final documentDirectory = await getApplicationDocumentsDirectory();
    final file = File(join(documentDirectory.path, fileName));
    file.writeAsBytesSync(response.bodyBytes);
    return file;
  }

  /// The notification identifier string for the message passed.
  /// @param message The message for which the identifier will be created.
  static String _notificationIdentifierForMessage(MBMessage message) {
    return 'mburger.automation.push.${message.id}';
  }

  /// If a message has already been shoewd or not.
  /// @param The message to check.
  static Future<bool> _needsToShowMessage(MBMessage message) async {
    if (message.endDate != null) {
      DateTime endDate = message.endDate!;
      if (endDate.millisecondsSinceEpoch <
          DateTime.now().millisecondsSinceEpoch) {
        return false;
      }
    }

    Map<String, dynamic> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id.toString()] ?? 0;
    // At least show once
    int repeatTimes = max(message.repeatTimes, 1);
    return messageShowCount < repeatTimes;
  }

  /// Set a message as showed.
  /// @param The message to set as showed.
  static Future<void> _setMessageShowed(MBMessage message) async {
    Map<String, dynamic> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id.toString()] ?? 0;
    showedMessagesCount[message.id.toString()] = messageShowCount + 1;
    await prefs.setString(_showedMessagesKey, json.encode(showedMessagesCount));
  }

  /// Unset a message as showed.
  /// @param The message to unset as showed.
  static Future<void> _unsetMessageShowed(MBMessage message) async {
    Map<String, dynamic> showedMessagesCount = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessagesKey);
    if (showedMessagesString != null) {
      showedMessagesCount =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    int messageShowCount = showedMessagesCount[message.id.toString()] ?? 0;
    showedMessagesCount[message.id.toString()] = max(0, messageShowCount - 1);
    await prefs.setString(_showedMessagesKey, json.encode(showedMessagesCount));
  }

  // Sets the date of a notification, when it will be sent, used when sendAfterDays
  // has a value to not override
  static Future<void> _setMessageShowDate(
    MBMessage message,
    DateTime date,
  ) async {
    Map<String, dynamic> showedMessagesDates = await _showedMessageDates();
    int? messageDateInt = showedMessagesDates[message.id.toString()];
    if (messageDateInt == null) {
      showedMessagesDates[message.id.toString()] = date.millisecondsSinceEpoch;
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _showedMessagesDatesKey,
      json.encode(showedMessagesDates),
    );
  }

  static Future<void> _unsetMessageShowDate(MBMessage message) async {
    Map<String, dynamic> showedMessagesDates = await _showedMessageDates();
    if (showedMessagesDates[message.id.toString()] != null) {
      showedMessagesDates.remove(message.id.toString());
    }
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _showedMessagesDatesKey,
      json.encode(showedMessagesDates),
    );
  }

  static Future<DateTime?> _messageShowDate(MBMessage message) async {
    Map<String, dynamic> showedMessagesDates = await _showedMessageDates();
    int? messageDateInt = showedMessagesDates[message.id.toString()];
    if (messageDateInt != null) {
      return DateTime.fromMillisecondsSinceEpoch(messageDateInt);
    } else {
      return null;
    }
  }

  static Future<Map<String, dynamic>> _showedMessageDates() async {
    Map<String, dynamic> showedMessagesDates = {};
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? showedMessagesString = prefs.getString(_showedMessagesDatesKey);
    if (showedMessagesString != null) {
      showedMessagesDates =
          Map<String, dynamic>.from(json.decode(showedMessagesString));
    }
    return showedMessagesDates;
  }

  /// The key used to save showed messages in shared preferences.
  static String get _showedMessagesKey =>
      'com.mumble.mburger.automation.pushMessages.showedMessages.count';

  static String get _showedMessagesDatesKey =>
      'com.mumble.mburger.automation.pushMessages.showedMessages.dates';
}
