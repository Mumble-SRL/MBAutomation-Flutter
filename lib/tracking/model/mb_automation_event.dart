import 'dart:convert';

import 'package:flutter/foundation.dart';

class MBAutomationEvent {
  final int id;
  final String event;
  final String name;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  MBAutomationEvent({
    @required this.event,
    this.name,
    this.metadata,
  })  : id = null,
        timestamp = DateTime.now();

  MBAutomationEvent.fromDbData({
    @required this.id,
    @required this.event,
    this.name,
    this.metadata,
    @required this.timestamp,
  });

  Map<String, dynamic> toApiDictionary() {
    Map<String, dynamic> dictionary = {
      'event': event,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
    if (name != null) {
      dictionary['name'] = name;
    }
    if (metadata != null) {
      dictionary['metadata'] = json.encode(metadata);
    }

    return dictionary;
  }
}
