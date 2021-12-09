import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/select_location/select_location_events_states.dart';

void main() {
  group("SelectLocationState", () {
    test("Supports value comparisons", () {
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
      var state = SelectLocationState();
      state = state.copyWith(
          devicePosition: devicePosition,
          marker: null,
          mapType: MapType.hybrid);
      expect(
          state,
          SelectLocationState(
              devicePosition: devicePosition,
              marker: null,
              mapType: MapType.hybrid));
    });
  });
}
