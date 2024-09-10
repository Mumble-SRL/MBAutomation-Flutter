import 'package:mbautomation/triggers/mb_trigger.dart';

/// Enum used to return the new trigger status when a tag changes.
/// If a push notification is scheduled and the tag becomes invalid the push notification is cancelled.
enum MBTriggerChangedStatus {
  /// If the trigger is not changed.
  unchanged,

  /// If the trigger becomes valid.
  valid,

  /// If the trigger becomes invalid.
  invalid,
}

/// The tag change operator.
enum MBTagChangeOperator {
  /// If the tag needs to be equal.
  equal,

  /// If the tag needs to be different.
  notEqual,
}

/// A tag change trigger that becomes true when a tag changes its value.
class MBTagChangeTrigger extends MBTrigger {
  /// The tag that needs to change.
  final String tag;

  /// The value of the tag.
  final String value;

  /// The operator, it describe if the value needs to be equal or different.
  final MBTagChangeOperator tagChangeOperator;

  /// The date of completion of this trigger.
  DateTime? completionDate;

  /// Initializes a tag change trigger with the data provided.
  MBTagChangeTrigger({
    required super.id,
    required this.tag,
    required this.value,
    required this.tagChangeOperator,
  }) : super(
          triggerType: MBTriggerType.tagChange,
        );

  /// Initializes a tag change trigger with the data of the dictionary returned by the APIs.
  factory MBTagChangeTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String tag = dictionary['tag'] ?? '';
    String value = dictionary['value'] ?? '';
    String operatorString = dictionary['operator'];

    return MBTagChangeTrigger(
      id: id,
      tag: tag,
      value: value,
      tagChangeOperator:
          MBTagChangeTrigger._tagChangeOperatorFromString(operatorString),
    );
  }

  /// Function called when a tag changes its value.
  /// @param tag The tag that has changed.
  /// @param value The new value of the tag.
  /// @returns The new trigger status (unchanged, valid, invalid).
  MBTriggerChangedStatus tagChanged(
    String tag,
    String? value,
  ) {
    if (tag != this.tag) {
      return MBTriggerChangedStatus.unchanged;
    }
    String? newValue = value;
    if (tagChangeOperator == MBTagChangeOperator.equal) {
      if (newValue == this.value) {
        completionDate = DateTime.now();
        return MBTriggerChangedStatus.valid;
      } else {
        completionDate = null;
        return MBTriggerChangedStatus.invalid;
      }
    } else if (tagChangeOperator == MBTagChangeOperator.notEqual) {
      if (newValue != this.value) {
        completionDate = DateTime.now();
        return MBTriggerChangedStatus.valid;
      } else {
        completionDate = null;
        return MBTriggerChangedStatus.invalid;
      }
    }
    return MBTriggerChangedStatus.unchanged;
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
    dictionary['tag'] = tag;
    dictionary['value'] = value;
    dictionary['tagChangeOperator'] =
        _stringForTagChangeOperator(tagChangeOperator);

    if (completionDate != null) {
      dictionary['completionDate'] =
          completionDate!.millisecondsSinceEpoch ~/ 1000;
    }

    return dictionary;
  }

  @override
  factory MBTagChangeTrigger.fromJsonDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String tag = dictionary['tag'];
    String value = dictionary['value'];
    String tagChangeOperatorString = dictionary['tagChangeOperator'];

    MBTagChangeTrigger trigger = MBTagChangeTrigger(
      id: id,
      tag: tag,
      value: value,
      tagChangeOperator: _tagChangeOperatorFromString(tagChangeOperatorString),
    );

    if (dictionary['completionDate'] != null) {
      int timeStamp = dictionary['completionDate'] * 1000;
      trigger.completionDate = DateTime.fromMillisecondsSinceEpoch(timeStamp);
    }

    return trigger;
  }

//endregion

//region operator-string conversion
  static String _stringForTagChangeOperator(MBTagChangeOperator operator) {
    switch (operator) {
      case MBTagChangeOperator.equal:
        return '=';
      case MBTagChangeOperator.notEqual:
        return '!=';
    }
  }

  static MBTagChangeOperator _tagChangeOperatorFromString(
      String operatorString) {
    switch (operatorString) {
      case '=':
        return MBTagChangeOperator.equal;
      case '!=':
        return MBTagChangeOperator.notEqual;
    }
    return MBTagChangeOperator.notEqual;
  }

//endregion

//region update trigger

  @override
  MBTrigger updatedTrigger(MBTrigger newTrigger) {
    if (newTrigger is MBTagChangeTrigger) {
      newTrigger.completionDate = completionDate;
    }
    return newTrigger;
  }

//endregion
}
