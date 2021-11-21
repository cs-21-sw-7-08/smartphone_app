import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class IssueStateFilterItem {
  bool isSelected;
  IssueState issueState;

  IssueStateFilterItem({required this.isSelected, required this.issueState});
}