import 'package:mbautomation/tracking/model/mb_automation_event.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';
import 'package:flutter/foundation.dart';

/// An event opening trigger that becomes true if an event happens.
class MBEventTrigger extends MBTrigger {
  /// The event that needs to happen.
  final String event;

  /// The number of times the event needs to happen.
  final int times;

  /// Metadata associated with the event.
  final Map<String, dynamic>? metadata;

  /// If the trigger has been completed this var will have the date the event has been completed.
  DateTime? completionDate;

  /// Counter to keeps track of how many times an event has happened.
  int? numberOfTimes;

  /// Initializes an event trigger with the data provided.
  MBEventTrigger({
    required String id,
    required this.event,
    required this.times,
    this.metadata,
  }) : super(
          id: id,
          triggerType: MBTriggerType.event,
        );

  /// Initializes an event trigger with the data of the dictionary returned by the APIs.
  factory MBEventTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String event = dictionary['event_name'] ?? '';

    int times = dictionary['times'] ?? 1;
    Map<String, dynamic>? metadata = dictionary['metadata'];

    return MBEventTrigger(
      id: id,
      event: event,
      times: times,
      metadata: metadata,
    );
  }

  /// Function called when an event happen.
  /// @param event The event that happened.
  /// @returns If the trigger has changed.
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
      if (currentNumberOfTimes >= times) {
        completionDate = DateTime.now();
        return true;
      }
      return true;
    } else {
      return false;
    }
  }

  /// If the trigger is valid or not.
  /// @param fromAppStartup If the check has been triggered at the app startup
  /// @returns If the trigger is valid or not.
  @override
  Future<bool> isValid(bool fromAppStartup) async {
    if (completionDate == null) {
      return false;
    }
    return completionDate!.isBefore(DateTime.now());
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
          completionDate!.millisecondsSinceEpoch ~/ 1000;
    }
    if (numberOfTimes != null) {
      dictionary['numberOfTimes'] = numberOfTimes;
    }
    return dictionary;
  }

  @override
  factory MBEventTrigger.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String event = dictionary['event'] ?? '';
    int times = dictionary['times'] ?? 0;
    Map<String, dynamic>? metadata = dictionary['metadata'];

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

//region update trigger

  @override
  MBTrigger updatedTrigger(MBTrigger newTrigger) {
    if (newTrigger is MBEventTrigger) {
      newTrigger.numberOfTimes = numberOfTimes;
      newTrigger.completionDate = completionDate;
    }
    return newTrigger;
  }

//endregion

}
