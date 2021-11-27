import 'package:equatable/equatable.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

// ignore: must_be_immutable
class MunicipalityFilterItem extends Equatable {
  Municipality municipality;
  bool isSelected;

  MunicipalityFilterItem(
      {required this.municipality, required this.isSelected});

  @override
  List<Object?> get props => [municipality, isSelected];
}
