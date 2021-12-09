import 'dart:ui';

import 'package:equatable/equatable.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

// ignore: must_be_immutable
class MunicipalityFilterItem extends Equatable {
  bool isSelected;
  Municipality municipality;

  MunicipalityFilterItem(
      {required this.municipality, required this.isSelected});

  @override
  List<Object?> get props => [municipality, isSelected];
}
