import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:flutter/foundation.dart';

class MBEventTrigger extends MBTrigger {
  final String event;

  final int times;

  final Map<String, dynamic> metadata;

  DateTime completionDate;
  int numberOfTimes;

  MBEventTrigger({
    @required String id,
    @required this.event,
    @required this.times,
    @required this.metadata,
  }) : super(
          id: id,
          triggerType: MBTriggerType.event,
        );

  factory MBEventTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String event = dictionary['event_name'] ?? '';

    int times = dictionary['times'] ?? 1;
    Map<String, dynamic> metadata = dictionary['metadata'];

    return MBEventTrigger(
      id: id,
      event: event,
      times: times,
      metadata: metadata,
    );
  }

  /// Function called when an event happen
  /// - Returns: If the trigger has changed
  Future<bool> eventHappened(MBAutomationEvent event) async {
    if (event.event != this.event) {
      return false;
    }
    bool isTriggerEvent = true;
    if (event.metadata != null) {
      if (this.metadata != null) {
        isTriggerEvent = mapEquals(
          event.metadata,
          this.metadata,
        );
      } else {
        isTriggerEvent = false;
      }
    } else if (this.metadata != null) {
      isTriggerEvent = false;
    }

    if (isTriggerEvent) {
      int currentNumberOfTimes = numberOfTimes ?? 0;
      currentNumberOfTimes += 1;
      numberOfTimes = currentNumberOfTimes;
      if (numberOfTimes >= times) {
        completionDate = DateTime.now();
        return true;
      }
      return true;
    } else {
      return false;
    }
  }

  @override
  Future<bool> isValid(bool fromAppStartup) async {
    if (completionDate == null) {
      return false;
    }
    return completionDate.isBefore(DateTime.now());
  }

//region json
  @override
  Map<String, dynamic> toJsonDictionary() {
    Map<String, dynamic> dictionary = super.toJsonDictionary();
    dictionary['event'] = event;
    dictionary['times'] = times;
    dictionary['metadata'] = metadata;
    if (completionDate != null) {
      dictionary['completionDate'] =
          completionDate.millisecondsSinceEpoch ~/ 1000;
    }
    if (numberOfTimes != null) {
      dictionary['numberOfTimes'] = numberOfTimes;
    }
    return dictionary;
  }

  @override
  factory MBEventTrigger.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String event = dictionary['event'];
    int times = dictionary['times'];
    Map<String, dynamic> metadata = dictionary['metadata'];

    MBEventTrigger trigger = MBEventTrigger(
      id: id,
      event: event,
      times: times,
      metadata: metadata,
    );

    if (dictionary['completionDate'] != null) {
      int completionDateTimestamp = dictionary['completionDate'];
      trigger.completionDate =
          DateTime.fromMicrosecondsSinceEpoch(completionDateTimestamp * 1000);
    }
    if (dictionary['numberOfTimes'] != null) {
      trigger.numberOfTimes = dictionary['numberOfTimes'];
    }

    return trigger;
  }
//endregion
}
