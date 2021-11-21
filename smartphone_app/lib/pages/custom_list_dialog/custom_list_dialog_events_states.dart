

import 'custom_list_dialog.dart';

///
/// ENUMS
///
//region Enums

enum CustomListDialogButtonEvent { changeSearchBarVisibility, backPressed, confirm }
enum CustomListDialogTextChangedEvent { searchText }

//endregion

///
/// EVENT
///
//region Event

class CustomListDialogEvent {}

class ButtonPressed extends CustomListDialogEvent {
  final CustomListDialogButtonEvent customListDialogButtonEvent;

  ButtonPressed({required this.customListDialogButtonEvent});
}

class TextChanged extends CustomListDialogEvent {
  final CustomListDialogTextChangedEvent customListDialogTextChangedEvent;
  String? value;

  TextChanged(
      {required this.customListDialogTextChangedEvent, required this.value});
}

class ItemWasSelected extends CustomListDialogEvent {
  SelectedItem selectedItem;

  ItemWasSelected({required this.selectedItem});
}

class ItemWasUpdated extends CustomListDialogEvent {
  ItemWasUpdated();
}

//endregion

///
/// STATE
///
//region State

class CustomListDialogState {
  bool? showSearchBar;
  String? searchText;
  List<dynamic>? rootItems;
  List<dynamic>? items;
  List<dynamic>? filteredItems;
  List<SelectedItem>? selectedItemTree;

  CustomListDialogState(
      {this.showSearchBar,
      this.searchText,
      this.rootItems,
      this.selectedItemTree,
      this.items,
      this.filteredItems});

  CustomListDialogState copyWith(
      {bool? showSearchBar,
      String? searchText,
      List<dynamic>? rootItems,
      List<dynamic>? items,
      List<dynamic>? filteredItems,
      List<SelectedItem>? selectedItemTree}) {
    return CustomListDialogState(
        rootItems: rootItems ?? this.rootItems,
        showSearchBar: showSearchBar ?? this.showSearchBar,
        filteredItems: filteredItems ?? this.filteredItems,
        selectedItemTree: selectedItemTree ?? this.selectedItemTree,
        searchText: searchText ?? this.searchText,
        items: items ?? this.items);
  }
}

//endregion
