import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/select_location/select_location_events_states.dart';

void main() {
  group("SelectLocationEvent", () {
    var devicePosition = const Position(
        longitude: 1,
        latitude: 1,
        accuracy: 1,
        altitude: 1,
        heading: 1,
        speed: 1,
        speedAccuracy: 1,
        isMocked: false,
        timestamp: null);

    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(
              buttonEvent: SelectLocationButtonEvent.changeMapType),
          const ButtonPressed(
              buttonEvent: SelectLocationButtonEvent.changeMapType),
        );
      });
    });

    group("AddMarker", () {
      test("Supports value comparisons", () {
        expect(
          const AddMarker(point: LatLng(1, 1)),
          const AddMarker(point: LatLng(1, 1)),
        );
      });
    });

    group("RemoveMarker", () {
      test("Supports value comparisons", () {
        expect(
          const RemoveMarker(),
          const RemoveMarker(),
        );
      });
    });

    group("PositionRetrieved", () {
      test("Supports value comparisons", () {
        expect(
          PositionRetrieved(devicePosition: devicePosition),
          PositionRetrieved(devicePosition: devicePosition),
        );
      });
    });
  });
}
