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

  MBAutomationEvent._withAllData({
    @required this.id,
    @required this.event,
    @required this.name,
    @required this.metadata,
    @required this.timestamp,
  });

  factory MBAutomationEvent.fromDbData({
    @required Map<String, dynamic> dbData,
  }) {
    int id = dbData['id'];
    String event = dbData['event'];
    String name = dbData['name'];

    Map<String, dynamic> metadata;
    String metadataString = dbData['metadata'];
    if (metadataString != null) {
      metadata = json.decode(metadataString);
    } else {
      metadata = null;
    }
    int timestampInt = dbData['timestamp'];
    DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000);
    return MBAutomationEvent._withAllData(
      id: id,
      event: event,
      name: name,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toDbDictionary() {
    Map<String, dynamic> dictionary = {
      'event': event,
      'name': name,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };

    if (metadata != null) {
      dictionary['metadata'] = json.encode(metadata);
    }
    return dictionary;
  }

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
