import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:mbmessages/messages/mbmessage.dart';

class MBAutomationMessagesManager {
  static Timer timer;

  static void setTriggersToMessages(List<MBMessage> messages) {
    if (messages == null) {
      return;
    }
    for (MBMessage message in messages) {
      if (message.automationIsOn) {
        if (message.triggers != null &&
            message.triggers is Map<String, dynamic>) {
          message.triggers = MBMessageTriggers.fromDictionary(message.triggers);
        }
      }
    }
  }

  static MBTrigger triggerForDictionary(Map<String, dynamic> dictionary) {
    //TODO:
    return null;
  }

  static startMessageTimer({@required int time}) {
    timer = Timer.periodic(
      Duration(seconds: time),
      (timer) => checkMessages(),
    );
  }

  static messageTimerChanged({@required int time}) {
    if (timer != null) {
      timer.cancel();
      timer = null;
    }
    timer = Timer.periodic(
      Duration(seconds: time),
          (timer) => checkMessages(),
    );
  }

  static void checkMessages() {

  }
}
