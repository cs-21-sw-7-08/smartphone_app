import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/issue/issue_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("IssuePageState", () {
    var image = Image.asset("");
    test("Supports value comparisons", () {
      var state = IssuePageState();
      state = state.copyWith(
          hasVerified: true,
          dateEdited: "2021-10-10 10:00:00",
          hasChanges: true,
          pageView: IssuePageView.edit,
          updatedItemHashCode: 10,
          pictures: [image],
          subCategory: SubCategory(id: 1),
          category: Category(id: 1),
          marker: const Marker(markerId: MarkerId("1")),
          address: "Testroad 1",
          municipalityName: "Aalborg",
          description: "Test",
          issueState: IssueState(id: 1),
          mapType: MapType.normal,
          isCreator: true,
          dateCreated: "2021-10-10 10:00:00",
          municipalityResponses: [MunicipalityResponse(id: 1)]);
      expect(
          state,
          IssuePageState(
              hasVerified: true,
              dateEdited: "2021-10-10 10:00:00",
              hasChanges: true,
              pageView: IssuePageView.edit,
              updatedItemHashCode: 10,
              pictures: [image],
              subCategory: SubCategory(id: 1),
              category: Category(id: 1),
              marker: const Marker(markerId: MarkerId("1")),
              address: "Testroad 1",
              municipalityName: "Aalborg",
              description: "Test",
              issueState: IssueState(id: 1),
              mapType: MapType.normal,
              isCreator: true,
              dateCreated: "2021-10-10 10:00:00",
              municipalityResponses: [MunicipalityResponse(id: 1)]));
    });
  });
}
