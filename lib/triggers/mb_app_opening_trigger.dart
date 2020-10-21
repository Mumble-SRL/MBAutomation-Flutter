import 'package:flutter/cupertino.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

class MBAppOpeningTrigger extends MBTrigger {
  final int times;

  MBAppOpeningTrigger({
    @required String id,
    @required this.times,
  }) : super(
          id: id,
          triggerType: MBTriggerType.appOpening,
        );

  factory MBAppOpeningTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    int times = dictionary['times'] ?? 0;

    return MBAppOpeningTrigger(id: id, times: times);
  }

  @override
  Future<bool> isValid(bool fromAppStartup) async {
    if (!fromAppStartup) {
      return false;
    }
    int currentSession = await MBAudience.currentSession;
    return currentSession >= times;
  }

//region json
  @override
  Map<String, dynamic> toJsonDictionary() {
    Map<String, dynamic> dictionary = super.toJsonDictionary();
    dictionary['times'] = times;
    return dictionary;
  }

  @override
  factory MBAppOpeningTrigger.fromJsonDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    int times = dictionary['times'];
    return MBAppOpeningTrigger(
      id: id,
      times: times,
    );
  }
//endregion
}
