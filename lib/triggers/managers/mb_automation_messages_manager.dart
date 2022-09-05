import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/managers/mb_automation_messages_view_manager.dart';
import 'package:mbautomation/triggers/managers/mb_automation_push_notifications_manager.dart';
import 'package:mbautomation/triggers/mb_app_opening_trigger.dart';
import 'package:mbautomation/triggers/mb_event_trigger.dart';
import 'package:mbautomation/triggers/mb_inactive_user_trigger.dart';
import 'package:mbautomation/triggers/mb_location_trigger.dart';
import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/mb_tag_change_trigger.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:mbautomation/triggers/mb_view_trigger.dart';
import 'package:mbautomation/triggers/message_saving/mb_message_saving_utility.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_manager.dart';
import 'package:mbmessages/mbmessages.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mburger/mb_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:collection/collection.dart';

/// Main class that manages messages and triggers, responds to external events and updates the triggers.
class MBAutomationMessagesManager {
  /// The tmer used to check message/triggers periodically.
  static Timer? timer;

//region triggers
  /// Creates and initializes triggers object to the messages fetched.
  /// Messages comes from the MBMessage plugin with the var triggers as a Map, when automation is on.
  /// This variable is replaced with a MBMessageTriggers object.
  /// @param messages A list of messages that will be populated with MBMessageTriggers objects.
  static void setTriggersToMessages(List<MBMessage> messages) {
    for (MBMessage message in messages) {
      if (message.automationIsOn) {
        if (message.triggers != null &&
            message.triggers is Map<String, dynamic>) {
          message.triggers = MBMessageTriggers.fromDictionary(message.triggers);
        }
      }
    }
  }

  /// Creates a `MBTrigger` object from the JSON dictionary, based on the type.
  /// @param jsonDictionary The JSON object to convert to a trigger.
  /// @returns The corresponding `MBTrigger` object.
  static MBTrigger triggerFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    String triggerTypeString = jsonDictionary['type'];
    MBTriggerType triggerType =
        MBTrigger.triggerTypeFromString(triggerTypeString);
    switch (triggerType) {
      case MBTriggerType.location:
        return MBLocationTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.appOpening:
        return MBAppOpeningTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.view:
        return MBViewTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.inactiveUser:
        return MBInactiveUserTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.event:
        return MBEventTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.tagChange:
        return MBTagChangeTrigger.fromJsonDictionary(jsonDictionary);
      case MBTriggerType.unknown:
        return MBTrigger.fromJsonDictionary(jsonDictionary);
    }
  }

  /// Creates a `MBTrigger` object from the dictionary returned by the APIs, based on the type.
  /// @param jsonDictionary The API Map to convert to a trigger.
  /// @returns The corresponding `MBTrigger` object.
  static MBTrigger triggerFromDictionary(Map<String, dynamic> dictionary) {
    String type = dictionary['type'];
    switch (type) {
      case 'location':
        return MBLocationTrigger.fromDictionary(dictionary);
      case 'app_opening':
        return MBAppOpeningTrigger.fromDictionary(dictionary);
      case 'view':
        return MBViewTrigger.fromDictionary(dictionary);
      case 'inactive_user':
        return MBInactiveUserTrigger.fromDictionary(dictionary);
      case 'event':
        return MBEventTrigger.fromDictionary(dictionary);
      case 'tag_change':
        return MBTagChangeTrigger.fromDictionary(dictionary);
    }
    return MBTrigger.fromDictionary(dictionary);
  }

//endregion

//region timer
  /// Starts the timer to check periodically messages.
  /// @param time The time interval in seconds.
  static startMessageTimer({required int time}) {
    timer = Timer.periodic(
      Duration(seconds: time),
      (timer) => checkMessages(fromStartup: false),
    );
  }

  /// Restarts the timer with a new time.
  /// @param time The time interval in seconds.
  static messageTimerChanged({required int time}) {
    if (timer != null) {
      timer?.cancel();
      timer = null;
    }
    timer = Timer.periodic(
      Duration(seconds: time),
      (timer) => checkMessages(fromStartup: false),
    );
  }

