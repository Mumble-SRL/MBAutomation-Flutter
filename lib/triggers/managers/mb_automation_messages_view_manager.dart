import 'dart:async';

import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/managers/mb_automation_messages_manager.dart';
import 'package:mbautomation/triggers/mb_message_triggers.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:mbautomation/triggers/mb_view_trigger.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:collection/collection.dart';

/// This class manages the view triggers, it's informed when a screen is viewed and it informs all the MBViewTrigger triggers.
class MBAutomationMessagesViewManager {
  /// Timer to set a screen as viewed after the seconds specified in the trigger.
  static Timer? _timer;

  /// Function called by `MBAutomationMessagesManager` when a screen is viewed.
  /// @param view The view that has been viewed.
  static Future<void> screenViewed(MBAutomationView view) async {
    if (_timer != null) {
      _timer?.cancel();
    }
    List<MBMessage>? messagesSaved =
        await MBAutomationMessagesManager.savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.length == 0) {
      return;
    }

    bool somethingChanged = false;
    for (MBMessage message in messagesSaved) {
      if (message.triggers is MBMessageTriggers) {
        MBMessageTriggers messageTriggers = message.triggers;
        List<MBViewTrigger> viewTriggers =
            List.castFrom<MBTrigger, MBViewTrigger>(messageTriggers.triggers
                .where((t) => t is MBViewTrigger)
                .toList());
        for (MBViewTrigger viewTrigger in viewTriggers) {
          bool result = viewTrigger.screenViewed(view);
          if (result) {
            somethingChanged = true;
            if ((viewTrigger.numberOfTimes ?? 0) >= viewTrigger.times) {
              int index = messageTriggers.triggers.indexOf(viewTrigger);
              if ((viewTrigger.secondsOnView) != 0) {
                _timer = Timer(
                  Duration(seconds: viewTrigger.secondsOnView),
                  () => _setTriggerCompleted(message.id, index),
                );
              } else {
                _setTriggerCompleted(message.id, index);
              }
            }
          }
        }
      }
    }
    if (somethingChanged) {
      MBAutomationMessagesManager.saveMessages(
        messagesSaved,
        fromFetch: false,
      );
    }
  }

  /// Sets a trigger as completed.
  /// @param messageId The id of the message.
  /// @param triggerIndex The index of the trigger that will be set as completed.
  static Future<void> _setTriggerCompleted(
    int messageId,
    int triggerIndex,
  ) async {
    List<MBMessage>? messagesSaved =
        await MBAutomationMessagesManager.savedMessages();
    if (messagesSaved == null) {
      return;
    }
    if (messagesSaved.length == 0) {
      return;
    }

    MBMessage? message =
        messagesSaved.firstWhereOrNull((m) => m.id == messageId);

    if (message == null) {
      return;
    }

    if (message.triggers is MBMessageTriggers) {
      MBMessageTriggers messageTriggers = message.triggers;
      if (triggerIndex < messageTriggers.triggers.length) {
        MBTrigger trigger = messageTriggers.triggers[triggerIndex];
        if (trigger is MBViewTrigger) {
          trigger.setCompleted();
          await MBAutomationMessagesManager.saveMessages(
            messagesSaved,
            fromFetch: false,
          );
          await MBAutomationMessagesManager.checkMessages(fromStartup: false);
        }
      }
    }
  }
}
