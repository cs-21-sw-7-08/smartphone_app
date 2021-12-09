import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_bloc.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_events_states.dart';

import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  group("CustomListDialog", () {
    late CustomListDialogBloc bloc;
    var items = [1, 2];
    var newItems = [1, 2, 3];

    setUp(() {
      bloc = CustomListDialogBloc(
          context: MockBuildContext(),
          searchPredicate: (item, String searchString) {
            return true;
          },
          confirmPressedCallBack: (List<dynamic> currentRootList) {
            return currentRootList;
          },
          items: items);
    });

    test("Initial state is correct", () {
      expect(
          bloc.state,
          CustomListDialogState(
              showSearchBar: true,
              rootItems: items,
              items: items,
              filteredItems: items,
              selectedItemTree: List.empty(growable: true)));
    });

    blocTest<CustomListDialogBloc, CustomListDialogState>(
        "ChangeSearchBarVisibility",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent:
                CustomListDialogButtonEvent.changeSearchBarVisibility)),
        expect: () => [
              bloc.state.copyWith(
                  showSearchBar: false, searchText: "", filteredItems: items)
            ]);

    blocTest<CustomListDialogBloc, CustomListDialogState>(
        "ButtonPressed -> Back",
        build: () => bloc,
        act: (bloc) {
          bloc.state.selectedItemTree = [
            SelectedItem(selectedItem: 1, selectedItems: newItems)
          ];
          bloc.add(const ButtonPressed(
              buttonEvent: CustomListDialogButtonEvent.backPressed));
        },
        expect: () => [
              bloc.state.copyWith(
                  searchText: "",
                  items: items,
                  filteredItems: items,
                  selectedItemTree: [])
            ]);

    blocTest<CustomListDialogBloc, CustomListDialogState>(
        "TextChanged -> Search text",
        build: () => bloc,
        act: (bloc) => bloc.add(const TextChanged(
            textChangedEvent: CustomListDialogTextChangedEvent.searchText,
            text: "1234")),
        expect: () => [bloc.state.copyWith(searchText: "1234")]);

    blocTest<CustomListDialogBloc, CustomListDialogState>("ItemWasSelected",
        build: () => bloc,
        act: (bloc) => bloc.add(ItemWasSelected(
            selectedItem:
                SelectedItem(selectedItem: 1, selectedItems: newItems))),
        expect: () => [
              bloc.state.copyWith(
                  searchText: "",
                  items: newItems,
                  filteredItems: newItems,
                  selectedItemTree: [
                    SelectedItem(selectedItem: 1, selectedItems: newItems)
                  ])
            ]);

    blocTest<CustomListDialogBloc, CustomListDialogState>("ItemWasUpdated",
        build: () => bloc,
        act: (bloc) => bloc.add(const ItemWasUpdated(updatedItem: 1)),
        expect: () => [bloc.state.copyWith(updatedItemHashCode: 1.hashCode)]);
  });
}
