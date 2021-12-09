import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_bloc.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_events_states.dart';

void main() {
  group("CustomListDialogState", () {
    var items = const [1, 2];

    test("Supports value comparisons", () {
      var state = CustomListDialogState();
      state = state.copyWith(
          selectedItemTree: [
            SelectedItem(selectedItem: 1, selectedItems: items)
          ],
          filteredItems: items,
          items: items,
          updatedItemHashCode: 10,
          searchText: "",
          showSearchBar: false,
          rootItems: items);
      expect(
          state,
          CustomListDialogState(
              selectedItemTree: [
                SelectedItem(selectedItem: 1, selectedItems: items)
              ],
              filteredItems: items,
              items: items,
              updatedItemHashCode: 10,
              searchText: "",
              showSearchBar: false,
              rootItems: items));
    });
  });
}
