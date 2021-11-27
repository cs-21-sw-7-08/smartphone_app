import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:darq/darq.dart';

import 'custom_list_dialog_events_states.dart';

typedef ItemSelected = Function(List<dynamic>? newList);
typedef ItemUpdated = Function();
typedef ItemBuilder = Widget? Function(
    int index,
    dynamic item,
    List<dynamic> list,
    bool showSearchBar,
    ItemSelected itemSelected,
    ItemUpdated itemUpdated);
typedef SearchPredicate = bool Function(dynamic item, String searchString);
typedef TitleBuilder = String Function(dynamic item);
typedef ConfirmPressedCallBack = List<dynamic> Function(
    List<dynamic> currentRootList);

// ignore: must_be_immutable
class SelectedItem {
  dynamic selectedItem;
  List<dynamic>? selectedItems;

  SelectedItem({required this.selectedItem, required this.selectedItems});
}

class CustomListDialogBloc
    extends Bloc<CustomListDialogEvent, CustomListDialogState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;
  late SearchPredicate searchPredicate;
  ConfirmPressedCallBack? confirmPressedCallBack;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  CustomListDialogBloc(
      {required this.context,
      required List<dynamic> items,
      required this.confirmPressedCallBack,
      required this.searchPredicate})
      : super(CustomListDialogState(
            showSearchBar: false,
            rootItems: items,
            items: items,
            filteredItems: items,
            selectedItemTree: List.empty(growable: true)));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<CustomListDialogState> mapEventToState(
      CustomListDialogEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.buttonEvent) {
        case CustomListDialogButtonEvent.changeSearchBarVisibility:
          yield state.copyWith(
              showSearchBar: !state.showSearchBar!,
              searchText: "",
              filteredItems: _getFilteredItems(items: state.items!));
          break;
        case CustomListDialogButtonEvent.backPressed:
          // Hide keyboard
          GeneralUtil.hideKeyboard();
          // If the selected item tree is empty close the dialog
          if (state.selectedItemTree!.isEmpty) {
            Navigator.of(context).pop(null);
          } else {
            // New end index removes the last item in the selected item tree
            var endIndex = state.selectedItemTree!.length - 2;
            if (endIndex < 0) endIndex = 0;
            // Get new item tree
            var newSelectedItemTree =
                state.selectedItemTree!.sublist(0, endIndex);
            // Get new items, if the selected item is empty use the root items
            var newItems = newSelectedItemTree.isEmpty
                ? state.rootItems!
                : newSelectedItemTree.last.selectedItems;
            // Yield new state
            yield state.copyWith(
                searchText: "",
                items: newItems,
                filteredItems: _getFilteredItems(items: newItems!),
                selectedItemTree: newSelectedItemTree);
          }
          break;
        case CustomListDialogButtonEvent.confirm:
          if (confirmPressedCallBack == null) {
            Navigator.of(context).pop(null);
            return;
          }
          List<dynamic> list = confirmPressedCallBack!(state.rootItems!);
          Navigator.of(context).pop(list);
          break;
      }
    } else if (event is TextChanged) {
      switch (event.textChangedEvent) {

        /// Search text
        case CustomListDialogTextChangedEvent.searchText:
          yield state.copyWith(
              searchText: event.text,
              filteredItems: _getFilteredItems(
                  items: state.items!, searchText: event.text));
          break;
      }
    } else if (event is ItemWasSelected) {
      // Add selected item to the item tree
      var newSelectedItemTree = state.selectedItemTree!;
      newSelectedItemTree.add(event.selectedItem);

      // If no new list has been given close the dialog and return the selected
      // items tree
      if (event.selectedItem.selectedItems == null) {
        Navigator.of(context).pop(newSelectedItemTree
            .select((element, index) => element.selectedItem)
            .toList());
        return;
      }
      // Get the new items
      var newItems = newSelectedItemTree.last.selectedItems;
      // Yield new state
      yield state.copyWith(
          searchText: "",
          items: newItems,
          filteredItems: _getFilteredItems(items: newItems!),
          selectedItemTree: newSelectedItemTree);
    } else if (event is ItemWasUpdated) {
      // Yield new state
      yield state.update(updatedItemHashCode: event.updatedItem.hashCode);
    }
  }

//endregion

  ///
  /// METHODS
  ///
//region Methods

  List<dynamic> _getFilteredItems(
      {required List<dynamic> items, String? searchText}) {
    if (searchText == null || searchText.isEmpty) {
      return items;
    }
    return items
        .where((element) => searchPredicate(element, searchText.toLowerCase()))
        .toList(growable: true);
  }

//endregion

}
