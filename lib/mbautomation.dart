import 'package:flutter/widgets.dart';
import 'package:mbautomation/tracking/db/mb_automation_database.dart';
import 'package:mbautomation/tracking/mb_automation_tracking_manager.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/managers/mb_automation_messages_manager.dart';
import 'package:mbmessages/messages/mbmessage.dart';
import 'package:mburger/mb_plugin/mb_plugin.dart';

import 'mbautomation_plugin.dart';

export 'package:mbautomation/tracking/mbautomation_navigator_observer.dart';

/// The automation plugin of MBurger, you can use this to show in app messages and push notifications based on the behavior of the user.
class MBAutomation extends MBPlugin with WidgetsBindingObserver {
  /// If tracking is enabled for this plugin, if this is false all events and views will not be saved and sent to the server.
  bool trackingEnabled;

  /// The frequency used to send events and view to MBurger.
  int _eventsTimerTime;

  /// Set the frequency used to send events and view to MBurger.
  set eventsTimerTime(int time) {
    _eventsTimerTime = time;
    MBAutomationTrackingManager.shared.timerTime = time;
  }

  /// Returns the frequency used to send events and view to MBurger.
  int get eventsTimerTime => _eventsTimerTime;

  /// Initializes the plugin with the parameters passed.
  /// @param trackingEnabled If the tracking is enabled, default to `true`.
  /// @param eventsTimerTime The frequency used to send events and view to MBurger (in seconds), default 10.
  MBAutomation({
    this.trackingEnabled: true,
    int eventsTimerTime: 10,
  }) {
    MBAutomationDatabase.initDb();
    MBAutomationMessagesManager.startMessageTimer(time: 30);
    _eventsTimerTime = eventsTimerTime;
    MBAutomationFlutterPlugin.initializeMethodCall();
    MBAutomationTrackingManager.shared.timerTime = eventsTimerTime;
    WidgetsBinding.instance.addObserver(this);
  }

//region plugin
  /// The order of startup for this plugin, in MBurger
  int startupOrder = 3;

  /// The function run at startup by MBurger, initializes the plugin and do the startup work.
  /// It start the timer to check and send events and views to the server.
  @override
  Future<void> startupBlock() async {
    MBAutomationTrackingManager.shared.startTimer();
  }

  /// Invoked by the MBurger plugins manager when a tag changes in the `MBAudience` plugin.
  /// @param tag The tag.
  /// @param value: The value of the tag, `null` if the tag has been deleted.
  void tagChanged(
    String tag, {
    String value,
  }) {
    MBAutomationMessagesManager.tagChanged(
      tag,
      value,
    );
  }

  /// Invoked by the MBurger plugins manager when new location data is available in the `MBAudience` plugin.
  /// @param latitude The new latitude.
  /// @param longitude: The new longitude.
  void locationDataUpdated(
    double latitude,
    double longitude,
  ) {
    MBAutomationMessagesManager.locationDataUpdated(
      latitude,
      longitude,
    );
  }

  /// Invoked by the MBurger plugins manager when new messages are received by the `MBMessages` plugin.
  /// This function parse the triggers array, creates triggers objects and updates the saved messages where automation is enabled.
  /// @param messages The messages received, the triggers property will be populated with a `MBTrigger` object.
  /// @param fromStartup If messages has been retrieved at app startup
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

  /// Tracks a screen view manually.
  /// @param view The name of the view.
  /// @param metadata Optional metadata associated with the view.
  static Future<void> trackScreenView(
    String view, {
    Map<String, dynamic> metadata,
  }) async {
    MBAutomationView automationView =
        MBAutomationView(view: view, metadata: metadata);
    MBAutomationMessagesManager.screenViewed(automationView);
    MBAutomationTrackingManager.shared.trackView(automationView);
  }

  /// Send and event with automation
  /// @param event The event.
  /// @param name The name of the event that will be displayed on MBurger dashboard
  /// @param metadata Additional metadata sent with the event
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

  /// WidgetBindingsObserver function, when the app is resumed automation checks the triggers in case something has changed.
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      MBAutomationMessagesManager.checkMessages(fromStartup: false);
    }
  }
}
