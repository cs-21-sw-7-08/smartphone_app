import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/settings/settings_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("SettingsEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(buttonEvent: SettingsButtonEvent.save),
          const ButtonPressed(buttonEvent: SettingsButtonEvent.save),
        );
      });
    });

    group("TextChanged", () {
      test("Supports value comparisons", () {
        expect(
          const TextChanged(
              textChangedEvent: SettingsTextChangedEvent.name, text: "Test"),
          const TextChanged(
              textChangedEvent: SettingsTextChangedEvent.name, text: "Test"),
        );
      });
    });

    group("ValuesRetrieved", () {
      test("Supports value comparisons", () {
        expect(
          ValuesRetrieved(name: "Test", municipality: Municipality(id: 1)),
          ValuesRetrieved(name: "Test", municipality: Municipality(id: 1)),
        );
      });
    });
  });
}
