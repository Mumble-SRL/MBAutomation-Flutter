import 'package:mbaudience/mbaudience.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

/// An inactive user trigger that becomes true when a user has been inactive for n days.
class MBInactiveUserTrigger extends MBTrigger {
  /// The number of days the user needs to stay inactive.
  final int days;

  /// Initializes an inactive user trigger with the data provided.
  MBInactiveUserTrigger({
    required String id,
    required this.days,
  }) : super(
          id: id,
          triggerType: MBTriggerType.inactiveUser,
        );

  /// Initializes an inactive user trigger with the data of the dictionary returned by the APIs.
  factory MBInactiveUserTrigger.fromDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    int days = dictionary['days'] ?? 0;

    return MBInactiveUserTrigger(
      id: id,
      days: days,
    );
  }

  /// If the trigger is valid or not.
  /// @param fromAppStartup If the check has been triggered at the app startup
  /// @returns If the trigger is valid or not.
  @override
  Future<bool> isValid(bool fromAppStartup) async {
    if (!fromAppStartup) {
      return false;
    }
    int currentSession = await MBAudience.currentSession;
    DateTime? currentDate =
        await MBAudience.startSessionDateForSession(currentSession);
    if (currentDate == null) {
      return false;
    }
    DateTime? lastSessionDate =
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
