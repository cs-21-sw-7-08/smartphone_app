import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:darq/darq.dart';

import 'custom_list_dialog.dart';
import 'custom_list_dialog_events_states.dart';

class CustomListDialogBloc
    extends Bloc<CustomListDialogEvent, CustomListDialogState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;
  late SearchPredicate _searchPredicate;
  ConfirmPressedCallBack? _confirmPressedCallBack;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  CustomListDialogBloc(
      {required BuildContext buildContext,
      required List<dynamic> items,
      required ConfirmPressedCallBack? confirmPressedCallBack,
      required SearchPredicate searchPredicate})
      : super(CustomListDialogState(
            showSearchBar: false,
            rootItems: items,
            items: items,
            filteredItems: items,
            selectedItemTree: List.empty(growable: true))) {
    _buildContext = buildContext;
    _searchPredicate = searchPredicate;
    _confirmPressedCallBack = confirmPressedCallBack;
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
            Navigator.of(_buildContext).pop(null);
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
          if (_confirmPressedCallBack == null) {
            Navigator.of(_buildContext).pop(null);
            return;
          }
          List<dynamic> list = _confirmPressedCallBack!(state.rootItems!);
          Navigator.of(_buildContext).pop(list);
          break;
      }
    } else if (event is TextChanged) {
      switch (event.textChangedEvent) {
        case CustomListDialogTextChangedEvent.searchText:
          print(event.value);
          yield state.copyWith(
              searchText: event.value,
              filteredItems: _getFilteredItems(
                  items: state.items!, searchText: event.value));
          break;
      }
    } else if (event is ItemWasSelected) {
      // Add selected item to the item tree
      var newSelectedItemTree = state.selectedItemTree!;
      newSelectedItemTree.add(event.selectedItem);

      // If no new list has been given close the dialog and return the selected
      // items tree
      if (event.selectedItem.selectedItems == null) {
        Navigator.of(_buildContext).pop(newSelectedItemTree
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
      yield state.copyWith(filteredItems: state.filteredItems);
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
        .where((element) => _searchPredicate(element, searchText.toLowerCase()))
        .toList(growable: true);
  }

//endregion

}
