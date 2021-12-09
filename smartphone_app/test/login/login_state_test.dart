import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/login/login_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';

void main() {
  group("LoginState", () {
    test("Supports value comparisons", () {
      var state = LoginState();
      state = state.copyWith(permissionState: PermissionState.denied);
      expect(state, LoginState(permissionState: PermissionState.denied));
    });
  });
}
