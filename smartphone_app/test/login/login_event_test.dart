import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginEvent", () {
    group("Resumed", () {
      test("Supports value comparisons", () {
        expect(Resumed(), Resumed());
      });
    });

    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(buttonEvent: LoginButtonEvent.usePhoneNo),
          const ButtonPressed(buttonEvent: LoginButtonEvent.usePhoneNo),
        );
      });
    });

    group("PermissionStateChanged", () {
      test("Supports value comparisons", () {
        expect(
            const PermissionStateChanged(
                permissionState: PermissionState.granted),
            const PermissionStateChanged(
                permissionState: PermissionState.granted));
      });
    });
  });
}
