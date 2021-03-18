import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/message_saving/mb_in_app_message_saving_utility.dart';
import 'package:mbautomation/triggers/message_saving/mb_push_message_saving_utility.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';

/// Utility class to save messages as JSONs
class MBMessageSavingUtility {
  /// Converts a message to a JSON map
  /// @param message The message to convert.
  /// @returns The JSON representation of the message.
  static Map<String, dynamic> jsonDictionaryForMessage(MBMessage message) {
    Map<String, dynamic> dictionary = {
      'id': message.id,
      'title': message.title,
      'messageDescription': message.messageDescription,
      'type': _stringForMessageType(message.messageType),
      'startDate': message.startDate.millisecondsSinceEpoch ~/ 1000,
      'endDate': message.endDate.millisecondsSinceEpoch ~/ 1000,
      'automationIsOn': message.automationIsOn,
      'sendAfterDays': message.sendAfterDays,
      'repeatTimes': message.repeatTimes,
    };

    if (message.inAppMessage != null) {
      dictionary['inAppMessage'] =
          MBInAppMessageSavingUtility.jsonDictionaryForInAppMessage(
              message.inAppMessage!);
    }

    if (message.pushMessage != null) {
      dictionary['push'] =
          MBPushMessageSavingUtility.jsonDictionaryForPushMessage(
              message.pushMessage!);
    }

    if (message.triggers != null) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers triggers = message.triggers;
        dictionary['triggers'] = triggers.toJsonDictionary();
      }
    }

    return dictionary;
  }

  /// Creates and initializes a `MBMessage` from a JSON dictionary.
  /// @param jsonDictionary The JSON dictionary to convert.
  /// @returns The message created with the data of the JSON.
  static MBMessage messageFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    int id = jsonDictionary['id'];
    String title = jsonDictionary['title'];
    String messageDescription = jsonDictionary['messageDescription'];
    String messageTypeString = jsonDictionary['type'];
    MBMessageType messageType = _messageTypeForString(messageTypeString);

    int startDateInt = jsonDictionary['startDate'];
    int endDateInt = jsonDictionary['endDate'];
    bool automationIsOn = jsonDictionary['automationIsOn'];

    int sendAfterDays = jsonDictionary['sendAfterDays'];
    int repeatTimes = jsonDictionary['repeatTimes'];

    MBInAppMessage? inAppMessage;
    MBPushMessage? pushMessage;
    MBMessageTriggers? triggers;

    if (jsonDictionary['inAppMessage'] != null) {
      inAppMessage = MBInAppMessageSavingUtility.inAppMessageFromJsonDictionary(
          jsonDictionary['inAppMessage']);
    }
    if (jsonDictionary['push'] != null) {
      pushMessage = MBPushMessageSavingUtility.pushMessageFromJsonDictionary(
          jsonDictionary['push']);
    }
    if (jsonDictionary['triggers'] != null) {
      triggers =
          MBMessageTriggers.fromJsonDictionary(jsonDictionary['triggers']);
    }

    MBMessage message = MBMessage(
      id: id,
      title: title,
      messageDescription: messageDescription,
      messageType: messageType,
      startDate: DateTime.fromMillisecondsSinceEpoch(startDateInt * 1000),
      endDate: DateTime.fromMillisecondsSinceEpoch(endDateInt * 1000),
      automationIsOn: automationIsOn,
      inAppMessage: inAppMessage,
      pushMessage: pushMessage,
      sendAfterDays: sendAfterDays,
      repeatTimes: repeatTimes,
      triggers: triggers,
    );
    return message;
  }

  /// Converts the type of message to a string.
  /// @param messageType The message type to convert.
  /// @returns The string representation of the message type.
  static String _stringForMessageType(MBMessageType messageType) {
    if (messageType == MBMessageType.inAppMessage) {
      return 'in_app';
    } else if (messageType == MBMessageType.push) {
      return 'push';
    }
    return 'in_app';
  }

  /// Converts a string to a `MBMessageType`.
  /// @param messageTypeString The string to convert.
  /// @returns The MBMessageType, if the string doesn't match it returns `MBMessageType.inAppMessage`.
  static MBMessageType _messageTypeForString(String messageTypeString) {
    if (messageTypeString == 'in_app') {
      return MBMessageType.inAppMessage;
    } else if (messageTypeString == 'push') {
      return MBMessageType.push;
    }
    return MBMessageType.inAppMessage;
  }
}
