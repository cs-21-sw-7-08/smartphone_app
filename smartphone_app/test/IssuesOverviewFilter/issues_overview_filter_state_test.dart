import 'package:flutter_test/flutter_test.dart';
import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

void main() {
  group("IssuesOverviewFilterState", () {
    test("Supports value comparisons", () {
      var state = IssuesOverviewFilterState();
      state = state.copyWith(
          updatedItemHashCode: 100,
          categories: [
            CategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategories: null)
          ],
          subCategories: [
            SubCategoryFilterItem(
                category: Category(id: 1),
                isSelected: true,
                subCategory: SubCategory(id: 1))
          ],
          municipalities: [
            MunicipalityFilterItem(
                municipality: Municipality(id: 1), isSelected: true)
          ],
          issueStates: [
            IssueStateFilterItem(
                issueState: IssueState(id: 1), isSelected: true)
          ],
          isOnlyShowingOwnIssues: false);
      expect(
          state,
          IssuesOverviewFilterState(
              updatedItemHashCode: 100,
              categories: [
                CategoryFilterItem(
                    category: Category(id: 1),
                    isSelected: true,
                    subCategories: null)
              ],
              subCategories: [
                SubCategoryFilterItem(
                    category: Category(id: 1),
                    isSelected: true,
                    subCategory: SubCategory(id: 1))
              ],
              municipalities: [
                MunicipalityFilterItem(
                    municipality: Municipality(id: 1), isSelected: true)
              ],
              issueStates: [
                IssueStateFilterItem(
                    issueState: IssueState(id: 1), isSelected: true)
              ],
              isOnlyShowingOwnIssues: false));
    });
  });
}
