import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:mbautomation/triggers/mb_trigger.dart';

/// A location trigger that becomes true when the user visits a location, specified by lat, lng and radius.
class MBLocationTrigger extends MBTrigger {
  /// The address of the location.
  final String address;

  /// The latitude of the location.
  final double latitude;

  /// The longitude of the location.
  final double longitude;

  /// The radius to check, in meters.
  final double radius;

  /// The lookback window to check (in days).
  final int afterDays;

  /// The date of completion of this trigger.
  DateTime completionDate;

  /// Initializes a location trigger with the data provided.
  MBLocationTrigger({
    @required String id,
    @required this.address,
    @required this.latitude,
    @required this.longitude,
    @required this.radius,
    @required this.afterDays,
  }) : super(
          id: id,
          triggerType: MBTriggerType.location,
        );

  /// Initializes a location trigger with the data of the dictionary returned by the APIs.
  factory MBLocationTrigger.fromDictionary(Map<String, dynamic> dictionary) {
    String id = dictionary['id'] ?? '';
    String address = dictionary['address'] ?? '';
    double latitude = dictionary['latitude'];
    double longitude = dictionary['longitude'];
    double radius = dictionary['radius'] ?? 0;
    int afterDays = dictionary['after'] ?? 0;

    return MBLocationTrigger(
      id: id,
      address: address,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      afterDays: afterDays,
    );
  }

  /// Function called when new location data is available.
  /// @param latitude The new latitude.
  /// @param longitude The new longitude.
  /// @param lastLatitude The last latitude seen by `MBAutomation`.
  /// @param lastLongitude The last longitude seen by `MBAutomation`.
  /// @returns If this trigger has changed.
  bool locationDataUpdated({
    @required latitude,
    @required longitude,
    @required lastLatitude,
    @required lastLongitude,
  }) {
    if (completionDate != null) {
      return false;
    }

    double currentDistanceFromCenter = _calculateDistance(
      latitude,
      longitude,
      this.latitude,
      this.longitude,
    ).abs();

    bool isInside = currentDistanceFromCenter <= radius;
    bool locationTriggerSatisfied = false;
    if (isInside) {
      if (lastLatitude != null && lastLongitude != null) {
        double lastLocationDistanceFromCenter = _calculateDistance(
          lastLatitude,
          lastLongitude,
          this.latitude,
          this.longitude,
        ).abs();
        bool lastLocationIsInside = lastLocationDistanceFromCenter <= radius;
        locationTriggerSatisfied = !lastLocationIsInside;
      } else {
        locationTriggerSatisfied = true;
      }
    }

    if (locationTriggerSatisfied) {
      if (afterDays == 0 || afterDays == null) {
        completionDate = DateTime.now();
        return true;
      } else {
        completionDate = DateTime.now().add(Duration(days: afterDays));
        return false;
      }
    }
    return false;
  }

  /// Calculates the distance between 2 locations.
  /// @param lat1 Latitude for the first location.
  /// @param lon1 Longitude for the first location.
  /// @param lat2 Latitude for the second location.
  /// @param lon2 Longitude for the second location.
  /// @returns The distance between locations, in meters.
  double _calculateDistance(lat1, lon1, lat2, lon2) {
    var p = 0.017453292519943295;
    var c = cos;
    var a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742 * asin(sqrt(a));
  }

  /// If the trigger is valid or not.
  /// @param fromAppStartup If the check has been triggered at the app startup
  /// @returns If the trigger is valid or not.
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
    dictionary['address'] = address;
    dictionary['latitude'] = latitude;
    dictionary['longitude'] = longitude;
    dictionary['radius'] = radius;
    dictionary['afterDays'] = afterDays;

    if (completionDate != null) {
      dictionary['completionDate'] =
          completionDate.millisecondsSinceEpoch ~/ 1000;
    }

    return dictionary;
  }

  @override
  factory MBLocationTrigger.fromJsonDictionary(
      Map<String, dynamic> dictionary) {
    String id = dictionary['id'];
    String address = dictionary['address'];
    double latitude = dictionary['latitude'];
    double longitude = dictionary['longitude'];
    double radius = dictionary['radius'];
    int afterDays = dictionary['afterDays'];

    MBLocationTrigger trigger = MBLocationTrigger(
      id: id,
      address: address,
      latitude: latitude,
      longitude: longitude,
      radius: radius,
      afterDays: afterDays,
    );

    if (dictionary['completionDate'] != null) {
      trigger.completionDate = dictionary['completionDate'] * 1000;
    }

    return trigger;
  }
//endregion

//region update trigger

  @override
  MBTrigger updatedTrigger(MBTrigger newTrigger) {
    if (newTrigger is MBLocationTrigger) {
      newTrigger.completionDate = completionDate;
    }
    return newTrigger;
  }

//endregion

}
