import 'package:flutter/foundation.dart';
import 'package:mbaudience/mbaudience.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

class MBInactiveUserTrigger extends MBTrigger {
  final int days;

  MBInactiveUserTrigger({
    @required String id,
    @required this.days,
  }) : super(
          id: id,
          triggerType: MBTriggerType.inactiveUser,
        );

  factory MBInactiveUserTrigger.fromDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    int days = dictionary['days'];

    return MBInactiveUserTrigger(
      id: id,
      days: days,
    );
  }

  @override
  Future<bool> isValid(bool fromAppStartup) async {
    if (!fromAppStartup) {
      return false;
    }
    int currentSession = await MBAudience.currentSession;
    DateTime currentDate =
        await MBAudience.startSessionDateForSession(currentSession);
    if (currentDate == null) {
      return false;
    }
    DateTime lastSessionDate =
        await MBAudience.startSessionDateForSession(currentSession - 1);
    if (lastSessionDate == null) {
      return false;
    }
    int days = currentDate.difference(lastSessionDate).inDays.abs();
    return days >= this.days;
  }

//region json
  @override
  Map<String, dynamic> toJsonDictionary() {
    Map<String, dynamic> dictionary = super.toJsonDictionary();
    dictionary['days'] = days;
    return dictionary;
  }

  @override
  factory MBInactiveUserTrigger.fromJsonDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    int days = dictionary['days'];

    return MBInactiveUserTrigger(
      id: id,
      days: days,
    );
  }
//endregion
}
