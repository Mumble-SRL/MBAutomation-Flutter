import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/mb_app_opening_trigger.dart';
import 'package:mbautomation/triggers/mb_event_trigger.dart';
import 'package:mbautomation/triggers/mb_inactive_user_trigger.dart';
import 'package:mbautomation/triggers/mb_location_trigger.dart';
import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/mb_tag_change_trigger.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:mbautomation/triggers/mb_view_trigger.dart';
import 'package:mbautomation/triggers/message_saving/mb_message_saving_utility.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:path_provider/path_provider.dart';

class MBAutomationMessagesManager {
  static Timer timer;

//region triggers
  static void setTriggersToMessages(List<MBMessage> messages) {
    if (messages == null) {
      return;
    }
    for (MBMessage message in messages) {
      if (message.automationIsOn) {
        if (message.triggers != null &&
            message.triggers is Map<String, dynamic>) {
          message.triggers = MBMessageTriggers.fromDictionary(message.triggers);
        }
      }
    }
  }

  static MBTrigger triggerFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    String triggerTypeString = jsonDictionary['type'];
    MBTriggerType triggerType =
        MBTrigger.triggerTypeFromString(triggerTypeString);
    switch (triggerType) {
      case MBTriggerType.location:
        return MBLocationTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.appOpening:
        return MBAppOpeningTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.view:
        return MBViewTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.inactiveUser:
        return MBInactiveUserTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.event:
        return MBEventTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.tagChange:
        return MBTagChangeTrigger.fromJsonDictionary(jsonDictionary);
        break;
      case MBTriggerType.unknown:
        return MBTrigger.fromJsonDictionary(jsonDictionary);
        break;
    }
    return MBTrigger.fromJsonDictionary(jsonDictionary);
  }

  static MBTrigger triggerFromDictionary(Map<String, dynamic> dictionary) {
    String type = dictionary['type'];
    switch (type) {
      case 'location':
        return MBLocationTrigger.fromDictionary(dictionary);
        break;
      case 'app_opening':
        return MBAppOpeningTrigger.fromDictionary(dictionary);
        break;
      case 'view':
        return MBViewTrigger.fromDictionary(dictionary);
        break;
      case 'inactive_user':
        return MBInactiveUserTrigger.fromDictionary(dictionary);
        break;
      case 'event':
        return MBEventTrigger.fromDictionary(dictionary);
        break;
      case 'tag_change':
        return MBTagChangeTrigger.fromDictionary(dictionary);
        break;
    }
    return MBTrigger.fromDictionary(dictionary);
  }
//endregion

//region timer
  static startMessageTimer({@required int time}) {
    timer = Timer.periodic(
      Duration(seconds: time),
      (timer) => checkMessages(fromStartup: false),
    );
  }

  static messageTimerChanged({@required int time}) {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    timer = Timer.periodic(
      Duration(seconds: time),
      (timer) => checkMessages(fromStartup: false),
    );
  }
//endregion

  static eventHappened(MBAutomationEvent event) {}

  static screenViewed(MBAutomationView view) {}

  static tagChanged(String tag, String value) {}

  static locationDataUpdated(
    double latitude,
    double longitude,
  ) {}

  static _Location _lastLocation() {}

  static saveLocationAsLast(_Location location) {}

  static void checkMessages({bool fromStartup}) {}

//endregion

//region message saving
  static Future<void> saveMessages() async {
    String path = await _messagesPath();
  }

  static Future<List<MBMessage>> _savedMessages() async {
    String path = await _messagesPath();
    if (path == null) {
      return [];
    }
    File f = File(path);
    bool fileExists = await f.exists();
    if (!fileExists) {
      return [];
    }
    String contents = await f.readAsString();
    if (contents == null) {
      return [];
    }
    List<dynamic> list = json.decode(contents);
    List<MBMessage> messages = [];
    for (dynamic messageDict in list) {
      if (messageDict is Map<String, dynamic>) {
        messages
            .add(MBMessageSavingUtility.messageFromJsonDictionary(messageDict));
      }
    }
    return messages;
  }

  static Future<String> _messagesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    String file = 'mb_automation_messages_f.json';
    return '$directory/$file';
  }
//endregion

}

class _Location {
  double latitude;
  double longitude;

  _Location(
    this.latitude,
    this.longitude,
  );
}
