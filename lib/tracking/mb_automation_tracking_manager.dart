import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:mbautomation/mbautomation.dart';
import 'package:mbautomation/tracking/db/mb_automation_database.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mburger/mb_manager.dart';
import 'package:http/http.dart' as http;

/// Singleton to manage the tracking of events and views.
/// Views and events are saved in a local DB and synced with the APIs every n seconds as specified by the timerTime property.
class MBAutomationTrackingManager {
  /// Singleton that manages all the tracking aspects of MBAutomation.
  static final MBAutomationTrackingManager shared =
      MBAutomationTrackingManager._internal();

  /// Internal initializer for the singleton.
  MBAutomationTrackingManager._internal();

  /// Timer time in seconds, default 10 seconds.
  int _timerTime = 10;

  /// Set the timer time to a new value and restarts the timer.
  set timerTime(int timerTime) {
    _timerTime = timerTime;
    if (_checkQueueTimer != null) {
      _checkQueueTimer?.cancel();
      startTimer();
    }
  }

  /// Returns the current timer time.
  int get timerTimer => _timerTime;

  /// The timer used to check the DB and send events/view to MBurger.
  Timer? _checkQueueTimer;

  /// If it's sending data to MBurger.
  bool _sendingData = false;

  /// Tracks a view, this function saves the view in the DB, it'll be sent when `_checkQueue()` is invoked by the timer.
  /// @param view The view to track.
  Future<void> trackView(MBAutomationView view) async {
    return _saveViewInDb(view);
  }

  /// Tracks an event, this function saves the event in the DB, it'll be sent when `_checkQueue()` is invoked by the timer.
  /// @param event The event to track.
  Future<void> trackEvent(MBAutomationEvent event) {
    return _saveEventInDb(event);
  }

  /// Starts a periodic timer with a duration of `_timerTime` seconds.
  void startTimer() {
    if (_checkQueueTimer != null) {
      _checkQueueTimer!.cancel();
    }
    _checkQueueTimer = Timer.periodic(
      Duration(seconds: _timerTime),
      (timer) => _checkQueue(),
    );
  }

  /// Stops the timer.
  void stopTimer() {
    if (_checkQueueTimer != null) {
      _checkQueueTimer!.cancel();
      _checkQueueTimer = null;
    }
  }

  /// Saves a view in the local database.
  /// @param view The view to save.
  Future<void> _saveViewInDb(MBAutomationView view) async {
    if (_trackingEnabled()) {
      await MBAutomationDatabase.saveView(view);
    }
  }

  /// Saves an event in the local database.
  /// @param event The event to save.
  Future<void> _saveEventInDb(MBAutomationEvent event) async {
    if (_trackingEnabled()) {
      await MBAutomationDatabase.saveEvent(event);
    }
  }

  /// If tracking is enabled or not, it will return the value of the `trackingEnabled` flag of the `MBAutomation` plugin.
  bool _trackingEnabled() {
    MBAutomation? plugin = MBManager.shared.pluginOf<MBAutomation>();
    return plugin?.trackingEnabled ?? false;
  }

  /// Checks the events and views saved and send them to MBurger, if it's already sending data the check is skipped.
  Future<void> _checkQueue() async {
    // If already sending data skip this cycle and do the task on next
    if (_sendingData) {
      return;
    }
    _sendingData = true;
    await _checkViewsQueue();
    await _checkEventsQueue();
    _sendingData = false;
  }

  /// Fetches views from the DB and sends them to MBurger.
  /// If the API call is successful views are removed from the DB.
  Future<void> _checkViewsQueue() async {
    List<MBAutomationView>? views = await MBAutomationDatabase.views();
    if (views == null) {
      return;
    }
    if (views.isEmpty) {
      return;
    }

    List<Map<String, dynamic>> viewsDictionaries =
        views.map((v) => v.toApiDictionary()).toList();

    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: true);

    Map<String, dynamic> parameters = <String, dynamic>{};
    parameters.addAll(defaultParameters);
    parameters['views'] = viewsDictionaries;

    var uri = Uri.https(
      MBManager.shared.endpoint,
      'api/project/client-views',
    );

    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode(parameters),
    );

    try {
      MBManager.checkResponse(response.body, checkBody: false);
      await MBAutomationDatabase.deleteViews(views);
    } catch (e) {
      debugPrint(e.toString());
    }
  }

  /// Fetches events from the DB and sends them to MBurger.
  /// If the API call is successful events are removed from the DB.
  Future<void> _checkEventsQueue() async {
    List<MBAutomationEvent>? events = await MBAutomationDatabase.events();
    if (events == null) {
      return;
    }
    if (events.isEmpty) {
      return;
    }

    List<Map<String, dynamic>> eventsDictionaries =
        events.map((v) => v.toApiDictionary()).toList();

    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: true);

    Map<String, dynamic> parameters = <String, dynamic>{};
    parameters.addAll(defaultParameters);
    parameters['events'] = eventsDictionaries;

    var uri = Uri.https(
      MBManager.shared.endpoint,
      'api/project/client-events',
    );

    var response = await http.post(
      uri,
      headers: headers,
      body: json.encode(parameters),
    );

    try {
      MBManager.checkResponse(response.body, checkBody: false);
      await MBAutomationDatabase.deleteEvents(events);
    } catch (e) {
      debugPrint(e.toString());
    }
  }
}
