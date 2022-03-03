import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
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

  late BuildContext context;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  ReportBloc({required this.context}) : super(ReportState());

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
          Navigator.of(context).pop(null);
          break;

        /// Select report category
        case ReportButtonEvent.selectReportCategory:
          await _selectReportCategory();
          break;

        /// Confirm
        case ReportButtonEvent.confirm:
          if (state.reportCategory == null) {
            GeneralUtil.showToast(
                AppLocalizations.of(context)!.please_select_a_category);
            return;
          }
          Navigator.of(context).pop(state.reportCategory);
          break;
      }
    } else if (event is ValueSelected) {
      switch (event.valueSelectedEvent) {
        case ReportValueSelectedEvent.reportCategory:
          yield state.copyWith(reportCategory: event.value);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<void> _selectReportCategory() async {
    List<ReportCategory> categories =
        AppValuesHelper.getInstance().getReportCategories();
    List<dynamic>? selectedItems =
        await CustomListDialog.show(context, items: categories, itemBuilder:
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
                        title: LocalizationHelper.getInstance()
                            .getLocalizedReportCategory(context, item),
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
        return LocalizationHelper.getInstance()
            .getLocalizedReportCategory(context, item)
            .toLowerCase()
            .contains(searchString);
        return item.name!.toLowerCase().contains(searchString);
      }
      return false;
    }, titleBuilder: (item) {
      if (item == null) {
        return AppLocalizations.of(context)!.category;
      }
      return "";
    });
    if (selectedItems == null) return;
    ReportCategory? selectedReportCategory = selectedItems
        .firstWhere((element) => element is ReportCategory, orElse: () => null);
    if (selectedReportCategory == null) return;

    // Fire event
    add(ValueSelected(
        valueSelectedEvent: ReportValueSelectedEvent.reportCategory,
        value: selectedReportCategory));
  }

//endregion

}
