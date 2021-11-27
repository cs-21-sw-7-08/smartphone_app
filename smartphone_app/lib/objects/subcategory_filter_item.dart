import 'package:equatable/equatable.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

// ignore: must_be_immutable
class SubCategoryFilterItem extends Equatable {
  Category category;
  SubCategory subCategory;
  bool isSelected;

  SubCategoryFilterItem(
      {required this.category,
      required this.subCategory,
      required this.isSelected});

  @override
  List<Object?> get props => [category, subCategory, isSelected];
}
