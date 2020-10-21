import 'package:flutter/widgets.dart';
import 'package:mbautomation/tracking/mb_automation_tracking_manager.dart';
import 'package:mbautomation/triggers/mb_automation_messages_manager.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

class MBAutomation extends MBPlugin with WidgetsBindingObserver {
  bool trackingEnabled;

  MBAutomation({
    this.trackingEnabled: true,
    int eventsTimerTime: 10,
  }) {
    //TODO: setup DB tables for events & views
    MBAutomationMessagesManager.startMessageTimer(time: 30);
    MBAutomationTrackingManager.shared.timerTime = eventsTimerTime;
    WidgetsBinding.instance.addObserver(this);
  }

//region plugin
  int startupOrder = 3;

  @override
  Future<void> startupBlock() async {
    MBAutomationTrackingManager.shared.startTimer();
  }

  void tagChanged(
    String tag, {
    String value,
  }) {}

  void locationDataUpdated(
    double latitude,
    double longitude,
  ) {}

  void messagesReceived(
    List<dynamic> messages,
    bool fromStartup,
  ) {
    List<MBMessage> automationMessages = [];
    for (dynamic message in messages) {
      if (message is MBMessage) {
        if (message.automationIsOn) {
          automationMessages.add(message);
        }
      }
    }
  }

//endregion

  Future<void> trackScreenView() async {}

  Future<void> sendEvent(
    String event, {
    String name,
    Map<String, dynamic> metadata,
  }) async {}

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MBAutomationMessagesManager.checkMessages();
    }
  }
}
