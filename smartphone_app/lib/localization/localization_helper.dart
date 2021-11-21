import 'package:flutter/cupertino.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class LocalizationHelper {
  ///
  /// STATIC
  ///
  //region Static

  static LocalizationHelper? _localizationHelper;

  static LocalizationHelper getInstance() {
    return _localizationHelper!;
  }

  static init({required BuildContext context}) {
    _localizationHelper = LocalizationHelper();
  }

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables


  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor


  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  String getLocalizedCategory(BuildContext context, Category? category) {
    if (category == null) return "";
    String localizedCategory = "";
    switch (category.id) {
      case 1:
        localizedCategory = AppLocalizations.of(context)!.category_id_1;
        break;
    }

    return localizedCategory.isNotEmpty
        ? localizedCategory
        : (category.name ?? "");
  }

  String getLocalizedSubCategory(BuildContext context, SubCategory? subCategory) {
    if (subCategory == null) return "";
    String localizedSubCategory = "";
    switch (subCategory.id) {
      case 1:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_1;
        break;
    }

    return localizedSubCategory.isNotEmpty
        ? localizedSubCategory
        : (subCategory.name ?? "");
  }

  String getLocalizedIssueState(BuildContext context, IssueState? issueState) {
    if (issueState == null) return "";
    String localizedIssueState = "";
    switch (issueState.id) {
      case 1:
        localizedIssueState = AppLocalizations.of(context)!.issue_state_id_1;
        break;
      case 2:
        localizedIssueState = AppLocalizations.of(context)!.issue_state_id_2;
        break;
      case 3:
        localizedIssueState = AppLocalizations.of(context)!.issue_state_id_3;
        break;
    }
    return localizedIssueState.isNotEmpty
        ? localizedIssueState
        : (issueState.name ?? "");
  }

  String getLocalizedReportCategory(BuildContext context, ReportCategory? reportCategory) {
    if (reportCategory == null) return "";
    String localizedReportCategory = "";
    switch (reportCategory.id) {
      case 1:
        //localizedCategory = AppLocalizations.of(context)!.category_id_1;
        break;
    }

    return localizedReportCategory.isNotEmpty
        ? localizedReportCategory
        : (reportCategory.name ?? "");
  }

//endregion
}
