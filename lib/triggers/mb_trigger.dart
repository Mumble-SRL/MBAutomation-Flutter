import 'package:flutter/foundation.dart';

enum MBTriggerType {
  location,
  appOpening,
  view,
  inactiveUser,
  event,
  tagChange,
  unknown,
}

class MBTrigger {
  final String id;

  final MBTriggerType triggerType;

  MBTrigger({
    @required this.id,
    @required this.triggerType,
  });

  factory MBTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    return MBTrigger(
      id: id,
      triggerType: MBTriggerType.unknown,
    );
  }

  Future<bool> isValid(bool fromAppStartup) async {
    return false;
  }

//region json
  Map<String, dynamic> toJsonDictionary() {
    return {
      'id': id,
      'type': MBTrigger._stringFromTriggerType(triggerType),
    };
  }

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

  /// Updates the trigger with the new infos
  /// By defaults no action is don
  MBTrigger updatedTrigger(MBTrigger newTrigger) {
    return newTrigger;
  }

//endregion
}
