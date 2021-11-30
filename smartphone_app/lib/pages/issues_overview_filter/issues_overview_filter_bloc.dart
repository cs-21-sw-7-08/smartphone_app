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

  late BuildContext context;
  late IssuesOverviewFilter filter;

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

  IssuesOverviewFilterBloc({required this.context, required this.filter})
      : super(IssuesOverviewFilterState(
            municipalities: List.empty(),
            categories: List.empty(),
            subCategories: List.empty(),
            issueStates: List.empty(),
            isOnlyShowingOwnIssues: false));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssuesOverviewFilterState> mapEventToState(
      IssuesOverviewFilterEvent event) async* {
    if (event is ButtonPressed) {
      switch (event.buttonEvent) {

        /// Select categories
        case IssuesOverviewFilterButtonEvent.selectCategories:
          await _selectCategories();
          break;

        /// Select subcategories
        case IssuesOverviewFilterButtonEvent.selectSubCategories:
          await _selectSubCategories();
          break;

        /// Select municipalities
        case IssuesOverviewFilterButtonEvent.selectMunicipalities:
          await _selectMunicipalities();
          break;

        /// Only show your own issues
        case IssuesOverviewFilterButtonEvent.onlyShowYourOwnIssues:
          yield state.copyWith(
              isOnlyShowingOwnIssues: !state.isOnlyShowingOwnIssues!);
          break;

        /// Close
        case IssuesOverviewFilterButtonEvent.close:
          Navigator.of(context).pop(null);
          break;

        /// Apply filter
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
          Navigator.of(context).pop(filter);
          break;

        /// Reset issue states
        case IssuesOverviewFilterButtonEvent.resetIssueStates:
          yield state.copyWith(issueStates: _getDefaultIssueStates());
          break;

        /// Reset categories
        case IssuesOverviewFilterButtonEvent.resetCategories:
          yield state.copyWith(
              categories: List.empty(), subCategories: List.empty());
          break;

        /// Reset subcategories
        case IssuesOverviewFilterButtonEvent.resetSubCategories:
          yield state.copyWith(subCategories: List.empty());
          break;

        /// Reset municipalities
        case IssuesOverviewFilterButtonEvent.resetMunicipalities:
          yield state.copyWith(municipalities: _getDefaultMunicipalities());
          break;

        /// Reset all
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
      yield state.update(
          updatedItemHashCode: event.issueStateFilterItem.hashCode);
    } else if (event is CategoryPressed) {
      yield state.copyWith(
          categories: state.categories!
              .where((element) => element != event.categoryFilterItem)
              .toList(),
          subCategories: state.subCategories!
              .where((element) =>
                  element.category != event.categoryFilterItem.category)
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
    } else if (event is ValueSelected) {
      switch (event.valueSelectedEvent) {

        /// Categories
        case IssuesOverviewFilterValueSelectedEvent.categories:
          yield state.copyWith(categories: event.value);
          break;

        /// Subcategories
        case IssuesOverviewFilterValueSelectedEvent.subCategories:
          yield state.copyWith(subCategories: event.value);
          break;

        /// Municipalities
        case IssuesOverviewFilterValueSelectedEvent.municipalities:
          yield state.copyWith(municipalities: event.value);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<void> _selectCategories() async {
    List<CategoryFilterItem> categories = AppValuesHelper.getInstance()
        .getCategories()
        .select((element, index) => CategoryFilterItem(
            category: element,
            subCategories: null,
            isSelected: state.categories!
                .any((selectedElement) => selectedElement.category == element)))
        .toList();
    List<dynamic>? selectedItems = await CustomListDialog.show(context,
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
                                .getLocalizedCategory(context, item.category),
                            textAlign: TextAlign.left,
                            alignmentGeometry: Alignment.centerLeft,
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
            return AppLocalizations.of(context)!.category;
          }
          return "";
        });
    if (selectedItems == null) return;
    if (selectedItems.isEmpty) {
      // Fire event
      add(ValueSelected(
          valueSelectedEvent: IssuesOverviewFilterValueSelectedEvent.categories,
          value: List.empty()));
    }
    List<CategoryFilterItem> categoryFilterItems = List.empty(growable: true);
    for (var item in selectedItems) {
      if (item is CategoryFilterItem) {
        categoryFilterItems.add(item);
      }
    }

    // Fire event
    add(ValueSelected(
        valueSelectedEvent: IssuesOverviewFilterValueSelectedEvent.categories,
        value: categoryFilterItems));
  }

  Future<void> _selectSubCategories() async {
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
    List<dynamic>? selectedItems = await CustomListDialog.show(context,
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
                            textAlign: TextAlign.left,
                            alignmentGeometry: Alignment.centerLeft,
                            title: LocalizationHelper.getInstance()
                                .getLocalizedCategory(context, item.category),
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
                            textAlign: TextAlign.left,
                            alignmentGeometry: Alignment.centerLeft,
                            title: LocalizationHelper.getInstance()
                                .getLocalizedSubCategory(
                                    context, item.subCategory),
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
            return AppLocalizations.of(context)!.category;
          } else if (item is CategoryFilterItem) {
            return AppLocalizations.of(context)!.subcategory;
          }
          return "";
        });
    if (selectedItems == null) return;
    if (selectedItems.isEmpty) {
      // Fire event
      add(ValueSelected(
          valueSelectedEvent:
              IssuesOverviewFilterValueSelectedEvent.subCategories,
          value: List.empty()));
      return;
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

    // Fire event
    add(ValueSelected(
        valueSelectedEvent:
            IssuesOverviewFilterValueSelectedEvent.subCategories,
        value: subCategoryFilterItems));
  }

  Future<void> _selectMunicipalities() async {
    List<MunicipalityFilterItem> municipalities = AppValuesHelper.getInstance()
        .getMunicipalities()
        .select((element, index) => MunicipalityFilterItem(
            municipality: element,
            isSelected: state.municipalities!.any(
                (selectedElement) => selectedElement.municipality == element)))
        .toList();
    List<dynamic>? selectedItems = await CustomListDialog.show(context,
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
                            textAlign: TextAlign.left,
                            alignmentGeometry: Alignment.centerLeft,
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
            return AppLocalizations.of(context)!.municipality;
          }
          return "";
        });
    if (selectedItems == null) return;
    if (selectedItems.isEmpty) {
      // Fire event
      add(ValueSelected(
          valueSelectedEvent:
              IssuesOverviewFilterValueSelectedEvent.municipalities,
          value: List.empty()));
      return;
    }
    List<MunicipalityFilterItem> municipalityFilterItems =
        List.empty(growable: true);
    for (var item in selectedItems) {
      if (item is MunicipalityFilterItem) {
        municipalityFilterItems.add(item);
      }
    }
    // Fire event
    add(ValueSelected(
        valueSelectedEvent:
            IssuesOverviewFilterValueSelectedEvent.municipalities,
        value: municipalityFilterItems));
  }

  Future<bool> getValues() async {
    List<Category> savedCategories =
        AppValuesHelper.getInstance().getCategories();

    List<CategoryFilterItem> categories = savedCategories
        .where((element) =>
            filter.categoryIds != null &&
            filter.categoryIds!.any((selectedId) => element.id == selectedId))
        .select((element, index) => CategoryFilterItem(
            category: element, subCategories: null, isSelected: true))
        .toList();
    List<SubCategoryFilterItem> subCategories = List.empty(growable: true);
    for (var categoryFilterItem in categories) {
      if (categoryFilterItem.category.subCategories == null) continue;
      for (var subCategory in categoryFilterItem.category.subCategories!) {
        if (filter.subCategoryIds != null &&
            filter.subCategoryIds!
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
            filter.municipalityIds != null &&
            filter.municipalityIds!
                .any((selectedId) => element.id == selectedId))
        .select((element, index) =>
            MunicipalityFilterItem(municipality: element, isSelected: true))
        .toList();
    List<IssueStateFilterItem> issueStates = AppValuesHelper.getInstance()
        .getIssueStates()
        .select((element, index) => IssueStateFilterItem(
            isSelected: filter.issueStateIds != null &&
                filter.issueStateIds!
                    .any((selectedId) => element.id == selectedId),
            issueState: element))
        .toList();
    bool isOnlyShowingOwnIssues = filter.citizenIds != null &&
        filter.citizenIds!.any((element) =>
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
