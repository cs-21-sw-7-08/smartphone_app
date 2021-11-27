import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smartphone_app/pages/settings/settings_bloc.dart';
import 'package:smartphone_app/pages/settings/settings_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("Settings", () {
    test("Initial state is correct", () {
      expect(
          SettingsBloc(
            context: MockBuildContext(),
          ).state,
          SettingsState());
    });

    blocTest<SettingsBloc, SettingsState>("ValuesRetrieved",
        build: () => SettingsBloc(context: MockBuildContext()),
        act: (bloc) => bloc.add(
            ValuesRetrieved(name: "Test", municipality: Municipality(id: 1))),
        expect: () =>
            [SettingsState(name: "Test", municipality: Municipality(id: 1))]);

    blocTest<SettingsBloc, SettingsState>("TextChanged -> Name",
        build: () => SettingsBloc(context: MockBuildContext()),
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: SettingsTextChangedEvent.name, text: "Test")),
        expect: () => [SettingsState(name: "Test")]);
  });
}
