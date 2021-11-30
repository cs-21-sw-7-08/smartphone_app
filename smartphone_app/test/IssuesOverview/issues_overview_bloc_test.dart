import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_bloc.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';

import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/mock_wasp_service.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("IssuesOverview", () {
    late IssuesOverviewBloc bloc;
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

    setUp(() async {
      AppValuesHelper.getInstance().init();
      WASPService.init(MockWASPService());

      var getListOfMunicipalitiesResponse =
          await WASPService.getInstance().getListOfMunicipalities();

      var jsonMunicipalities = jsonEncode(getListOfMunicipalitiesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      var getListOfCategoriesResponse =
          await WASPService.getInstance().getListOfCategories();

      var jsonCategories = jsonEncode(getListOfCategoriesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      var getListOfReportCategoriesResponse =
          await WASPService.getInstance().getListOfReportCategories();

      var jsonReportCategories = jsonEncode(getListOfReportCategoriesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      SharedPreferences.setMockInitialValues({
        AppValuesKey.defaultMunicipalityId.toString(): 1,
        AppValuesKey.municipalities.toString(): jsonMunicipalities,
        AppValuesKey.citizenId.toString(): 1,
        AppValuesKey.categories.toString(): jsonCategories,
        AppValuesKey.reportCategories.toString(): jsonReportCategories
      });

      bloc = IssuesOverviewBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () {
      expect(
          IssuesOverviewBloc(context: MockBuildContext()).state,
          IssuesOverviewState(
              mapType: MapType.hybrid,
              filter: IssuesOverviewBloc.getDefaultIssuesOverviewFilter()));
    });

    blocTest<IssuesOverviewBloc, IssuesOverviewState>(
        "ButtonPressed -> Change map type",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: IssuesOverviewButtonEvent.changeMapType)),
        expect: () => [bloc.state.copyWith(mapType: MapType.normal)]);

    blocTest<IssuesOverviewBloc, IssuesOverviewState>("PositionRetrieved",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(PositionRetrieved(devicePosition: devicePosition)),
        expect: () => [bloc.state.copyWith(devicePosition: devicePosition)]);

    blocTest<IssuesOverviewBloc, IssuesOverviewState>("ListOfIssuesRetrieved",
        build: () => bloc,
        act: (bloc) => bloc.add(ListOfIssuesRetrieved(issues: [
              Issue(id: 1, location: Location(latitude: 1, longitude: 1))
            ])),
        expect: () => [
              bloc.state.copyWith(issues: [
                Issue(id: 1, location: Location(latitude: 1, longitude: 1))
              ])
            ]);

    blocTest<IssuesOverviewBloc, IssuesOverviewState>("ListOfIssuesRetrieved",
        build: () => bloc,
        act: (bloc) => bloc.add(ListOfIssuesRetrieved(issues: [
              Issue(id: 1, location: Location(latitude: 1, longitude: 1))
            ])),
        expect: () => [
              bloc.state.copyWith(issues: [
                Issue(id: 1, location: Location(latitude: 1, longitude: 1))
              ])
            ]);

    blocTest<IssuesOverviewBloc, IssuesOverviewState>("MarkersUpdated",
        build: () => bloc,
        act: (bloc) => bloc.add(MarkersUpdated(
            markers: <Marker>{const Marker(markerId: MarkerId("1"))})),
        expect: () => [
              bloc.state.copyWith(
                  markers: <Marker>{const Marker(markerId: MarkerId("1"))})
            ]);
  });
}
