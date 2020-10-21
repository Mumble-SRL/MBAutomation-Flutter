import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';

class MBInAppMessageSavingUtility {
  static Map<String, dynamic> jsonDictionaryForInAppMessage(
      MBInAppMessage inAppMessage) {
    Map<String, dynamic> dictionary = {
      'id': inAppMessage.id,
      'style': _stringForInAppMessageStyle(inAppMessage.style),
      'duration': inAppMessage.duration,
    };
    if (inAppMessage.title != null) {
      dictionary['title'] = inAppMessage.title;
    }
    if (inAppMessage.titleColor != null) {
      dictionary['titleColor'] = inAppMessage.titleColor.value;
    }
    if (inAppMessage.body != null) {
      dictionary['body'] = inAppMessage.body;
    }
    if (inAppMessage.bodyColor != null) {
      dictionary['bodyColor'] = inAppMessage.bodyColor.value;
    }
    if (inAppMessage.image != null) {
      dictionary['image'] = inAppMessage.image;
    }
    if (inAppMessage.backgroundColor != null) {
      dictionary['backgroundColor'] = inAppMessage.backgroundColor;
    }
    if (inAppMessage.buttons != null) {
      dictionary['buttons'] =
          inAppMessage.buttons.map((b) => _jsonDictionaryForButton(b)).toList();
    }
    return dictionary;
  }

  static MBInAppMessage inAppMessageFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    //TODO:
  }

  static String _stringForInAppMessageStyle(
      MBInAppMessageStyle inAppMessageStyle) {
    switch (inAppMessageStyle) {
      case MBInAppMessageStyle.bannerTop:
        return 'banner_top';
        break;
      case MBInAppMessageStyle.bannerBottom:
        return 'banner_bottom';
        break;
      case MBInAppMessageStyle.center:
        return 'center';
        break;
      case MBInAppMessageStyle.fullscreenImage:
        return 'fullscreen_image';
        break;
    }
    return 'banner_top';
  }

  static Map<String, dynamic> _jsonDictionaryForButton(
      MBInAppMessageButton button) {
    Map<String, dynamic> dictionary = {
      'title': button.title,
      'link': button.link,
      'linkType': _stringForLinkType(button.linkType),
    };
    if (button.titleColor != null) {
      dictionary['titleColor'] = button.titleColor.value;
    }
    if (button.backgroundColor != null) {
      dictionary['backgroundColor'] = button.backgroundColor.value;
    }
    return dictionary;
  }

  static String _stringForLinkType(MBInAppMessageButtonLinkType linkType) {
    switch (linkType) {
      case MBInAppMessageButtonLinkType.link:
        return 'link';
        break;
      case MBInAppMessageButtonLinkType.inApp:
        return 'in_app';
        break;
    }
    return 'link';
  }
}
