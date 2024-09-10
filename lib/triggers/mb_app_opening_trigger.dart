import 'package:mbaudience/mbaudience.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

/// An app opening trigger that becomes true once the user has opened the app n times.
class MBAppOpeningTrigger extends MBTrigger {
  /// The number of times the user needs to open the app.
  final int times;

  /// Initializes an app opening trigger with the data provided.
  MBAppOpeningTrigger({
    required super.id,
    required this.times,
  }) : super(
          triggerType: MBTriggerType.appOpening,
        );

  /// Initializes an app opening trigger with the data of the dictionary returned by the APIs.
  factory MBAppOpeningTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] is String ? dictionary['id'] : '';
    int times = 0;
    if (dictionary['times'] is String) {
      times = int.tryParse(dictionary['times']) ?? 0;
    } else if (dictionary['times'] is int) {
      times = dictionary['times'];
    }

    return MBAppOpeningTrigger(id: id, times: times);
  }

  /// If the trigger is valid or not.
  /// @param fromAppStartup If the check has been triggered at the app startup
  /// @returns If the trigger is valid or not.s
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
