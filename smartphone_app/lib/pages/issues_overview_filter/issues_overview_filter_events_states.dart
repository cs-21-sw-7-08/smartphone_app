import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';

///
/// ENUMS
///
//region Enums

enum IssuesOverviewFilterButtonEvent {
  selectCategories,
  selectSubCategories,
  selectMunicipalities,
  onlyShowYourOwnIssues,
  closePressed,
  applyFilter,
  resetAll,
  resetIssueStates,
  resetCategories,
  resetSubCategories,
  resetMunicipalities
}

//endregion

///
/// EVENT
///
//region Event

class IssuesOverviewFilterEvent {}

class ButtonPressed extends IssuesOverviewFilterEvent {
  final IssuesOverviewFilterButtonEvent issuesOverviewFilterButtonEvent;

  ButtonPressed({required this.issuesOverviewFilterButtonEvent});
}

class IssueStatePressed extends IssuesOverviewFilterEvent {
  final int index;
  final IssueStateFilterItem issueStateFilterItem;

  IssueStatePressed({required this.index, required this.issueStateFilterItem});
}

class CategoryPressed extends IssuesOverviewFilterEvent {
  final int index;
  final CategoryFilterItem categoryFilterItem;

  CategoryPressed({required this.index, required this.categoryFilterItem});
}

class SubCategoryPressed extends IssuesOverviewFilterEvent {
  final int index;
  final SubCategoryFilterItem subCategoryFilterItem;

  SubCategoryPressed(
      {required this.index, required this.subCategoryFilterItem});
}

class MunicipalityPressed extends IssuesOverviewFilterEvent {
  final int index;
  final MunicipalityFilterItem municipalityFilterItem;

  MunicipalityPressed(
      {required this.index, required this.municipalityFilterItem});
}

//endregion

///
/// STATE
///
//region State

class IssuesOverviewFilterState {
  List<CategoryFilterItem>? categories;
  List<SubCategoryFilterItem>? subCategories;
  List<MunicipalityFilterItem>? municipalities;
  List<IssueStateFilterItem>? issueStates;
  bool? isOnlyShowingOwnIssues;

  IssuesOverviewFilterState(
      {this.categories,
      this.subCategories,
      this.municipalities,
      this.isOnlyShowingOwnIssues,
      this.issueStates});

  IssuesOverviewFilterState copyWith({
    List<CategoryFilterItem>? categories,
    List<SubCategoryFilterItem>? subCategories,
    bool? isOnlyShowingOwnIssues,
    List<MunicipalityFilterItem>? municipalities,
    List<IssueStateFilterItem>? issueStates,
  }) {
    return IssuesOverviewFilterState(
        categories: categories ?? this.categories,
        subCategories: subCategories ?? this.subCategories,
        isOnlyShowingOwnIssues:
            isOnlyShowingOwnIssues ?? this.isOnlyShowingOwnIssues,
        municipalities: municipalities ?? this.municipalities,
        issueStates: issueStates ?? this.issueStates);
  }
}

//endregion
