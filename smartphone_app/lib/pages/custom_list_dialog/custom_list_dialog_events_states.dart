import 'package:equatable/equatable.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:quiver/collection.dart';

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
  final dynamic updatedItem;

  const ItemWasUpdated({required this.updatedItem});
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
  int? updatedItemHashCode;

  CustomListDialogState(
      {this.showSearchBar,
      this.searchText,
      this.rootItems,
      this.selectedItemTree,
      this.items,
      this.updatedItemHashCode,
      this.filteredItems});

  CustomListDialogState copyWith(
      {bool? showSearchBar,
      String? searchText,
      int? updatedItemHashCode,
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
        updatedItemHashCode: updatedItemHashCode ?? this.updatedItemHashCode,
        items: items ?? this.items);
  }

  CustomListDialogState update({required int updatedItemHashCode}) {
    return copyWith(updatedItemHashCode: updatedItemHashCode);
  }

  @override
  List<Object?> get props => [
        showSearchBar,
        searchText,
        rootItems,
        selectedItemTree,
        items,
        filteredItems,
        updatedItemHashCode
      ];
}

//endregion
