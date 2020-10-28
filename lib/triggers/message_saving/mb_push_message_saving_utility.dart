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
      dictionary['c'] = pushMessage.launchImage;
    }
    if (pushMessage.userInfo != null) {
      dictionary['userInfo'] = pushMessage.userInfo;
    }
    return dictionary;
  }

  static MBPushMessage pushMessageFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    String id = jsonDictionary['id'];
    String title = jsonDictionary['title'];
    String body = jsonDictionary['body'];
    bool sent = jsonDictionary['sent'];

    int badge = jsonDictionary['badge'];
    String sound = jsonDictionary['sound'];
    String launchImage = jsonDictionary['body'];

    Map<String, dynamic> userInfo = jsonDictionary['userInfo'];

    return MBPushMessage(
      id: id,
      title: title,
      body: body,
      sent: sent,
      badge: badge,
      sound: sound,
      launchImage: launchImage,
      userInfo: userInfo,
    );
  }
}
