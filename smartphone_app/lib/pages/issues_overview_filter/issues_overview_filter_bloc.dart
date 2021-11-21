import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/pages/custom_list_dialog/custom_list_dialog.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:darq/darq.dart';
import 'package:smartphone_app/widgets/custom_label.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class IssuesOverviewFilterBloc
    extends Bloc<IssuesOverviewFilterEvent, IssuesOverviewFilterState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;
  late IssuesOverviewFilter _filter;

  //endregion

  ///
  /// DEFAULT VALUES
  ///
  //region Default values

  static List<IssueStateFilterItem> _getDefaultIssueStates() {
    List<IssueStateFilterItem> issueStateFilterItems =
        List.empty(growable: true);
    issueStateFilterItems.add(IssueStateFilterItem(
        isSelected: true, issueState: IssueState(id: 1, name: "Created")));
    issueStateFilterItems.add(IssueStateFilterItem(
        isSelected: true, issueState: IssueState(id: 2, name: "Approved")));
    issueStateFilterItems.add(IssueStateFilterItem(
        isSelected: false, issueState: IssueState(id: 3, name: "Resolved")));
    issueStateFilterItems.add(IssueStateFilterItem(
        isSelected: false,
        issueState: IssueState(id: 4, name: "Not resolved")));
    return issueStateFilterItems;
  }

  static List<MunicipalityFilterItem> _getDefaultMunicipalities() {
    // Create list
    List<MunicipalityFilterItem> municipalityFilterItems =
        List.empty(growable: true);
    // Get municipalities
    List<Municipality?> municipalities =
        AppValuesHelper.getInstance().getMunicipalities();
    // Get default municipality ID
    int defaultMunicipalityId = AppValuesHelper.getInstance()
        .getInteger(AppValuesKey.defaultMunicipalityId)!;
    // Get municipality
    Municipality? municipality;
    try {
      municipality = municipalities
          .firstWhere((element) => element!.id == defaultMunicipalityId);
    } on StateError catch (_) {}
    if (municipality != null) {
      municipalityFilterItems.add(MunicipalityFilterItem(
          municipality: municipality, isSelected: false));
    }
    return municipalityFilterItems;
  }

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  IssuesOverviewFilterBloc(
      {required BuildContext buildContext,
      required IssuesOverviewFilter filter})
      : super(IssuesOverviewFilterState(
            municipalities: List.empty(),
            categories: List.empty(),
            subCategories: List.empty(),
            issueStates: List.empty(),
            isOnlyShowingOwnIssues: false)) {
    _buildContext = buildContext;
    _filter = filter;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssuesOverviewFilterState> mapEventToState(
      IssuesOverviewFilterEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.issuesOverviewFilterButtonEvent) {
        case IssuesOverviewFilterButtonEvent.selectCategories:
          IssuesOverviewFilterState? newState = await _selectCategories();
          if (newState == null) return;
          yield newState;
          break;
        case IssuesOverviewFilterButtonEvent.selectSubCategories:
          IssuesOverviewFilterState? newState = await _selectSubCategories();
          if (newState == null) return;
          yield newState;
          break;
        case IssuesOverviewFilterButtonEvent.selectMunicipalities:
          IssuesOverviewFilterState? newState = await _selectMunicipalities();
          if (newState == null) return;
          yield newState;
          break;
        case IssuesOverviewFilterButtonEvent.onlyShowYourOwnIssues:
          yield state.copyWith(
              isOnlyShowingOwnIssues: !state.isOnlyShowingOwnIssues!);
          break;
        case IssuesOverviewFilterButtonEvent.closePressed:
          Navigator.of(_buildContext).pop(null);
          break;
        case IssuesOverviewFilterButtonEvent.applyFilter:
          // Category IDs
          List<int> categoryIds = state.categories!
              .select((element, index) => element.category.id)
              .toList(growable: true);
          // SubCategory IDs
          List<int> subCategoryIds = state.subCategories!
              .select((element, index) => element.subCategory.id)
              .toList(growable: true);
          // Issue state IDs
          List<int> issueStateIds = state.issueStates!
              .where((element) => element.isSelected)
              .select((element, index) => element.issueState.id)
              .toList(growable: true);
          // Municipality IDs
          var municipalityIds = state.municipalities!
              .select((element, index) => element.municipality.id)
              .toList(growable: true);
          // Filter
          IssuesOverviewFilter filter = IssuesOverviewFilter(
              categoryIds: categoryIds.isEmpty ? null : categoryIds,
              subCategoryIds: subCategoryIds.isEmpty ? null : subCategoryIds,
              isBlocked: false,
              citizenIds: state.isOnlyShowingOwnIssues!
                  ? [
                      AppValuesHelper.getInstance()
                          .getInteger(AppValuesKey.citizenId)!
                    ]
                  : null,
              issueStateIds: issueStateIds.isEmpty ? null : issueStateIds,
              municipalityIds:
                  municipalityIds.isEmpty ? null : municipalityIds);
          // Return filter to parent
          Navigator.of(_buildContext).pop(filter);
          break;
        case IssuesOverviewFilterButtonEvent.resetIssueStates:
          yield state.copyWith(issueStates: _getDefaultIssueStates());
          break;
        case IssuesOverviewFilterButtonEvent.resetCategories:
          yield state.copyWith(
              categories: List.empty(), subCategories: List.empty());
          break;
        case IssuesOverviewFilterButtonEvent.resetSubCategories:
          yield state.copyWith(subCategories: List.empty());
          break;
        case IssuesOverviewFilterButtonEvent.resetMunicipalities:
          yield state.copyWith(municipalities: _getDefaultMunicipalities());
          break;
        case IssuesOverviewFilterButtonEvent.resetAll:
          yield state.copyWith(
              issueStates: _getDefaultIssueStates(),
              categories: List.empty(),
              subCategories: List.empty(),
              municipalities: _getDefaultMunicipalities(),
              isOnlyShowingOwnIssues: false);
          break;
      }
    } else if (event is IssueStatePressed) {
      event.issueStateFilterItem.isSelected =
          !event.issueStateFilterItem.isSelected;
      yield state.copyWith(issueStates: state.issueStates);
    } else if (event is CategoryPressed) {
      yield state.copyWith(
          categories: state.categories!
              .where((element) => element != event.categoryFilterItem)
              .toList());
    } else if (event is CategoryInSubCategoryPressed) {
      yield state.copyWith(
          subCategories: state.subCategories!
              .where((element) =>
                  element.category != event.categoryFilterItem.category)
              .toList());
    } else if (event is SubCategoryPressed) {
      yield state.copyWith(
          subCategories: state.subCategories!
              .where((element) =>
                  element.subCategory !=
                  event.subCategoryFilterItem.subCategory)
              .toList());
    } else if (event is MunicipalityPressed) {
      yield state.copyWith(
          municipalities: state.municipalities!
              .where((element) =>
                  element.municipality !=
                  event.municipalityFilterItem.municipality)
              .toList());
    } else if (event is FilterUpdated) {
      yield state.copyWith(
          isOnlyShowingOwnIssues: event.isOnlyShowingOwnIssues,
          issueStates: event.issueStates,
          subCategories: event.subCategories,
          categories: event.categories,
          municipalities: event.municipalities);
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<IssuesOverviewFilterState?> _selectCategories() async {
    List<CategoryFilterItem> categories = AppValuesHelper.getInstance()
        .getCategories()
        .select((element, index) => CategoryFilterItem(
            category: element,
            subCategories: null,
            isSelected: state.categories!
                .any((selectedElement) => selectedElement.category == element)))
        .toList();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
        // Show confirm button
        showConfirmButton: true,
        // Confirm pressed callback
        confirmPressedCallBack: (rootList) {
          List<dynamic> returnList = List.empty(growable: true);
          for (var item in rootList) {
            if (item is CategoryFilterItem) {
              if (item.isSelected) {
                returnList.add(item);
              }
            }
          }
          return returnList;
        },
        // Items
        items: categories,
        // Item builder
        itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
          if (item is CategoryFilterItem) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: IntrinsicHeight(
                          child: Row(
                        children: [
                          Expanded(
                              child: CustomLabel(
                            title: item.category.name!,
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )),
                          if (item.isSelected)
                            Container(
                              margin: const EdgeInsets.all(values.padding),
                              child:
                                  const Icon(Icons.check, color: Colors.black),
                            )
                        ],
                      )),
                    ),
                    onPressed: () {
                      item.isSelected = !item.isSelected;
                      itemUpdated();
                    }));
          }
        },
        // Search predicate
        searchPredicate: (item, searchString) {
          if (item is CategoryFilterItem) {
            return item.category.name!.toLowerCase().contains(searchString);
          }
          return false;
        },
        // Title builder
        titleBuilder: (item) {
          if (item == null) {
            return AppLocalizations.of(_buildContext)!.category;
          }
          return "";
        });
    if (selectedItems == null) return null;
    if (selectedItems.isEmpty) return state.copyWith(categories: List.empty());
    List<CategoryFilterItem> categoryFilterItems = List.empty(growable: true);
    for (var item in selectedItems) {
      if (item is CategoryFilterItem) {
        categoryFilterItems.add(item);
      }
    }
    return state.copyWith(categories: categoryFilterItems);
  }

  Future<IssuesOverviewFilterState?> _selectSubCategories() async {
    List<CategoryFilterItem> categories = AppValuesHelper.getInstance()
        .getCategories()
        .where((element) => state.categories!
            .any((selectedElement) => selectedElement.category == element))
        .select((element, index) => CategoryFilterItem(
            category: element,
            subCategories: element.subCategories!
                .select((subCategory, index) => SubCategoryFilterItem(
                    category: element,
                    subCategory: subCategory,
                    isSelected: state.subCategories!.any((selectedElement) =>
                        selectedElement.subCategory == subCategory)))
                .toList(),
            isSelected: null))
        .toList();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
        // Show confirm button
        showConfirmButton: true,
        // Confirm pressed callback
        confirmPressedCallBack: (rootList) {
          List<dynamic> returnList = List.empty(growable: true);
          for (var item in rootList) {
            if (item is CategoryFilterItem) {
              if (item.isSelected) {
                returnList.add(item);
              }
            }
          }
          return returnList;
        },
        // Items
        items: categories,
        // Item builder
        itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
          if (item is CategoryFilterItem) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: IntrinsicHeight(
                          child: Row(
                        children: [
                          Expanded(
                              child: CustomLabel(
                            title: LocalizationHelper.getInstance()
                                .getLocalizedCategory(
                                    _buildContext, item.category),
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )),
                          if (item.isSelected)
                            CustomLabel(
                              title: item.subCategories!
                                  .where((element) => element.isSelected)
                                  .length
                                  .toString(),
                              margin: const EdgeInsets.all(values.padding),
                            )
                        ],
                      )),
                    ),
                    onPressed: () {
                      itemSelected(item.subCategories);
                    }));
          } else if (item is SubCategoryFilterItem) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: IntrinsicHeight(
                          child: Row(
                        children: [
                          Expanded(
                              child: CustomLabel(
                            title: LocalizationHelper.getInstance()
                                .getLocalizedSubCategory(
                                    _buildContext, item.subCategory),
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )),
                          if (item.isSelected)
                            Container(
                              margin: const EdgeInsets.all(values.padding),
                              child:
                                  const Icon(Icons.check, color: Colors.black),
                            )
                        ],
                      )),
                    ),
                    onPressed: () {
                      item.isSelected = !item.isSelected;
                      itemUpdated();
                    }));
          }
        },
        // Search predicate
        searchPredicate: (item, searchString) {
          if (item is CategoryFilterItem) {
            return item.category.name!.toLowerCase().contains(searchString);
          } else if (item is SubCategoryFilterItem) {
            return item.subCategory.name!.toLowerCase().contains(searchString);
          }
          return false;
        },
        // Title builder
        titleBuilder: (item) {
          if (item == null) {
            return AppLocalizations.of(_buildContext)!.category;
          } else if (item is CategoryFilterItem) {
            return AppLocalizations.of(_buildContext)!.subcategory;
          }
          return "";
        });
    if (selectedItems == null) return null;
    if (selectedItems.isEmpty) {
      return state.copyWith(subCategories: List.empty());
    }
    List<SubCategoryFilterItem> subCategoryFilterItems =
        List.empty(growable: true);
    for (var item in selectedItems) {
      if (item is CategoryFilterItem) {
        for (SubCategoryFilterItem subCategoryFilterItem
            in item.subCategories!) {
          if (subCategoryFilterItem.isSelected) {
            subCategoryFilterItems.add(subCategoryFilterItem);
          }
        }
      }
    }
    return state.copyWith(subCategories: subCategoryFilterItems);
  }

  Future<IssuesOverviewFilterState?> _selectMunicipalities() async {
    List<MunicipalityFilterItem> municipalities = AppValuesHelper.getInstance()
        .getMunicipalities()
        .select((element, index) => MunicipalityFilterItem(
            municipality: element,
            isSelected: state.municipalities!.any(
                (selectedElement) => selectedElement.municipality == element)))
        .toList();
    List<dynamic>? selectedItems = await CustomListDialog.show(_buildContext,
        // Show confirm button
        showConfirmButton: true,
        // Confirm pressed callback
        confirmPressedCallBack: (rootList) {
          List<dynamic> returnList = List.empty(growable: true);
          for (var item in rootList) {
            if (item is MunicipalityFilterItem) {
              if (item.isSelected) {
                returnList.add(item);
              }
            }
          }
          return returnList;
        },
        // Items
        items: municipalities,
        // Item builder
        itemBuilder:
            (index, item, list, showSearchBar, itemSelected, itemUpdated) {
          if (item is MunicipalityFilterItem) {
            return Container(
                margin: EdgeInsets.only(
                    top: index == 0 && showSearchBar ? 0 : values.padding,
                    left: values.padding,
                    right: values.padding),
                child: CustomListTile(
                    widget: Container(
                      color: Colors.transparent,
                      child: IntrinsicHeight(
                          child: Row(
                        children: [
                          Expanded(
                              child: CustomLabel(
                            title: item.municipality.name!,
                            margin: const EdgeInsets.only(
                                left: values.padding,
                                top: values.padding * 2,
                                right: values.padding,
                                bottom: values.padding * 2),
                          )),
                          if (item.isSelected)
                            Container(
                              margin: const EdgeInsets.all(values.padding),
                              child:
                                  const Icon(Icons.check, color: Colors.black),
                            )
                        ],
                      )),
                    ),
                    onPressed: () {
                      item.isSelected = !item.isSelected;
                      itemUpdated();
                    }));
          }
        },
        // Search predicate
        searchPredicate: (item, searchString) {
          if (item is MunicipalityFilterItem) {
            return item.municipality.name!.toLowerCase().contains(searchString);
          }
          return false;
        },
        // Title builder
        titleBuilder: (item) {
          if (item == null) {
            return AppLocalizations.of(_buildContext)!.municipality;
          }
          return "";
        });
    if (selectedItems == null) return null;
    if (selectedItems.isEmpty) {
      return state.copyWith(municipalities: List.empty());
    }
    List<MunicipalityFilterItem> municipalityFilterItems =
        List.empty(growable: true);
    for (var item in selectedItems) {
      if (item is MunicipalityFilterItem) {
        municipalityFilterItems.add(item);
      }
    }
    return state.copyWith(municipalities: municipalityFilterItems);
  }

  Future<bool> getValues() async {
    List<Category> savedCategories =
        AppValuesHelper.getInstance().getCategories();

    List<CategoryFilterItem> categories = savedCategories
        .where((element) =>
            _filter.categoryIds != null &&
            _filter.categoryIds!.any((selectedId) => element.id == selectedId))
        .select((element, index) => CategoryFilterItem(
            category: element, subCategories: null, isSelected: true))
        .toList();
    List<SubCategoryFilterItem> subCategories = List.empty(growable: true);
    for (var categoryFilterItem in categories) {
      if (categoryFilterItem.category.subCategories == null) continue;
      for (var subCategory in categoryFilterItem.category.subCategories!) {
        if (_filter.subCategoryIds!
            .any((element) => element == subCategory.id)) {
          subCategories.add(SubCategoryFilterItem(
              category: categoryFilterItem.category,
              subCategory: subCategory,
              isSelected: true));
        }
      }
    }
    List<MunicipalityFilterItem> municipalities = AppValuesHelper.getInstance()
        .getMunicipalities()
        .where((element) =>
            _filter.municipalityIds != null &&
            _filter.municipalityIds!
                .any((selectedId) => element.id == selectedId))
        .select((element, index) =>
            MunicipalityFilterItem(municipality: element, isSelected: true))
        .toList();
    List<IssueStateFilterItem> issueStates = AppValuesHelper.getInstance()
        .getIssueStates()
        .select((element, index) => IssueStateFilterItem(
            isSelected: _filter.issueStateIds != null &&
                _filter.issueStateIds!
                    .any((selectedId) => element.id == selectedId),
            issueState: element))
        .toList();
    bool isOnlyShowingOwnIssues = _filter.citizenIds != null &&
        _filter.citizenIds!.any((element) =>
            element ==
            AppValuesHelper.getInstance().getInteger(AppValuesKey.citizenId));

    add(FilterUpdated(
        categories: categories,
        subCategories: subCategories,
        municipalities: municipalities,
        issueStates: issueStates,
        isOnlyShowingOwnIssues: isOnlyShowingOwnIssues));

    return true;
  }

//endregion

}
