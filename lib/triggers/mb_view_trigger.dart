import 'package:flutter/foundation.dart';
import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

class MBViewTrigger extends MBTrigger {
  final String view;

  final int times;

  final int secondsOnView;

  DateTime completionDate;
  int numberOfTimes;

  MBViewTrigger({
    @required String id,
    @required this.view,
    @required this.times,
    @required this.secondsOnView,
  }) : super(
          id: id,
          triggerType: MBTriggerType.view,
        );

  factory MBViewTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String view = dictionary['view_name'] ?? '';
    int times = dictionary['times'];
    int secondsOnView = dictionary['seconds_on_view'];

    return MBViewTrigger(
      id: id,
      view: view,
      times: times,
      secondsOnView: secondsOnView,
    );
  }

  bool screenViewed(MBAutomationView view) {
    if (view.view == this.view) {
      this.numberOfTimes = (this.numberOfTimes ?? 0) + 1;
      return true;
    }
    return false;
  }

  void setCompleted() {
    completionDate = DateTime.now();
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
    dictionary['view'] = view;
    dictionary['times'] = times;
    dictionary['secondsOnView'] = secondsOnView;

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
  factory MBViewTrigger.fromJsonDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String view = dictionary['view'];
    int times = dictionary['times'];
    int secondsOnView = dictionary['secondsOnView'];

    MBViewTrigger trigger = MBViewTrigger(
      id: id,
      view: view,
      times: times,
      secondsOnView: secondsOnView,
    );

    if (dictionary['completionDate'] != null) {
      trigger.completionDate = dictionary['completionDate'] * 1000;
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
    if (newTrigger is MBViewTrigger) {
      newTrigger.numberOfTimes = numberOfTimes;
      newTrigger.completionDate = completionDate;
    }
    return newTrigger;
  }

//endregion

}
