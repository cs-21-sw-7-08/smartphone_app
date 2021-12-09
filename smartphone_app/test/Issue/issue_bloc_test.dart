import 'dart:collection';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/pages/issue/issue_bloc.dart';
import 'package:smartphone_app/pages/issue/issue_events_states.dart';

import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("Issue", () {
    late IssuePageBloc bloc;
    var image = Image.asset("");

    setUp(() {
      bloc = IssuePageBloc(
          context: MockBuildContext(),
          mapType: MapType.hybrid,
          issue: Issue(id: 1, issueState: IssueState(id: 1)));
    });

    test("Initial state is correct", () {
      expect(
          IssuePageBloc(
                  context: MockBuildContext(),
                  mapType: MapType.hybrid,
                  issue: Issue(id: 1))
              .state,
          IssuePageState(
              mapType: MapType.hybrid,
              hasChanges: false,
              pictures: List.empty(growable: true),
              pageView: IssuePageView.see));
    });

    blocTest<IssuePageBloc, IssuePageState>("ButtonPressed -> Back",
        setUp: () {
          bloc.state.pageView = IssuePageView.edit;
          bloc.hashCodeMap = HashMap<String, int>();
        },
        build: () => bloc,
        act: (bloc) =>
            bloc.add(const ButtonPressed(buttonEvent: IssueButtonEvent.back)),
        expect: () => [bloc.state.copyWith(pageView: IssuePageView.see)]);

    blocTest<IssuePageBloc, IssuePageState>("ButtonPressed -> Edit issue",
        build: () => bloc,
        act: (bloc) => bloc
            .add(const ButtonPressed(buttonEvent: IssueButtonEvent.editIssue)),
        expect: () => [bloc.state.copyWith(pageView: IssuePageView.edit)]);

    blocTest<IssuePageBloc, IssuePageState>("TextChanged -> Description",
        build: () => bloc,
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: IssueTextChangedEvent.description, text: "1234")),
        expect: () => [bloc.state.copyWith(description: "1234")]);

    blocTest<IssuePageBloc, IssuePageState>("PageContentLoaded",
        build: () => bloc,
        act: (bloc) => bloc.add(PageContentLoaded(
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
            subCategory: SubCategory(id: 1))),
        expect: () => [
              bloc.state.copyWith(
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
                  subCategory: SubCategory(id: 1))
            ]);

    blocTest<IssuePageBloc, IssuePageState>("LocationInformationRetrieved",
        build: () => bloc,
        act: (bloc) => bloc.add(const LocationInformationRetrieved(
            municipalityName: "Aalborg",
            address: "Test",
            marker: Marker(markerId: MarkerId("1")))),
        expect: () => [
              bloc.state.copyWith(
                  municipalityName: "Aalborg",
                  address: "Test",
                  marker: const Marker(markerId: MarkerId("1")))
            ]);

    blocTest<IssuePageBloc, IssuePageState>("CategorySelected",
        build: () => bloc,
        act: (bloc) => bloc.add(CategorySelected(
            category: Category(id: 1), subCategory: SubCategory(id: 1))),
        expect: () => [
              bloc.state.copyWith(
                  category: Category(id: 1), subCategory: SubCategory(id: 1))
            ]);

    blocTest<IssuePageBloc, IssuePageState>("PictureSelected",
        build: () => bloc,
        act: (bloc) => bloc.add(PictureSelected(image: image)),
        expect: () => [
              bloc.state.copyWith(
                  pictures: [image], updatedItemHashCode: hashList([image]))
            ]);

    blocTest<IssuePageBloc, IssuePageState>("IssueUpdated",
        build: () => bloc,
        act: (bloc) => bloc.add(const IssueUpdated(
            hasChanges: true, dateEdited: "2021-10-10 10:00:00")),
        expect: () => [
              bloc.state.copyWith(
                  pageView: IssuePageView.see,
                  hasChanges: true,
                  dateEdited: "2021-10-10 10:00:00")
            ]);

    blocTest<IssuePageBloc, IssuePageState>("IssueVerified",
        build: () => bloc,
        act: (bloc) => bloc.add(const IssueVerified()),
        expect: () => [bloc.state.copyWith(hasVerified: true)]);
  });
}