//endregion

  /// Function called when an event happens.
  /// It checks the saved messages and tells all the `MBEventTrigger` triggers that this event happened.
  /// @param event The event that happened.
  static eventHappened(MBAutomationEvent event) async {
    List<MBMessage>? messagesSaved = await savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.isEmpty) {
      return;
    }

    bool somethingChanged = false;
    for (MBMessage message in messagesSaved) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers messageTriggers = message.triggers;
        List<MBEventTrigger> eventsTriggers =
            List.castFrom<MBTrigger, MBEventTrigger>(
          messageTriggers.triggers.whereType<MBEventTrigger>().toList(),
        );
        for (MBEventTrigger eventTrigger in eventsTriggers) {
          bool triggerChanged = await eventTrigger.eventHappened(event);
          if (triggerChanged) {
            somethingChanged = true;
          }
        }
      }
    }

    if (somethingChanged) {
      await saveMessages(
        messagesSaved,
        fromFetch: false,
      );
    }
    checkMessages(fromStartup: false);
  }

  /// Function called when a screen has been viewed.
  /// It checks the saved messages (with the `MBAutomationMessagesViewManager`) and tells all the `MBViewTrigger` triggers that this view has been viewed.
  /// @param view The screen view that the user has viewed.
  static Future<void> screenViewed(MBAutomationView view) async {
    MBAutomationMessagesViewManager.screenViewed(view);
  }

  /// Function called when a tag changes.
  /// It checks the saved messages and tells all the `MBTagChange` triggers that this tag has changed.
  /// @param tag The tag that changed.
  /// @param value The new value of the tag.
  static Future<void> tagChanged(String tag, String? value) async {
    List<MBMessage>? messagesSaved = await savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.isEmpty) {
      return;
    }

    bool somethingChanged = false;
    for (MBMessage message in messagesSaved) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers messageTriggers = message.triggers;
        List<MBTagChangeTrigger> tagTriggers =
            List.castFrom<MBTrigger, MBTagChangeTrigger>(
          messageTriggers.triggers.whereType<MBTagChangeTrigger>().toList(),
        );
        for (MBTagChangeTrigger tagTrigger in tagTriggers) {
          MBTriggerChangedStatus result = tagTrigger.tagChanged(tag, value);
          if (result != MBTriggerChangedStatus.unchanged) {
            somethingChanged = true;
          }

          if (result == MBTriggerChangedStatus.invalid) {
            if (message.messageType == MBMessageType.push &&
                message.sendAfterDays != 0) {
              MBAutomationPushNotificationsManager
                  .cancelPushNotificationForMessage(message);
            }
          }
        }
      }
    }

    if (somethingChanged) {
      await saveMessages(
        messagesSaved,
        fromFetch: false,
      );
    }
    checkMessages(fromStartup: false);
  }

  /// Function called when new location data is available.
  /// It checks the saved messages and tells all the MBLocationTrigger` triggers that this tag has changed.
  /// @param latitude The new latitude.
  /// @param longitude The new longitude.
  static Future<void> locationDataUpdated(
    double latitude,
    double longitude,
  ) async {
    List<MBMessage>? messagesSaved = await savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.isEmpty) {
      return;
    }

    _Location? lastLocation = await _lastLocation();

    bool somethingChanged = false;
    for (MBMessage message in messagesSaved) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers messageTriggers = message.triggers;
        List<MBLocationTrigger> locationTriggers =
            List.castFrom<MBTrigger, MBLocationTrigger>(
          messageTriggers.triggers.whereType<MBLocationTrigger>().toList(),
        );
        for (MBLocationTrigger locationTrigger in locationTriggers) {
          bool triggerChanged = locationTrigger.locationDataUpdated(
            latitude: latitude,
            longitude: longitude,
            lastLatitude: lastLocation?.latitude,
            lastLongitude: lastLocation?.longitude,
          );
          if (triggerChanged) {
            somethingChanged = true;
          }
        }
      }
    }

    if (somethingChanged) {
      await saveMessages(
        messagesSaved,
        fromFetch: false,
      );
    }
    checkMessages(fromStartup: false);
    await _saveLocationAsLast(_Location(
      latitude,
      longitude,
    ));
  }

  /// The last location seen by MBAutomation.
  /// @returns The last location saved, if present.
  static Future<_Location?> _lastLocation() async {
    String lastLocationLatKey =
        'com.mumble.mburger.automation.lastLocation.lat';
    String lastLocationLngKey =
        'com.mumble.mburger.automation.lastLocation.lng';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double? lat = prefs.getDouble(lastLocationLatKey);
    double? lng = prefs.getDouble(lastLocationLngKey);
    if (lat != null && lng != null) {
      return _Location(lat, lng);
    }
    return null;
  }

  /// Saves a location as the last seen.
  /// @param location The location that will be saved.
  static Future<void> _saveLocationAsLast(_Location location) async {
    String lastLocationLatKey =
        'com.mumble.mburger.automation.lastLocation.lat';
    String lastLocationLngKey =
        'com.mumble.mburger.automation.lastLocation.lng';
    SharedPreferences prefs = await SharedPreferences.getInstance();
    double lat = location.latitude;
    double lng = location.longitude;
    if (lat != 0 && lng != 0) {
      await prefs.setDouble(lastLocationLatKey, lat);
      await prefs.setDouble(lastLocationLngKey, lng);
    } else {
      await prefs.remove(lastLocationLatKey);
      await prefs.remove(lastLocationLngKey);
    }
  }

  /// Checks the saved messages and show them if they need to be showed.
  /// @param fromStartup If the check has been triggered at app startup.
  static Future<void> checkMessages({bool fromStartup = false}) async {
    List<MBMessage>? messagesSaved = await savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.isEmpty) {
      return;
    }
    List<MBMessage> messagesToShow = [];
    for (MBMessage message in messagesSaved) {
      if (message.triggers != null) {
        if (message.triggers is MBMessageTriggers) {
          MBMessageTriggers messageTriggers = message.triggers;
          bool triggerIsValid = await messageTriggers.isValid(fromStartup);
          if (message.repeatTimes > 0) {
            bool hasAppOpeningTriggers = messageTriggers.triggers
                    .firstWhereOrNull((t) => t is MBAppOpeningTrigger) !=
                null;
            if (!(hasAppOpeningTriggers && fromStartup)) {
              Map<String, dynamic>? savedTriggers =
                  await _savedMessageTriggers(message);
              if (savedTriggers != null) {
                Map<String, dynamic> triggersDictionary =
                    messageTriggers.toJsonDictionary();
                if (mapEquals(savedTriggers, triggersDictionary)) {
                  continue;
                }
              }
            }
            await _saveMessageTriggers(message);
          }
          if (triggerIsValid) {
            messagesToShow.add(message);
          }
        }
      }
    }

    if (messagesToShow.isNotEmpty) {
      List<MBMessage> inAppMessages = messagesToShow
          .where((m) =>
              m.messageType == MBMessageType.inAppMessage &&
              m.inAppMessage != null)
          .toList();
      List<MBMessage> pushMessages = messagesToShow
          .where((m) =>
              m.messageType == MBMessageType.push && m.pushMessage != null)
          .toList();
      if (inAppMessages.isNotEmpty) {
        MBMessages? plugin = MBManager.shared.pluginOf<MBMessages>();
        if (plugin != null) {
          MBInAppMessageManager.presentMessages(
            messages: inAppMessages,
            ignoreShowedMessages: plugin.debug,
            themeForMessage: plugin.themeForMessage,
            onButtonPressed: plugin.onButtonPressed,
          );
        }
      }
      if (pushMessages.isNotEmpty) {
        MBAutomationPushNotificationsManager.showPushNotifications(
            pushMessages);
      }
    }
  }

