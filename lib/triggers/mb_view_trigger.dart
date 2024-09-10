import 'package:mbautomation/tracking/model/mb_automation_view.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

/// A view trigger that becomes true when a view is viewed n times and the user stays in the view for a tot of seconds.
class MBViewTrigger extends MBTrigger {
  /// The view name.
  final String view;

  /// The times the user needs to see the specified view.
  final int times;

  /// The seconds the user needs to stay in the view.
  final int secondsOnView;

  /// If the trigger has been completed this var will have the date the event has been completed.
  DateTime? completionDate;

  /// Counter to keeps track of how many times an event has happened.
  int? numberOfTimes;

  /// Initializes a view trigger with the data provided.
  MBViewTrigger({
    required super.id,
    required this.view,
    required this.times,
    required this.secondsOnView,
  }) : super(
          triggerType: MBTriggerType.view,
        );

  /// Initializes a view trigger with the data of the dictionary returned by the APIs.
  factory MBViewTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String view = dictionary['view'] ?? '';
    int times = 0;
    if (dictionary['times'] is int) {
      times = dictionary['times'];
    } else if (dictionary['times'] is String) {
      times = int.tryParse(dictionary['times']) ?? 0;
    }

    int secondsOnView = 0;
    if (dictionary['seconds_on_view'] is int) {
      secondsOnView = dictionary['seconds_on_view'];
    } else if (dictionary['seconds_on_view'] is String) {
      secondsOnView = int.tryParse(dictionary['seconds_on_view']) ?? 0;
    }

    return MBViewTrigger(
      id: id,
      view: view,
      times: times,
      secondsOnView: secondsOnView,
    );
  }

  /// Function called when the user views a view
  /// @param view The view viewed.
  /// @returns If theis trigger has changed or not.
  bool screenViewed(MBAutomationView view) {
    if (view.view == this.view) {
      numberOfTimes = (numberOfTimes ?? 0) + 1;
      return true;
    }
    return false;
  }

  /// Sets the trigger as completed.
  /// This function set the completionDate of the trigger to now.
  void setCompleted() {
    completionDate = DateTime.now();
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
    dictionary['view'] = view;
    dictionary['times'] = times;
    dictionary['secondsOnView'] = secondsOnView;

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
      int timeStamp = dictionary['completionDate'] * 1000;
      trigger.completionDate = DateTime.fromMillisecondsSinceEpoch(timeStamp);
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
