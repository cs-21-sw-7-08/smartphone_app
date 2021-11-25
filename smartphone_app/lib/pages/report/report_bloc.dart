import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

import 'report_events_states.dart';

class ReportBloc extends Bloc<ReportEvent, ReportState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  ReportBloc({required BuildContext buildContext}) : super(ReportState()) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<ReportState> mapEventToState(ReportEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.buttonEvent) {

        /// Close
        case ReportButtonEvent.close:
          // Close dialog
          Navigator.of(_buildContext).pop(null);
          break;

        /// Select report category
        case ReportButtonEvent.selectReportCategory:
          ReportState? newState = await _selectReportCategory();
          if (newState == null) return;
          yield newState;
          break;

        /// Confirm
        case ReportButtonEvent.confirm:
          if (state.reportCategory == null) {
            GeneralUtil.showToast(
                AppLocalizations.of(_buildContext)!.please_select_a_category);
            return;
          }
          Navigator.of(_buildContext).pop(state.reportCategory);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<ReportState?> _selectReportCategory() async {
    List<ReportCategory> categories =
        AppValuesHelper.getInstance().getReportCategories();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
        items: categories, itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
      if (item is ReportCategory) {
        return Container(
            margin: EdgeInsets.only(
                top: index == 0 && showSearchBar ? 0 : values.padding,
                left: values.padding,
                right: values.padding,
                bottom: index == list.length - 1 ? values.padding : 0),
            child: CustomListTile(
                widget: Container(
                  color: Colors.transparent,
                  child: Column(
                    children: [
                      CustomLabel(
                        title: item.name!,
                        margin: const EdgeInsets.only(
                            left: values.padding,
                            top: values.padding * 2,
                            right: values.padding,
                            bottom: values.padding * 2),
                      )
                    ],
                  ),
                ),
                onPressed: () {
                  itemSelected(null);
                }));
      }
    }, searchPredicate: (item, searchString) {
      if (item is ReportCategory) {
        return item.name!.toLowerCase().contains(searchString);
      }
      return false;
    }, titleBuilder: (item) {
      if (item == null) {
        return AppLocalizations.of(_buildContext)!.category;
      }
      return "";
    });
    if (selectedItems == null) return null;
    ReportCategory? selectedReportCategory = selectedItems
        .firstWhere((element) => element is ReportCategory, orElse: () => null);
    if (selectedReportCategory == null) return null;
    return state.copyWith(reportCategory: selectedReportCategory);
  }

//endregion

}
