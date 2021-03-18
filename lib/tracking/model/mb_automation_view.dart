import 'dart:convert';

/// A view of MBAutomation.
class MBAutomationView {
  /// The id of the view.
  final int? id;

  /// The view name.
  final String view;

  /// Additional metadata for the view.
  final Map<String, dynamic>? metadata;

  /// Timestamp of the view.
  final DateTime timestamp;

  /// Initializes a view with the parameters passed. Timestamp is set with `DateTime.now()`.
  /// @param view The name of the view.
  /// @param metadata Additional metadata for the view.
  MBAutomationView({
    required this.view,
    this.metadata,
  })  : id = null,
        timestamp = DateTime.now();

  /// Initializes a view with all the data. Used when initializing the view from DB data.
  MBAutomationView._withAllData({
    required this.id,
    required this.view,
    required this.metadata,
    required this.timestamp,
  });

  /// Initializes a view with the `Map` retrieved from the DB.
  /// @param dbData data retrieved from the DB.
  factory MBAutomationView.fromDbData({
    required Map<String, dynamic> dbData,
  }) {
    int? id = dbData['id'];
    String view = dbData['view'];

    Map<String, dynamic>? metadata;
    String? metadataString = dbData['metadata'];
    if (metadataString != null) {
      metadata = json.decode(metadataString);
    } else {
      metadata = null;
    }
    int timestampInt = dbData['timestamp'] ?? 0;
    DateTime timestamp =
        DateTime.fromMillisecondsSinceEpoch(timestampInt * 1000);
    return MBAutomationView._withAllData(
      id: id,
      view: view,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  /// Converts this view to a `Map` to save it in the DB.
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

  /// Converts this view to a `Map` to send it with MBurger APIs.
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
