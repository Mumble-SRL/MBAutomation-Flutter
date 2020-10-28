import 'dart:ui';

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
    int id = jsonDictionary['id'];
    String styleString = jsonDictionary['style'];
    double duration = jsonDictionary['duration'];

    String title = jsonDictionary['title'];
    int titleColor = jsonDictionary['titleColor'];

    String body = jsonDictionary['body'];
    int bodyColor = jsonDictionary['bodyColor'];

    String image = jsonDictionary['image'];

    int backgroundColor = jsonDictionary['backgroundColor'];

    List<MBInAppMessageButton> buttons;
    if (jsonDictionary['buttons'] != null) {
      buttons = [];
      List<Map<String, dynamic>> buttonsDictionaries =
          List.castFrom<dynamic, Map<String, dynamic>>(
              jsonDictionary['buttons']);
      for (Map<String, dynamic> buttonDictionary in buttonsDictionaries) {
        buttons.add(
            MBInAppMessageSavingUtility._inAppMessageButtonFromJsonDictionary(
                buttonDictionary));
      }
    }

    return MBInAppMessage(
      id: id,
      style: _inAppMessageStyleForString(styleString),
      duration: duration,
      title: title,
      titleColor: Color(titleColor),
      body: body,
      bodyColor: Color(bodyColor),
      image: image,
      backgroundColor: Color(backgroundColor),
      buttons: buttons,
    );
  }

  static MBInAppMessageStyle _inAppMessageStyleForString(String styleString) {
    switch (styleString) {
      case 'banner_top':
        return MBInAppMessageStyle.bannerTop;
        break;
      case 'banner_bottom':
        return MBInAppMessageStyle.bannerBottom;
        break;
      case 'center':
        return MBInAppMessageStyle.center;
        break;
      case 'fullscreen_image':
        return MBInAppMessageStyle.fullscreenImage;
        break;
    }
    return MBInAppMessageStyle.bannerTop;
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

  static MBInAppMessageButton _inAppMessageButtonFromJsonDictionary(
      Map<String, dynamic> jsonDictionary) {
    String title = jsonDictionary['title'];
    String link = jsonDictionary['link'];
    String linkType = jsonDictionary['linkType'];
    int titleColor = jsonDictionary['titleColor'];
    int backgroundColor = jsonDictionary['backgroundColor'];

    return MBInAppMessageButton(
      title: title,
      titleColor: Color(titleColor),
      backgroundColor: Color(backgroundColor),
      link: link,
      linkTypeString: linkType,
    );
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
