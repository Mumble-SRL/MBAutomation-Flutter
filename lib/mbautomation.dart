import 'package:flutter/widgets.dart';
import 'package:mbautomation/tracking/db/mb_automation_database.dart';
import 'package:mbautomation/tracking/mb_automation_tracking_manager.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/managers/mb_automation_messages_manager.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

class MBAutomation extends MBPlugin with WidgetsBindingObserver {
  bool trackingEnabled;

  int _eventsTimerTime;

  set eventsTimerTime(int time) {
    _eventsTimerTime = time;
    MBAutomationTrackingManager.shared.timerTime = time;
  }

  int get eventsTimerTime => _eventsTimerTime;

  MBAutomation({
    this.trackingEnabled: true,
    int eventsTimerTime: 10,
  }) {
    MBAutomationDatabase.initDb();
    MBAutomationMessagesManager.startMessageTimer(time: 30);
    _eventsTimerTime = eventsTimerTime;
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
  }) {
    MBAutomationMessagesManager.tagChanged(
      tag,
      value,
    );
  }

  void locationDataUpdated(
    double latitude,
    double longitude,
  ) {
    MBAutomationMessagesManager.locationDataUpdated(
      latitude,
      longitude,
    );
  }

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
    MBAutomationMessagesManager.saveMessages(
      automationMessages,
      fromFetch: true,
    );
    MBAutomationMessagesManager.checkMessages(fromStartup: fromStartup);
  }

//endregion

  static Future<void> trackScreenView(
    String view,
    Map<String, dynamic> metadata,
  ) async {
    MBAutomationView automationView =
        MBAutomationView(view: view, metadata: metadata);
    MBAutomationMessagesManager.screenViewed(automationView);
    MBAutomationTrackingManager.shared.trackView(automationView);
  }

  static Future<void> sendEvent(
    String event, {
    String name,
    Map<String, dynamic> metadata,
  }) async {
    MBAutomationEvent automationEvent = MBAutomationEvent(
      event: event,
      name: name,
      metadata: metadata,
    );
    MBAutomationMessagesManager.eventHappened(automationEvent);
    MBAutomationTrackingManager.shared.trackEvent(automationEvent);
  }

  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MBAutomationMessagesManager.checkMessages(fromStartup: false);
    }
  }
}
