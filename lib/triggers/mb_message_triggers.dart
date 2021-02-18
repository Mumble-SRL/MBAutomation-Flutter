import 'package:flutter/foundation.dart';
import 'package:mbautomation/triggers/managers/mb_automation_messages_manager.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

/// The method used to check triggers.
enum MBMessageTriggersMethod {
  /// The message trigger is valid if any of the triggers is valid.
  any,

  /// The message trigger is valid when all of the triggers are valid.
  all,
}

/// This class represents the triggers of a message.
class MBMessageTriggers {
  /// The method to check the messages.
  MBMessageTriggersMethod method;

  /// The list of triggers.
  List<MBTrigger> triggers;

  /// Initialized triggers for a message with the data passed.
  MBMessageTriggers({
    @required this.method,
    @required this.triggers,
  });

  /// Initializes message triggers with the data of the dictionary returned by the APIs.
  MBMessageTriggers.fromDictionary(Map<String, dynamic> dictionary) {
    String methodString = dictionary['method'];
    if (methodString == 'all') {
      method = MBMessageTriggersMethod.all;
    } else if (methodString == 'any') {
      method = MBMessageTriggersMethod.any;
    } else {
      method = MBMessageTriggersMethod.all;
    }

    List<MBTrigger> triggers = [];
    if (dictionary['triggers'] != null && dictionary['triggers'] is List) {
      List triggersDict = dictionary['triggers'];
      for (dynamic triggerDict in triggersDict) {
        if (triggerDict is Map<String, dynamic>) {
          triggers.add(
              MBAutomationMessagesManager.triggerFromDictionary(triggerDict));
        }
      }
    }
    this.triggers = triggers;
  }

  /// If the trigger is valid, based on the triggers method and all the triggers.
  /// @param fromAppStartup If the check has been triggered at startup.
  /// @returns If the trigger is valid.
  Future<bool> isValid(bool fromAppStartup) async {
    if (triggers == null) {
      return true;
    }
    for (MBTrigger trigger in triggers) {
      bool triggerIsValid = await trigger.isValid(fromAppStartup);
      switch (method) {
        case MBMessageTriggersMethod.any:
          if (triggerIsValid) {
            return true;
          }
          break;
        case MBMessageTriggersMethod.all:
          if (!triggerIsValid) {
            return false;
          }
      }
    }
    return method == MBMessageTriggersMethod.any ? false : true;
  }

  /// Creates and initializes the trigger with a saved JSON dictionary.
  MBMessageTriggers.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String methodString = dictionary['method'];
    method = MBMessageTriggers._triggersMethodFromString(methodString);

    if (dictionary['triggers'] != null) {
      if (dictionary['triggers'] is List) {
        List<Map<String, dynamic>> triggersDictionaries =
            List.castFrom<dynamic, Map<String, dynamic>>(
                dictionary['triggers']);
        triggers = triggersDictionaries
            .map(
                (t) => MBAutomationMessagesManager.triggerFromJsonDictionary(t))
            .toList();
      }
    }
  }

  /// Converts the trigger object to a JSON map.
  Map<String, dynamic> toJsonDictionary() {
    Map<String, dynamic> dictionary = {
      'method': _stringFromTriggersMethod(method),
    };

    if (triggers != null) {
      dictionary['triggers'] =
          triggers.map((e) => e.toJsonDictionary()).toList();
    }

    return dictionary;
  }

  ///  Updates all the triggers with the new triggers,
  ///  this function is called by the manager after new messages are received to update values of triggers if necessary.
  void updateTriggers(MBMessageTriggers newTriggers) {
    List<MBTrigger> updatedTriggers = [];
    for (MBTrigger newTrigger in newTriggers.triggers) {
      MBTrigger trigger = triggers.firstWhere(
        (t) => t.id == newTrigger.id,
        orElse: () => null,
      );
      if (trigger != null) {
        MBTrigger updatedTrigger = trigger.updatedTrigger(newTrigger);
        updatedTriggers.add(updatedTrigger);
      } else {
        updatedTriggers.add(newTrigger);
      }
    }
    this.triggers = updatedTriggers;
  }

//region triggers method conversions
  static MBMessageTriggersMethod _triggersMethodFromString(
      String triggersMethodString) {
    switch (triggersMethodString) {
      case 'all':
        return MBMessageTriggersMethod.all;
        break;
      case 'any':
        return MBMessageTriggersMethod.any;
        break;
    }
    return MBMessageTriggersMethod.all;
  }

  String _stringFromTriggersMethod(MBMessageTriggersMethod triggersMethod) {
    switch (triggersMethod) {
      case MBMessageTriggersMethod.all:
        return 'all';
        break;
      case MBMessageTriggersMethod.any:
        return 'any';
        break;
    }
    return 'all';
  }
//endregion

}
