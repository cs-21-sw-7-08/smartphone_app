import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/sign_up/sign_up_events_states.dart';

void main() {
  group("SignUpEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(const ButtonPressed(buttonEvent: SignUpButtonEvent.confirmName),
            const ButtonPressed(buttonEvent: SignUpButtonEvent.confirmName));
      });
    });

    group("TextChanged", () {
      test("Supports value comparisons", () {
        expect(
          const TextChanged(
              textChangedEvent: SignUpTextChangedEvent.name, text: "Test"),
          const TextChanged(
              textChangedEvent: SignUpTextChangedEvent.name, text: "Test"),
        );
      });
    });

    group("MakeViewChange", () {
      test("Supports value comparisons", () {
        expect(
          const MakeViewChange(pageView: SignUpPageView.phoneNo),
          const MakeViewChange(pageView: SignUpPageView.phoneNo),
        );
      });
    });

    group("VerificationIdRetrieved", () {
      test("Supports value comparisons", () {
        expect(
          const VerificationIdRetrieved(verificationId: "12345678"),
          const VerificationIdRetrieved(verificationId: "12345678"),
        );
      });
    });
  });
}
