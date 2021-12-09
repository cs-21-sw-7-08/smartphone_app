import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_bloc.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog_events_states.dart';

void main() {
  group("CustomListDialogEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(
              buttonEvent: CustomListDialogButtonEvent.backPressed),
          const ButtonPressed(
              buttonEvent: CustomListDialogButtonEvent.backPressed),
        );
      });
    });

    group("TextChanged", () {
      test("Supports value comparisons", () {
        expect(
          const TextChanged(
              textChangedEvent: CustomListDialogTextChangedEvent.searchText,
              text: "1234"),
          const TextChanged(
              textChangedEvent: CustomListDialogTextChangedEvent.searchText,
              text: "1234"),
        );
      });
    });

    group("ItemWasSelected", () {
      test("Supports value comparisons", () {
        expect(
          ItemWasSelected(
              selectedItem:
                  SelectedItem(selectedItem: 1, selectedItems: const [1, 2])),
          ItemWasSelected(
              selectedItem:
                  SelectedItem(selectedItem: 1, selectedItems: const [1, 2])),
        );
      });

      group("ItemWasUpdated", () {
        test("Supports value comparisons", () {
          expect(
            const ItemWasUpdated(updatedItem: 1),
            const ItemWasUpdated(updatedItem: 1),
          );
        });
      });
    });
  });
}
