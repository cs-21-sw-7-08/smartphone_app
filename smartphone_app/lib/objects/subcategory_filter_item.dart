import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class SubCategoryFilterItem {
  Category category;
  SubCategory subCategory;
  bool isSelected;

  SubCategoryFilterItem(
      {required this.category,
      required this.subCategory,
      required this.isSelected});
}
