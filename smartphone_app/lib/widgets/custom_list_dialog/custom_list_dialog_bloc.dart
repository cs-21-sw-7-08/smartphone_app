import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/widgets/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/widgets/custom_list_dialog/custom_list_dialog_events_states.dart';

class CustomListDialogBloc
    extends Bloc<CustomListDialogEvent, CustomListDialogState> {
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

  CustomListDialogBloc(
      {required BuildContext buildContext, required List<dynamic> items})
      : super(CustomListDialogState(
            showSearchBar: false,
            rootItems: items,
            items: items,
            filteredItems: items,
            selectedItemTree: List.empty(growable: true))) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<CustomListDialogState> mapEventToState(
      CustomListDialogEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.customListDialogButtonEvent) {
        case CustomListDialogButtonEvent.changeSearchBarVisibility:
          yield state.copyWith(showSearchBar: !state.showSearchBar!);
          break;
        case CustomListDialogButtonEvent.backPressed:
          if (state.selectedItemTree!.isEmpty) {
            Navigator.of(_buildContext).pop(false);
          } else {
            var newSelectedItemTree = state.selectedItemTree!
                .sublist(0, state.selectedItemTree!.length - 2);
            var newItems = newSelectedItemTree.isEmpty
                ? state.rootItems!
                : newSelectedItemTree.last.selectedItems;
            state.searchText = null;
            yield state.copyWith(
                items: newItems,
                filteredItems: getFilteredItems(newItems),
                selectedItemTree: newSelectedItemTree);
          }
          break;
      }
    } else if (event is TextChanged) {
      switch (event.customListDialogTextChangedEvent) {
        case CustomListDialogTextChangedEvent.searchText:
          yield state.copyWith(searchText: event.value);
          break;
      }
    } else if (event is ItemWasSelected) {
      var newSelectedItemTree = state.selectedItemTree!;
      newSelectedItemTree.add(event.selectedItem);
      var newItems = newSelectedItemTree.last.selectedItems;
      state.searchText = null;
      yield state.copyWith(
          items: newItems,
          filteredItems: getFilteredItems(newItems),
          selectedItemTree: newSelectedItemTree);
    }
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  List<dynamic> getFilteredItems(List<dynamic> items) {
    return items;
  }

//endregion

}
