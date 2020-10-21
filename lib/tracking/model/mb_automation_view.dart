import 'dart:convert';

import 'package:flutter/cupertino.dart';

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

  MBAutomationView.fromDbData({
    @required this.id,
    @required this.view,
    this.metadata,
    @required this.timestamp,
  });

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
