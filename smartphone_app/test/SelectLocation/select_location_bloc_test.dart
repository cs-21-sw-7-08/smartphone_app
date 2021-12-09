import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/pages/select_location/select_location_bloc.dart';
import 'package:smartphone_app/pages/select_location/select_location_events_states.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("Select location", () {
    late SelectLocationBloc bloc;
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

    setUp(() {
      bloc = SelectLocationBloc(
          context: MockBuildContext(), mapType: MapType.hybrid);
    });

    test("Initial state is correct", () {
      expect(
          SelectLocationBloc(
            context: MockBuildContext(),
            mapType: MapType.hybrid,
          ).state,
          SelectLocationState(mapType: MapType.hybrid));
    });

    blocTest<SelectLocationBloc, SelectLocationState>("AddMarker",
        build: () => bloc,
        act: (bloc) => bloc.add(const AddMarker(point: LatLng(1, 1))),
        expect: () => [isA<SelectLocationState>()]);

    blocTest<SelectLocationBloc, SelectLocationState>("RemoveMarker",
        build: () => bloc,
        act: (bloc) => bloc.add(const RemoveMarker()),
        expect: () => [bloc.state.copyWith(marker: null)]);

    blocTest<SelectLocationBloc, SelectLocationState>("PositionRetrieved",
        build: () => bloc,
        act: (bloc) =>
            bloc.add(PositionRetrieved(devicePosition: devicePosition)),
        expect: () => [bloc.state.copyWith(devicePosition: devicePosition)]);

    blocTest<SelectLocationBloc, SelectLocationState>(
        "ButtonPressed -> Change map type",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: SelectLocationButtonEvent.changeMapType)),
        expect: () => [bloc.state.copyWith(mapType: MapType.normal)]);
  });
}
