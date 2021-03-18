import 'dart:convert';

/// An event of MBAutomation.
class MBAutomationEvent {
  /// The id of the event.
  final int? id;

  /// The event name.
  final String event;

  /// The name of the event.
  final String? name;

  /// Additional metadata for the event.
  final Map<String, dynamic>? metadata;

  /// Timestamp of the event.
  final DateTime timestamp;

  /// Initializes an event with the parameters passed. Timestamp is set with `DateTime.now()`.
  /// @param event The name of the event.
  /// @param name The name of the event.
  /// @param metadata Additional metadata for the event.
  MBAutomationEvent({
    required this.event,
    this.name,
    this.metadata,
  })  : id = null,
        timestamp = DateTime.now();

  /// Initializes an event with all the data. Used when initializing the event from DB data.
  MBAutomationEvent._withAllData({
    required this.id,
    required this.event,
    required this.name,
    required this.metadata,
    required this.timestamp,
  });

  /// Initializes an event with the `Map` retrieved from the DB.
  /// @param dbData data retrieved from the DB.
  factory MBAutomationEvent.fromDbData({
    required Map<String, dynamic> dbData,
  }) {
    int? id = dbData['id'];
    String event = dbData['event'];
    String? name = dbData['name'];

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
    return MBAutomationEvent._withAllData(
      id: id,
      event: event,
      name: name,
      metadata: metadata,
      timestamp: timestamp,
    );
  }

  /// Converts this event to a `Map` to save it in the DB.
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

  /// Converts this event to a `Map` to send it with MBurger APIs.
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