//endregion

//region message saving
  /// Save a list of messages.
  /// @param messages The list of messages that will be saved.
  /// @param fromFetch If the save has been triggered after an API call.
  static Future<void> saveMessages(
    List<MBMessage> messages, {
    bool fromFetch = false,
  }) async {
    String path = await _messagesPath();
    File f = File(path);
    List<MBMessage>? messagesSaved = await savedMessages();
    List<MBMessage> messagesToSave = [];
    if (fromFetch) {
      for (MBMessage message in messages) {
        MBMessage? savedMessage =
            messagesSaved?.firstWhereOrNull((m) => m.id == message.id);
        if (savedMessage != null) {
          if (savedMessage.triggers != null && message.triggers != null) {
            if (savedMessage.triggers is MBMessageTriggers &&
                message.triggers is MBMessageTriggers) {
              MBMessageTriggers savedTriggers = savedMessage.triggers;
              MBMessageTriggers messageTriggers = message.triggers;
              savedTriggers.updateTriggers(messageTriggers);
            }
          } else if (savedMessage.triggers == null &&
              message.triggers != null) {
            savedMessage.triggers = message.triggers;
            savedMessage.sendAfterDays = message.sendAfterDays;
            savedMessage.repeatTimes = message.repeatTimes;
          }
          messagesToSave.add(savedMessage);
        } else {
          messagesToSave.add(message);
        }
      }
    } else {
      messagesToSave = messages;
    }
    List<Map<String, dynamic>> jsonDictionaries = messagesToSave
        .map((m) => MBMessageSavingUtility.jsonDictionaryForMessage(m))
        .toList();
    String jsonString = json.encode(jsonDictionaries);
    if (!(await f.exists())) {
      await f.create(recursive: true);
    }
    await f.writeAsString(jsonString);
  }

  /// Returns the saved messages.
  /// @returns A future that completes with the list of saved messages.
  static Future<List<MBMessage>?> savedMessages() async {
    String path = await _messagesPath();
    File f = File(path);
    bool fileExists = await f.exists();
    if (!fileExists) {
      return [];
    }
    String contents = await f.readAsString();
    if (contents.isEmpty) {
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

  static Future<void> _saveMessageTriggers(MBMessage message) async {
    String path = await _triggersPath(message);
    if (message.triggers == null) {
      return;
    }
    File f = File(path);
    bool fileExists = await f.exists();
    if (!fileExists) {
      return;
    }
    if (message.triggers is MBMessageTriggers) {
      Map<String, dynamic> triggers =
          (message.triggers as MBMessageTriggers).toJsonDictionary();
      String jsonString = json.encode(triggers);
      if (!(await f.exists())) {
        await f.create(recursive: true);
      }
      await f.writeAsString(jsonString);
    }
  }

  static Future<Map<String, dynamic>?> _savedMessageTriggers(
      MBMessage message) async {
    String path = await _triggersPath(message);
    File f = File(path);
    bool fileExists = await f.exists();
    if (!fileExists) {
      return null;
    }
    String contents = await f.readAsString();
    Map<String, dynamic> dictionary = json.decode(contents);
    return dictionary;
  }

  /// The path in which messages will be saved.
  static Future<String> _messagesPath() async {
    final directory = await getApplicationDocumentsDirectory();
    String file = 'mb_automation_messages_f.json';
    return '${directory.path}/$file';
  }

  static Future<String> _triggersPath(MBMessage message) async {
    final directory = await getApplicationDocumentsDirectory();
    String file = 'mb_automation_messages_${message.id}_triggers.json';
    return '${directory.path}/$file';
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
