import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/report/report_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("ReportEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(buttonEvent: ReportButtonEvent.close),
          const ButtonPressed(buttonEvent: ReportButtonEvent.close),
        );
      });
    });

    group("ValueSelected", () {
      test("Supports value comparisons", () {
        expect(
          ValueSelected(
              valueSelectedEvent: ReportValueSelectedEvent.reportCategory,
              value: ReportCategory(id: 1)),
          ValueSelected(
              valueSelectedEvent: ReportValueSelectedEvent.reportCategory,
              value: ReportCategory(id: 1)),
        );
      });
    });
  });
}
