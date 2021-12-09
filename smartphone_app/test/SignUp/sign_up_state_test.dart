import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("SignUpState", () {
    test("Supports value comparisons", () {
      var state = SignUpState();
      state = state.copyWith(
          verificationId: "afasdffdasf",
          pageView: SignUpPageView.phoneNo,
          name: "Test",
          municipality: Municipality(id: 1),
          phoneNo: "12345678",
          smsCode: "123456");
      expect(
          state,
          SignUpState(
              verificationId: "afasdffdasf",
              pageView: SignUpPageView.phoneNo,
              name: "Test",
              municipality: Municipality(id: 1),
              phoneNo: "12345678",
              smsCode: "123456"));
    });
  });
}
