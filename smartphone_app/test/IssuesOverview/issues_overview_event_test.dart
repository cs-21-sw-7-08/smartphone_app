import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("IssuesOverviewEvent", () {
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
              buttonEvent: IssuesOverviewButtonEvent.createIssue),
          const ButtonPressed(
              buttonEvent: IssuesOverviewButtonEvent.createIssue),
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

    group("ListOfIssuesRetrieved", () {
      test("Supports value comparisons", () {
        expect(
          ListOfIssuesRetrieved(issues: [Issue(id: 1)]),
          ListOfIssuesRetrieved(issues: [Issue(id: 1)]),
        );
      });
    });

    group("IssueDetailsRetrieved", () {
      test("Supports value comparisons", () {
        expect(
          IssueDetailsRetrieved(issue: Issue(id: 1)),
          IssueDetailsRetrieved(issue: Issue(id: 1)),
        );
      });
    });

    group("IssuePressed", () {
      test("Supports value comparisons", () {
        expect(
          IssuePressed(issue: Issue(id: 1)),
          IssuePressed(issue: Issue(id: 1)),
        );
      });
    });

    group("MarkersUpdated", () {
      test("Supports value comparisons", () {
        expect(
          MarkersUpdated(
              markers: <Marker>{const Marker(markerId: MarkerId("1"))}),
          MarkersUpdated(
              markers: <Marker>{const Marker(markerId: MarkerId("1"))}),
        );
      });
    });
  });
}
