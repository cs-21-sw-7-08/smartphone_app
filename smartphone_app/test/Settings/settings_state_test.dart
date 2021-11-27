import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/settings/settings_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("SettingsState", () {
    test("Supports value comparisons", () {
      var state = SettingsState();
      state = state.copyWith(municipality: Municipality(id: 1), name: "Test");
      expect(state,
          SettingsState(municipality: Municipality(id: 1), name: "Test"));
    });
  });
}
