import 'package:equatable/equatable.dart';
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
  close,
  applyFilter,
  resetAll,
  resetIssueStates,
  resetCategories,
  resetSubCategories,
  resetMunicipalities
}

enum IssuesOverviewFilterValueSelectedEvent {
  categories,
  subCategories,
  municipalities
}

//endregion

///
/// EVENT
///
//region Event

abstract class IssuesOverviewFilterEvent extends Equatable {
  const IssuesOverviewFilterEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends IssuesOverviewFilterEvent {
  final IssuesOverviewFilterButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class IssueStatePressed extends IssuesOverviewFilterEvent {
  final IssueStateFilterItem issueStateFilterItem;

  const IssueStatePressed({required this.issueStateFilterItem});

  @override
  List<Object?> get props => [issueStateFilterItem];
}

class CategoryPressed extends IssuesOverviewFilterEvent {
  final CategoryFilterItem categoryFilterItem;

  const CategoryPressed({required this.categoryFilterItem});

  @override
  List<Object?> get props => [categoryFilterItem];
}

class CategoryInSubCategoryPressed extends IssuesOverviewFilterEvent {
  final CategoryFilterItem categoryFilterItem;

  const CategoryInSubCategoryPressed({required this.categoryFilterItem});

  @override
  List<Object?> get props => [categoryFilterItem];
}

class SubCategoryPressed extends IssuesOverviewFilterEvent {
  final SubCategoryFilterItem subCategoryFilterItem;

  const SubCategoryPressed({required this.subCategoryFilterItem});

  @override
  List<Object?> get props => [subCategoryFilterItem];
}

class MunicipalityPressed extends IssuesOverviewFilterEvent {
  final MunicipalityFilterItem municipalityFilterItem;

  const MunicipalityPressed({required this.municipalityFilterItem});

  @override
  List<Object?> get props => [municipalityFilterItem];
}

class FilterUpdated extends IssuesOverviewFilterEvent {
  final List<CategoryFilterItem> categories;
  final List<SubCategoryFilterItem> subCategories;
  final List<MunicipalityFilterItem> municipalities;
  final List<IssueStateFilterItem> issueStates;
  final bool isOnlyShowingOwnIssues;

  const FilterUpdated(
      {required this.categories,
      required this.subCategories,
      required this.municipalities,
      required this.issueStates,
      required this.isOnlyShowingOwnIssues});

  @override
  List<Object?> get props => [
        categories,
        subCategories,
        municipalities,
        issueStates,
        isOnlyShowingOwnIssues
      ];
}

class ValueSelected<T> extends IssuesOverviewFilterEvent {
  final IssuesOverviewFilterValueSelectedEvent valueSelectedEvent;
  final T value;

  const ValueSelected({required this.valueSelectedEvent, required this.value});

  @override
  List<Object?> get props => [valueSelectedEvent, value];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class IssuesOverviewFilterState extends Equatable {
  List<CategoryFilterItem>? categories;
  List<SubCategoryFilterItem>? subCategories;
  List<MunicipalityFilterItem>? municipalities;
  List<IssueStateFilterItem>? issueStates;
  bool? isOnlyShowingOwnIssues;
  int? updatedItemHashCode;

  IssuesOverviewFilterState(
      {this.categories,
      this.subCategories,
      this.municipalities,
      this.isOnlyShowingOwnIssues,
      this.updatedItemHashCode,
      this.issueStates});

  IssuesOverviewFilterState copyWith({
    List<CategoryFilterItem>? categories,
    List<SubCategoryFilterItem>? subCategories,
    bool? isOnlyShowingOwnIssues,
    int? updatedItemHashCode,
    List<MunicipalityFilterItem>? municipalities,
    List<IssueStateFilterItem>? issueStates,
  }) {
    return IssuesOverviewFilterState(
        categories: categories ?? this.categories,
        subCategories: subCategories ?? this.subCategories,
        isOnlyShowingOwnIssues:
            isOnlyShowingOwnIssues ?? this.isOnlyShowingOwnIssues,
        updatedItemHashCode: updatedItemHashCode ?? this.updatedItemHashCode,
        municipalities: municipalities ?? this.municipalities,
        issueStates: issueStates ?? this.issueStates);
  }

  IssuesOverviewFilterState update({required int updatedItemHashCode}) {
    return copyWith(updatedItemHashCode: updatedItemHashCode);
  }

  @override
  List<Object?> get props => [
        categories,
        subCategories,
        municipalities,
        isOnlyShowingOwnIssues,
        issueStates,
        updatedItemHashCode
      ];
}

//endregion
