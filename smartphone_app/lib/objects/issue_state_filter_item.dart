import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

// ignore: must_be_immutable
class IssueStateFilterItem extends Equatable {
  bool isSelected;
  IssueState issueState;

  IssueStateFilterItem({required this.isSelected, required this.issueState});

  @override
  List<Object?> get props => [isSelected, issueState];
}
