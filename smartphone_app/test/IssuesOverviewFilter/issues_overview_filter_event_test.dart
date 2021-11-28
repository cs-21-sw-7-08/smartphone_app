import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("ReportEvent", () {
    group("ButtonPressed", () {
      test("Supports value comparisons", () {
        expect(
          const ButtonPressed(
              buttonEvent:
                  IssuesOverviewFilterButtonEvent.selectMunicipalities),
          const ButtonPressed(
              buttonEvent:
                  IssuesOverviewFilterButtonEvent.selectMunicipalities),
        );
      });
    });

    group("IssueStatePressed", () {
      test("Supports value comparisons", () {
        expect(
          IssueStatePressed(
              issueStateFilterItem: IssueStateFilterItem(
                  issueState: IssueState(id: 1), isSelected: true)),
          IssueStatePressed(
              issueStateFilterItem: IssueStateFilterItem(
                  issueState: IssueState(id: 1), isSelected: true)),
        );
      });
    });

    group("CategoryPressed", () {
      test("Supports value comparisons", () {
        expect(
          CategoryPressed(
              categoryFilterItem: CategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategories: null)),
          CategoryPressed(
              categoryFilterItem: CategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategories: null)),
        );
      });
    });

    group("CategoryInSubCategoryPressed", () {
      test("Supports value comparisons", () {
        expect(
          CategoryInSubCategoryPressed(
              categoryFilterItem: CategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategories: null)),
          CategoryInSubCategoryPressed(
              categoryFilterItem: CategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategories: null)),
        );
      });
    });

    group("SubCategoryPressed", () {
      test("Supports value comparisons", () {
        expect(
          SubCategoryPressed(
              subCategoryFilterItem: SubCategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategory: SubCategory(id: 1))),
          SubCategoryPressed(
              subCategoryFilterItem: SubCategoryFilterItem(
                  category: Category(id: 1),
                  isSelected: true,
                  subCategory: SubCategory(id: 1))),
        );
      });
    });

    group("MunicipalityPressed", () {
      test("Supports value comparisons", () {
        expect(
          MunicipalityPressed(
              municipalityFilterItem: MunicipalityFilterItem(
                  municipality: Municipality(id: 1), isSelected: true)),
          MunicipalityPressed(
              municipalityFilterItem: MunicipalityFilterItem(
                  municipality: Municipality(id: 1), isSelected: true)),
        );
      });
    });

    group("FilterUpdated", () {
      test("Supports value comparisons", () {
        expect(
          FilterUpdated(categories: [
            CategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategories: null)
          ], subCategories: [
            SubCategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategory: SubCategory(id: 1))
          ], municipalities: [
            MunicipalityFilterItem(
                municipality: Municipality(id: 1), isSelected: true)
          ], issueStates: [
            IssueStateFilterItem(
                issueState: IssueState(id: 1), isSelected: true)
          ], isOnlyShowingOwnIssues: false),
          FilterUpdated(categories: [
            CategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategories: null)
          ], subCategories: [
            SubCategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategory: SubCategory(id: 1))
          ], municipalities: [
            MunicipalityFilterItem(
                municipality: Municipality(id: 1), isSelected: true)
          ], issueStates: [
            IssueStateFilterItem(
                issueState: IssueState(id: 1), isSelected: true)
          ], isOnlyShowingOwnIssues: false),
        );
      });
    });

    group("ValueSelected", () {
      test("Supports value comparisons", () {
        expect(
          ValueSelected(valueSelectedEvent: IssuesOverviewFilterValueSelectedEvent.subCategories, value: [SubCategoryFilterItem(
              category: Category(id: 1),
              isSelected: true,
              subCategory: SubCategory(id: 1))]),
          ValueSelected(valueSelectedEvent: IssuesOverviewFilterValueSelectedEvent.subCategories, value: [SubCategoryFilterItem(
              category: Category(id: 1),
              isSelected: true,
              subCategory: SubCategory(id: 1))]),
        );
      });
    });
  });
}
