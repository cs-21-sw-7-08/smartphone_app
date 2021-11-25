import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum ReportButtonEvent { close, selectReportCategory, confirm }

//endregion

///
/// EVENT
///
//region Event

class ReportEvent {}

class ButtonPressed extends ReportEvent {
  final ReportButtonEvent buttonEvent;

  ButtonPressed({required this.buttonEvent});
}

//endregion

///
/// STATE
///
//region State

class ReportState {
  ReportCategory? reportCategory;

  ReportState({this.reportCategory});

  ReportState copyWith({ReportCategory? reportCategory}) {
    return ReportState(reportCategory: reportCategory ?? this.reportCategory);
  }
}

//endregion
