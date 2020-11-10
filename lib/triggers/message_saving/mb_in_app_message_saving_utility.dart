import 'dart:ui';
import 'package:mbmessages/in_app_messages/mb_in_app_message.dart';
import 'package:mbmessages/in_app_messages/mb_in_app_message_button.dart';

/// Utility class to convert in app messages to JSON and initialize a message from a JSON
class MBInAppMessageSavingUtility {
  /// Converts an in app message to a JSON dictionary
  /// @param inAppMessage The in app message to convert.
  /// @returns The Map that represent the in app message.
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
      dictionary['backgroundColor'] = inAppMessage.backgroundColor.value;
    }
    if (inAppMessage.buttons != null) {
      dictionary['buttons'] =
          inAppMessage.buttons.map((b) => _jsonDictionaryForButton(b)).toList();
    }
    return dictionary;
  }

  /// Creates and initializes an in app message object from a JSON object.
  /// @param jsonDictionary The dictionary from the JSON.
  /// @returns The in app message created.
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

  /// Converts the string represent the in app message style to the corresponding enum.
  /// @param styleString The string that represent the in app message style.
  /// @returns The corresponding `MBInAppMessageStyle`.
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

  /// Converts a `MBInAppMessageStyle` to a string, to save it as JSON.
  /// @param inAppMessageStyle The message style that will be converted.
  /// @returns The striing representation.
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

  /// Converts a `MBInAppMessageButton` to save it in a JSON.
  /// @param button The `MBInAppMessageButton` to convert.
  /// @returns The JSON representation of the in app message button.
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

  /// Creates and initializes a `MBInAppMessageButton` from a JSON map.
  /// @param jsonDictionary The JSON representation of the in app message button.
  /// @returns The `MBInAppMessageButton` created.
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

  /// Converts a `MBInAppMessageButtonLinkType` to a string, to save it as JSON.
  /// @param linkType The link type to convert.
  /// @returns The string representation of the link type.
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
