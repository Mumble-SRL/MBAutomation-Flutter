import 'package:flutter/foundation.dart';

/// The type of trigger.
enum MBTriggerType {
  /// A location trigger.
  location,

  /// An app opening trigger.
  appOpening,

  /// A view trigger.
  view,

  /// An inactive user trigger.
  inactiveUser,

  /// An event trigger.
  event,

  /// A tag change trigger.
  tagChange,

  /// An unknown type trigger.
  unknown,
}

/// A general trigger for automation, you should always use and see subclasses of this.
class MBTrigger {
  /// The id of the trigger.
  final String id;

  /// The type of trigger.
  final MBTriggerType triggerType;

  /// Initializes a trigger with an id and a type.
  /// @param id The id of the trigger.
  /// @param triggerType The type of trigger.
  MBTrigger({
    @required this.id,
    @required this.triggerType,
  });

  /// Initializes a trigger with the data of the dictionary returned by the APIs.
  /// The type of trigger is set to `MBTriggerType.unknown`.
  factory MBTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    return MBTrigger(
      id: id,
      triggerType: MBTriggerType.unknown,
    );
  }

  /// If the trigger is valid or not.
  /// @param fromAppStartup If the check has been triggered at the app startup
  /// @returns If the trigger is valid or not.
  Future<bool> isValid(bool fromAppStartup) async {
    return false;
  }

//region json
  /// Converts the trigger to a JSON dictionary.
  /// @returns The JSON representation of the trigger.
  Map<String, dynamic> toJsonDictionary() {
    return {
      'id': id,
      'type': MBTrigger._stringFromTriggerType(triggerType),
    };
  }

  /// Initializes a trigger from a JSON dictionary.
  /// @param dictionary The JSON dictionary.
  factory MBTrigger.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String triggerTypeString = dictionary['type'];
    MBTriggerType triggerType =
        MBTrigger.triggerTypeFromString(triggerTypeString);
    return MBTrigger(
      id: id,
      triggerType: triggerType,
    );
  }
//endregion

//region trigger type conversions
  /// Converts a `MBTriggerType` to a string.
  /// @param triggerType The trigger type.
  /// @returns The string representation of the trigger type.
  static String _stringFromTriggerType(MBTriggerType triggerType) {
    switch (triggerType) {
      case MBTriggerType.location:
        return 'location';
        break;
      case MBTriggerType.appOpening:
        return 'app_opening';
        break;
      case MBTriggerType.view:
        return 'view';
        break;
      case MBTriggerType.inactiveUser:
        return 'inactive_user';
        break;
      case MBTriggerType.event:
        return 'event';
        break;
      case MBTriggerType.tagChange:
        return 'tag_change';
        break;
      case MBTriggerType.unknown:
        return 'unknown';
        break;
    }
    return 'unknown';
  }

  /// Converts a string to a `MBTriggerType`.
  /// @param triggerTypeString The string that represents the trigger type.
  /// @returns The MBTriggerType that matches the string, if no match is found it returns `MBTriggerType.unknown`.
  static MBTriggerType triggerTypeFromString(String triggerTypeString) {
    switch (triggerTypeString) {
      case 'location':
        return MBTriggerType.location;
        break;
      case 'app_opening':
        return MBTriggerType.appOpening;
        break;
      case 'view':
        return MBTriggerType.view;
        break;
      case 'inactive_user':
        return MBTriggerType.inactiveUser;
        break;
      case 'event':
        return MBTriggerType.event;
        break;
      case 'tag_change':
        return MBTriggerType.tagChange;
        break;
      case 'unknown':
        return MBTriggerType.unknown;
        break;
    }
    return MBTriggerType.unknown;
  }
//endregion

//region update trigger

  /// Updates the trigger with the new info; by defaults no action is done.
  /// @param newTrigger The new trigger from which info will be copied.
  /// @returns The updated trigger.
  MBTrigger updatedTrigger(MBTrigger newTrigger) {
    return newTrigger;
  }

//endregion
}
