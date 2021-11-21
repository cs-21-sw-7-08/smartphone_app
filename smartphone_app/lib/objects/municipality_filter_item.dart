import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class MunicipalityFilterItem {
  Municipality municipality;
  bool isSelected;

  MunicipalityFilterItem(
      {required this.municipality, required this.isSelected});
}
