import 'package:flutter/widgets.dart';
import 'package:mbautomation/tracking/mb_automation_tracking_manager.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

class MBAutomation extends MBPlugin with WidgetsBindingObserver {
  bool trackingEnabled;

  MBAutomation({
    this.trackingEnabled: true,
    int eventsTimerTime: 10,
  }) {
    //TODO: setup DB tables
    //MBAutomationMessagesManager.startMessagesTimer(time: 30.0)
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
  ) {}

//endregion

  Future<void> trackScreenView() {}

  Future<void> sendEvent(
    String event, {
    String name,
    Map<String, dynamic> metadata,
  }) {}


  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      //TODO: MBAutomationMessagesManager.checkMessages
    }
  }
}
