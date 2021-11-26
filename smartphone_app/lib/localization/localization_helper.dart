import 'package:flutter/cupertino.dart';
import 'package:smartphone_app/localization/local_app_localizations.dart';
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
      case 2:
        localizedCategory = AppLocalizations.of(context)!.category_id_2;
        break;
      case 3:
        localizedCategory = AppLocalizations.of(context)!.category_id_3;
        break;
      case 4:
        localizedCategory = AppLocalizations.of(context)!.category_id_4;
        break;
      case 5:
        localizedCategory = AppLocalizations.of(context)!.category_id_5;
        break;
      case 6:
        localizedCategory = AppLocalizations.of(context)!.category_id_6;
        break;
      case 7:
        localizedCategory = AppLocalizations.of(context)!.category_id_7;
        break;
      case 8:
        localizedCategory = AppLocalizations.of(context)!.category_id_8;
        break;
      case 9:
        localizedCategory = AppLocalizations.of(context)!.category_id_9;
        break;
      case 10:
        localizedCategory = AppLocalizations.of(context)!.category_id_10;
        break;
      case 11:
        localizedCategory = AppLocalizations.of(context)!.category_id_11;
        break;
    }

    return localizedCategory.isNotEmpty
        ? localizedCategory
        : (category.name ?? "");
  }

  String getLocalizedSubCategory(
      BuildContext context, SubCategory? subCategory) {
    if (subCategory == null) return "";
    String localizedSubCategory = "";
    switch (subCategory.id) {
      case 1:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_1;
        break;
      case 2:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_2;
        break;
      case 3:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_3;
        break;
      case 4:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_4;
        break;
      case 5:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_5;
        break;
      case 6:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_6;
        break;
      case 7:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_7;
        break;
      case 8:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_8;
        break;
      case 9:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_9;
        break;
      case 10:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_10;
        break;
      case 11:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_11;
        break;
      case 12:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_12;
        break;
      case 13:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_13;
        break;
      case 14:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_14;
        break;
      case 15:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_15;
        break;
      case 16:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_16;
        break;
      case 17:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_17;
        break;
      case 18:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_18;
        break;
      case 19:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_19;
        break;
      case 20:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_20;
        break;
      case 21:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_21;
        break;
      case 22:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_22;
        break;
      case 23:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_23;
        break;
      case 24:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_24;
        break;
      case 25:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_25;
        break;
      case 26:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_26;
        break;
      case 27:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_27;
        break;
      case 28:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_28;
        break;
      case 29:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_29;
        break;
      case 30:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_30;
        break;
      case 31:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_31;
        break;
      case 32:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_32;
        break;
      case 33:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_33;
        break;
      case 34:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_34;
        break;
      case 35:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_35;
        break;
      case 36:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_36;
        break;
      case 37:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_37;
        break;
      case 38:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_38;
        break;
      case 39:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_39;
        break;
      case 40:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_40;
        break;
      case 41:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_41;
        break;
      case 42:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_42;
        break;
      case 43:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_43;
        break;
      case 44:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_44;
        break;
      case 45:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_45;
        break;
      case 46:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_46;
        break;
      case 47:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_47;
        break;
      case 48:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_48;
        break;
      case 49:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_49;
        break;
      case 50:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_50;
        break;
      case 51:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_51;
        break;
      case 52:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_52;
        break;
      case 53:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_53;
        break;
      case 54:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_54;
        break;
      case 55:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_55;
        break;
      case 56:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_56;
        break;
      case 57:
        localizedSubCategory = AppLocalizations.of(context)!.sub_category_id_57;
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
      case 4:
        localizedIssueState = AppLocalizations.of(context)!.issue_state_id_4;
        break;
    }
    return localizedIssueState.isNotEmpty
        ? localizedIssueState
        : (issueState.name ?? "");
  }

  String getLocalizedReportCategory(
      BuildContext context, ReportCategory? reportCategory) {
    if (reportCategory == null) return "";
    String localizedReportCategory = "";
    switch (reportCategory.id) {
      case 1:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_1;
        break;
      case 2:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_2;
        break;
      case 3:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_3;
        break;
      case 4:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_4;
        break;
      case 5:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_5;
        break;
      case 6:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_6;
        break;
      case 7:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_7;
        break;
      case 8:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_8;
        break;
      case 9:
        localizedReportCategory =
            AppLocalizations.of(context)!.report_category_id_9;
        break;
    }

    return localizedReportCategory.isNotEmpty
        ? localizedReportCategory
        : (reportCategory.name ?? "");
  }

  Future<String?> getLocalizedResponseError(int errorNo) async {
    String? localizedResponseError;
    AppLocalizations appLocalizations = await LocalAppLocalizations.getAppLocalizations();
    switch (errorNo) {
      case 5:
        localizedResponseError =
            appLocalizations.response_error_id_5;
        break;
      case 50:
        localizedResponseError =
            appLocalizations.response_error_id_50;
        break;
      case 100:
        localizedResponseError =
            appLocalizations.response_error_id_100;
        break;
      case 101:
        localizedResponseError =
            appLocalizations.response_error_id_101;
        break;
      case 102:
        localizedResponseError =
            appLocalizations.response_error_id_102;
        break;
      case 103:
        localizedResponseError =
            appLocalizations.response_error_id_103;
        break;
      case 104:
        localizedResponseError =
            appLocalizations.response_error_id_104;
        break;
      case 105:
        localizedResponseError =
            appLocalizations.response_error_id_105;
        break;
      case 106:
        localizedResponseError =
            appLocalizations.response_error_id_106;
        break;
      case 107:
        localizedResponseError =
            appLocalizations.response_error_id_107;
        break;
      case 108:
        localizedResponseError =
            appLocalizations.response_error_id_108;
        break;
      case 200:
        localizedResponseError =
            appLocalizations.response_error_id_200;
        break;
      case 201:
        localizedResponseError =
            appLocalizations.response_error_id_201;
        break;
      case 202:
        localizedResponseError =
            appLocalizations.response_error_id_202;
        break;
      case 203:
        localizedResponseError =
            appLocalizations.response_error_id_203;
        break;
      case 204:
        localizedResponseError =
            appLocalizations.response_error_id_204;
        break;
      case 205:
        localizedResponseError =
            appLocalizations.response_error_id_205;
        break;
      case 206:
        localizedResponseError =
            appLocalizations.response_error_id_206;
        break;
      case 207:
        localizedResponseError =
            appLocalizations.response_error_id_207;
        break;
      case 208:
        localizedResponseError =
            appLocalizations.response_error_id_208;
        break;
      case 300:
        localizedResponseError =
            appLocalizations.response_error_id_300;
        break;
      case 301:
        localizedResponseError =
            appLocalizations.response_error_id_301;
        break;
      case 302:
        localizedResponseError =
            appLocalizations.response_error_id_302;
        break;
      case 303:
        localizedResponseError =
            appLocalizations.response_error_id_303;
        break;
      case 304:
        localizedResponseError =
            appLocalizations.response_error_id_304;
        break;
      case 305:
        localizedResponseError =
            appLocalizations.response_error_id_305;
        break;
    }

    return localizedResponseError;
  }

//endregion
}
