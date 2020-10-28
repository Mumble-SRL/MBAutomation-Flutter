import 'dart:convert';

import 'package:flutter/foundation.dart';

class MBAutomationView {
  final int id;
  final String view;
  final Map<String, dynamic> metadata;
  final DateTime timestamp;

  MBAutomationView({
    @required this.view,
    this.metadata,
  })  : id = null,
        timestamp = DateTime.now();

  MBAutomationView._withAllData({
    @required this.id,
    @required this.view,
    @required this.metadata,
    @required this.timestamp,
  });

  factory MBAutomationView.fromDbData({
    @required Map<String, dynamic> dbData,
  }) {
    int id = dbData['id'];
    String view = dbData['view'];

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
    return MBAutomationView._withAllData(
      id: id,
      view: view,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  Map<String, dynamic> toDbDictionary() {
    Map<String, dynamic> dictionary = {
      'view': view,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
    if (metadata != null) {
      dictionary['metadata'] = json.encode(metadata);
    }
    return dictionary;
  }

  Map<String, dynamic> toApiDictionary() {
    Map<String, dynamic> dictionary = {
      'view': view,
      'timestamp': timestamp.millisecondsSinceEpoch ~/ 1000,
    };
    if (metadata != null) {
      dictionary['metadata'] = json.encode(metadata);
    }
    return dictionary;
  }
}
