import 'package:equatable/equatable.dart';

import 'custom_list_dialog_bloc.dart';

///
/// ENUMS
///
//region Enums

enum CustomListDialogButtonEvent {
  changeSearchBarVisibility,
  backPressed,
  confirm
}
enum CustomListDialogTextChangedEvent { searchText }

//endregion

///
/// EVENT
///
//region Event

abstract class CustomListDialogEvent extends Equatable {
  const CustomListDialogEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends CustomListDialogEvent {
  final CustomListDialogButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class TextChanged extends CustomListDialogEvent {
  final CustomListDialogTextChangedEvent textChangedEvent;
  final String? text;

  const TextChanged({required this.textChangedEvent, required this.text});

  @override
  List<Object?> get props => [textChangedEvent, text];
}

class ItemWasSelected extends CustomListDialogEvent {
  final SelectedItem selectedItem;

  const ItemWasSelected({required this.selectedItem});

  @override
  List<Object?> get props => [selectedItem];
}

class ItemWasUpdated extends CustomListDialogEvent {
  const ItemWasUpdated();
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class CustomListDialogState extends Equatable {
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

  @override
  List<Object?> get props => [
        showSearchBar,
        searchText,
        rootItems,
        items,
        filteredItems,
        selectedItemTree
      ];
}

//endregion
