import 'dart:async';
import 'dart:convert';

import 'package:mbautomation/mbautomation.dart';
import 'package:mbautomation/tracking/db/mb_automation_database.dart';
import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mburger/mb_manager.dart';
import 'package:http/http.dart' as http;

class MBAutomationTrackingManager {
  static final MBAutomationTrackingManager shared =
      MBAutomationTrackingManager._internal();

  MBAutomationTrackingManager._internal();

  int _timerTime = 10;

  set timerTime(int timerTime) {
    _timerTime = timerTime;
    if (_checkQueueTimer != null) {
      _checkQueueTimer.cancel();
      startTimer();
    }
  }

  int get timerTimer => _timerTime;

  Timer _checkQueueTimer;

  bool _sendingData = false;

  Future<void> trackView(MBAutomationView view) async {
    return _saveViewInDb(view);
  }

  Future<void> trackEvent(MBAutomationEvent event) {
    return _saveEventInDb(event);
  }

  void startTimer() {
    if (_checkQueueTimer != null) {
      _checkQueueTimer.cancel();
    }
    _checkQueueTimer = Timer.periodic(
      Duration(seconds: _timerTime),
      (timer) => _checkQueue(),
    );
  }

  void stopTimer() {
    if (_checkQueueTimer != null) {
      _checkQueueTimer.cancel();
      _checkQueueTimer = null;
    }
  }

  Future<void> _saveViewInDb(MBAutomationView view) async {
    if (_trackingEnabled()) {
      await MBAutomationDatabase.saveView(view);
    }
  }

  Future<void> _saveEventInDb(MBAutomationEvent event) async {
    if (_trackingEnabled()) {
      await MBAutomationDatabase.saveEvent(event);
    }
  }

  bool _trackingEnabled() {
    MBAutomation plugin = MBManager.shared.pluginOf<MBAutomation>();
    return plugin?.trackingEnabled ?? false;
  }

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

  Future<void> _checkViewsQueue() async {
    List<MBAutomationView> views = await MBAutomationDatabase.views();
    if (views == null) {
      return;
    }
    if (views.length == 0) {
      return;
    }

    List<Map<String, dynamic>> viewsDictionaries =
        views.map((v) => v.toApiDictionary()).toList();

    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: false);

    Map<String, dynamic> parameters = Map<String, dynamic>();
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
      print(e);
    }
  }

  Future<void> _checkEventsQueue() async {
    List<MBAutomationEvent> events = await MBAutomationDatabase.events();
    if (events == null) {
      return;
    }
    if (events.length == 0) {
      return;
    }

    List<Map<String, dynamic>> eventsDictionaries =
        events.map((v) => v.toApiDictionary()).toList();

    var defaultParameters = await MBManager.shared.defaultParameters();
    var headers = await MBManager.shared.headers(contentTypeJson: false);

    Map<String, dynamic> parameters = Map<String, dynamic>();
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
      print(e);
    }
  }
}
