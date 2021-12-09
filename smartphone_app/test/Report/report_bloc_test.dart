import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

import 'package:smartphone_app/pages/report/report_bloc.dart';
import 'package:smartphone_app/pages/report/report_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("Report", () {
    late ReportBloc bloc;

    setUp(() {
      bloc = ReportBloc(context: MockBuildContext());
    });

    test("Initial state is correct", () {
      expect(bloc.state, ReportState());
    });

    blocTest<ReportBloc, ReportState>("ValueSelected",
        build: () => bloc,
        act: (bloc) => bloc.add(ValueSelected(
            valueSelectedEvent: ReportValueSelectedEvent.reportCategory,
            value: ReportCategory(id: 1))),
        expect: () =>
            [bloc.state.copyWith(reportCategory: ReportCategory(id: 1))]);
  });
}
