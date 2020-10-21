import 'package:mbmessages/push_notifications/mbpush_message.dart';

class MBPushMessageSavingUtility {
  static Map<String, dynamic> jsonDictionaryForPushMessage(
      MBPushMessage pushMessage) {
    Map<String, dynamic> dictionary = {
      'id': pushMessage.id,
      'title': pushMessage.title,
      'body': pushMessage.body,
      'sent': pushMessage.sent,
    };

    if (pushMessage.badge != null) {
      dictionary['badge'] = pushMessage.badge;
    }
    if (pushMessage.sound != null) {
      dictionary['sound'] = pushMessage.sound;
    }
    if (pushMessage.launchImage != null) {
      dictionary['launchImage'] = pushMessage.launchImage;
    }
    if (pushMessage.userInfo != null) {
      dictionary['userInfo'] = pushMessage.userInfo;
    }
    return dictionary;
  }

  static MBPushMessage pushMessageFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    //TODO:
  }
}
