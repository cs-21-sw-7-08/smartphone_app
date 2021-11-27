import 'package:equatable/equatable.dart';
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

abstract class ReportEvent extends Equatable {
  const ReportEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends ReportEvent {
  final ReportButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class ReportState extends Equatable {
  ReportCategory? reportCategory;

  ReportState({this.reportCategory});

  ReportState copyWith({ReportCategory? reportCategory}) {
    return ReportState(reportCategory: reportCategory ?? this.reportCategory);
  }

  @override
  List<Object?> get props => [reportCategory];
}

//endregion
