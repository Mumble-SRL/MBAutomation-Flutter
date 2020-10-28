import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/message_saving/mb_in_app_message_saving_utility.dart';
import 'package:mbautomation/triggers/message_saving/mb_push_message_saving_utility.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mbmessages/push_notifications/mbpush_message.dart';

class MBMessageSavingUtility {
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
    };

    if (message.inAppMessage != null) {
      dictionary['inAppMessage'] =
          MBInAppMessageSavingUtility.jsonDictionaryForInAppMessage(
              message.inAppMessage);
    }

    if (message.pushMessage != null) {
      dictionary['push'] =
          MBPushMessageSavingUtility.jsonDictionaryForPushMessage(
              message.pushMessage);
    }

    if (message.triggers != null) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers triggers = message.triggers;
        dictionary['triggers'] = triggers.toJsonDictionary();
      }
    }

    return dictionary;
  }

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

    MBInAppMessage inAppMessage;
    MBPushMessage pushMessage;
    MBMessageTriggers triggers;

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
      triggers: triggers,
    );
    return message;
  }

  static String _stringForMessageType(MBMessageType messageType) {
    if (messageType == MBMessageType.inAppMessage) {
      return 'in_app';
    } else if (messageType == MBMessageType.push) {
      return 'push';
    }
    return 'in_app';
  }

  static MBMessageType _messageTypeForString(String messageTypeString) {
    if (messageTypeString == 'in_app') {
      return MBMessageType.inAppMessage;
    } else if (messageTypeString == 'push') {
      return MBMessageType.push;
    }
    return MBMessageType.inAppMessage;
  }
}
