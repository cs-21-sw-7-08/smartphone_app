import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/report/report_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("ReportState", () {
    test("Supports value comparisons", () {
      var state = ReportState();
      state = state.copyWith(reportCategory: ReportCategory(id: 1));
      expect(state,
          ReportState(reportCategory: ReportCategory(id: 1)));
    });
  });
}