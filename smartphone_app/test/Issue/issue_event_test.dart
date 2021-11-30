import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/issue/issue_events_states.dart';
import 'package:flutter/material.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("IssuePageEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(buttonEvent: IssueButtonEvent.createIssue),
          const ButtonPressed(buttonEvent: IssueButtonEvent.createIssue),
        );
      });
    });

    group("DeletePicture", () {
      var image = Image.asset("");

      test("Supports value comparisons", () {
        expect(
          DeletePicture(picture: image),
          DeletePicture(picture: image),
        );
      });
    });

    group("TextChanged", () {
      test("Supports value comparisons", () {
        expect(
          const TextChanged(
              textChangedEvent: IssueTextChangedEvent.description,
              text: "1234"),
          const TextChanged(
              textChangedEvent: IssueTextChangedEvent.description,
              text: "1234"),
        );
      });
    });

    group("CategorySelected", () {
      test("Supports value comparisons", () {
        expect(
          CategorySelected(
              category: Category(id: 1), subCategory: SubCategory(id: 1)),
          CategorySelected(
              category: Category(id: 1), subCategory: SubCategory(id: 1)),
        );
      });
    });

    group("PageContentLoaded", () {
      test("Supports value comparisons", () {
        expect(
          PageContentLoaded(
              marker: const Marker(markerId: MarkerId("1")),
              issueState: IssueState(id: 1),
              municipalityResponses: [MunicipalityResponse(id: 1)],
              address: "Testroad 1",
              dateCreated: "2021-01-01 10:00:00",
              dateEdited: "2021-01-01 10:00:00",
              hasVerified: true,
              isCreator: true,
              description: "Test",
              pictures: List.empty(),
              category: Category(id: 1),
              subCategory: SubCategory(id: 1)),
          PageContentLoaded(
              marker: const Marker(markerId: MarkerId("1")),
              issueState: IssueState(id: 1),
              municipalityResponses: [MunicipalityResponse(id: 1)],
              address: "Testroad 1",
              dateCreated: "2021-01-01 10:00:00",
              dateEdited: "2021-01-01 10:00:00",
              hasVerified: true,
              isCreator: true,
              description: "Test",
              pictures: List.empty(),
              category: Category(id: 1),
              subCategory: SubCategory(id: 1)),
        );
      });
    });

    group("PictureSelected", () {
      var image = Image.asset("");
      test("Supports value comparisons", () {
        expect(
          PictureSelected(image: image),
          PictureSelected(image: image),
        );
      });
    });

    group("IssueVerified", () {
      test("Supports value comparisons", () {
        expect(
          const IssueUpdated(
              hasChanges: true, dateEdited: "2021-10-10 10:00:00"),
          const IssueUpdated(
              hasChanges: true, dateEdited: "2021-10-10 10:00:00"),
        );
      });
    });

    group("IssueUpdated", () {
      test("Supports value comparisons", () {
        expect(
          const IssueVerified(),
          const IssueVerified(),
        );
      });
    });
  });
}
