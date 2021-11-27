// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility that Flutter provides. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smartphone_app/pages/report/report_bloc.dart';
import 'package:smartphone_app/pages/report/report_events_states.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("Report", () {
    test("Initial state is correct", () {
      expect(
          ReportBloc(
              context: MockBuildContext())
              .state,
          ReportState());
    });
  });
}
