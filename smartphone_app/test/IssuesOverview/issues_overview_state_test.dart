import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/objects/place.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("IssuesOverviewState", () {
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
      var state = IssuesOverviewState();
      state = state.copyWith(
          markers: <Marker>{const Marker(markerId: MarkerId("1"))},
          issues: [Issue(id: 1)],
          devicePosition: devicePosition,
          mapType: MapType.hybrid,
          filter: IssuesOverviewFilter(citizenIds: const [1]),
          places: [
            Place(
                issue:
                    Issue(id: 1, location: Location(latitude: 1, longitude: 1)))
          ]);
      expect(
          state,
          IssuesOverviewState(
              markers: <Marker>{const Marker(markerId: MarkerId("1"))},
              issues: [Issue(id: 1)],
              devicePosition: devicePosition,
              mapType: MapType.hybrid,
              filter: IssuesOverviewFilter(citizenIds: const [1]),
              places: [
                Place(
                    issue: Issue(
                        id: 1, location: Location(latitude: 1, longitude: 1)))
              ]));
    });
  });
}
