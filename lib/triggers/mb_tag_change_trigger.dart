import 'package:flutter/foundation.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

enum MBTagChangeOperator {
  equal,
  notEqual,
}

class MBTagChangeTrigger extends MBTrigger {
  final String tag;
  final String value;

  final MBTagChangeOperator tagChangeOperator;

  DateTime completionDate;

  MBTagChangeTrigger({
    @required String id,
    @required this.tag,
    @required this.value,
    @required this.tagChangeOperator,
  }) : super(
          id: id,
          triggerType: MBTriggerType.tagChange,
        );

  factory MBTagChangeTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String tag = dictionary['tag'] ?? '';
    String value = dictionary['value'];
    String operatorString = dictionary['operator'];

    return MBTagChangeTrigger(
      id: id,
      tag: tag,
      value: value,
      tagChangeOperator:
          MBTagChangeTrigger._tagChangeOperatorFromString(operatorString),
    );
  }

  bool tagChanged(String tag, String value) {
    //TODO: cancel notification?
    // Instead of a bool return the new state: valid, invalid, unchanged
    // valid = true
    // invalid = [new] cancel local notif
    // unchanged = do nothing

    if (tag != this.tag) {
      return false;
    }
    String newValue = value;
    if (tagChangeOperator == MBTagChangeOperator.equal) {
      if (newValue == this.value) {
        completionDate = DateTime.now();
        return true;
      }
    } else if (tagChangeOperator == MBTagChangeOperator.notEqual) {
      if (newValue != this.value) {
        completionDate = DateTime.now();
        return true;
      }
    }
    return false;
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
    dictionary['tag'] = tag;
    dictionary['value'] = value;
    dictionary['tagChangeOperator'] =
        _stringForTagChangeOperator(tagChangeOperator);

    if (completionDate != null) {
      dictionary['completionDate'] =
          completionDate.millisecondsSinceEpoch ~/ 1000;
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

    MBTagChangeTrigger triggger = MBTagChangeTrigger(
      id: id,
      tag: tag,
      value: value,
      tagChangeOperator: _tagChangeOperatorFromString(tagChangeOperatorString),
    );

    if (dictionary['completionDate'] != null) {
      triggger.completionDate = dictionary['completionDate'] * 1000;
    }

    return triggger;
  }
//endregion

//region operator-string conversion

  static String _stringForTagChangeOperator(MBTagChangeOperator operator) {
    switch (operator) {
      case MBTagChangeOperator.equal:
        return '=';
        break;
      case MBTagChangeOperator.notEqual:
        return '!=';
        break;
    }
    return '=';
  }

  static MBTagChangeOperator _tagChangeOperatorFromString(
      String operatorString) {
    switch (operatorString) {
      case '=':
        return MBTagChangeOperator.equal;
        break;
      case '!=':
        return MBTagChangeOperator.notEqual;
        break;
    }
    return MBTagChangeOperator.notEqual;
  }

//endregion
}
