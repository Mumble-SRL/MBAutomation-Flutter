import 'package:flutter/cupertino.dart';
import 'package:mbautomation/triggers/mb_automation_messages_manager.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

enum MBMessageTriggersMethod {
  any,
  all,
}

class MBMessageTriggers {
  MBMessageTriggersMethod method;
  List<MBTrigger> triggers;

  MBMessageTriggers({
    @required this.method,
    @required this.triggers,
  });

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
          triggers.add(MBTrigger.fromDictionary(triggerDict));
        }
      }
    }
  }

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
    return true;
  }

  MBMessageTriggers.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String methodString = dictionary['method'];
    method = MBMessageTriggers._triggersMethodFromString(methodString);

    if (dictionary['triggers'] != null) {
      if (dictionary['triggers'] is List) {
        List<Map<String, dynamic>> triggersDictionaries =
            dictionary['triggers'];
        triggers = triggersDictionaries
            .map((t) => MBAutomationMessagesManager.triggerForDictionary(t))
            .toList();
      }
    }
  }

  Map<String, dynamic> toJsonDictionary() {
    Map<String, dynamic> dictionary = {
      'method': _stringFromTriggersMethod(method),
    };

    if (triggers != null) {
      dictionary['triggers'] = triggers.map((e) => e.toJsonDictionary());
    }

    return dictionary;
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
