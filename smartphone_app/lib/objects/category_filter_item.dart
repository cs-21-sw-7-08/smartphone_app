import 'package:equatable/equatable.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

// ignore: must_be_immutable
class CategoryFilterItem extends Equatable {
  Category category;
  late bool? _isSelected;
  List<SubCategoryFilterItem>? subCategories;

  bool get isSelected {
    if (_isSelected == null && subCategories == null) return false;
    if (subCategories != null) {
      return subCategories!.any((element) => element.isSelected);
    }
    return _isSelected!;
  }

  set isSelected(bool value) {
    _isSelected = value;
  }

  CategoryFilterItem(
      {required this.category,
      required bool? isSelected,
      required this.subCategories}) {
    _isSelected = isSelected;
  }

  @override
  List<Object?> get props => [category, isSelected, subCategories];
}
