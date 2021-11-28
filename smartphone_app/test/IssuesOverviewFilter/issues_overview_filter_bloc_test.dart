import 'dart:convert';

import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/objects/category_filter_item.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/objects/subcategory_filter_item.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_bloc.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/mock_wasp_service.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class MockBuildContext extends Mock implements BuildContext {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  group("IssuesOverviewFilter", () {
    late IssuesOverviewFilterBloc bloc;
    var filter = IssuesOverviewFilter(
        categoryIds: [],
        subCategoryIds: [],
        citizenIds: [1],
        issueStateIds: [1, 2],
        municipalityIds: [1],
        isBlocked: false);
    var hashCode = 0;

    setUp(() async {
      AppValuesHelper.getInstance().init();
      WASPService.init(MockWASPService());

      var getListOfMunicipalitiesResponse =
          await WASPService.getInstance().getListOfMunicipalities();

      var jsonMunicipalities = jsonEncode(getListOfMunicipalitiesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      var getListOfCategoriesResponse =
          await WASPService.getInstance().getListOfCategories();

      var jsonCategories = jsonEncode(getListOfCategoriesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      var getListOfReportCategoriesResponse =
          await WASPService.getInstance().getListOfReportCategories();

      var jsonReportCategories = jsonEncode(getListOfReportCategoriesResponse
          .waspResponse!.result!
          .map((e) => e.toJson())
          .toList());

      SharedPreferences.setMockInitialValues({
        AppValuesKey.defaultMunicipalityId.toString(): 1,
        AppValuesKey.municipalities.toString(): jsonMunicipalities,
        AppValuesKey.citizenId.toString(): 1,
        AppValuesKey.categories.toString(): jsonCategories,
        AppValuesKey.reportCategories.toString(): jsonReportCategories
      });
      bloc =
          IssuesOverviewFilterBloc(context: MockBuildContext(), filter: filter);
    });

    test("Initial state is correct", () {
      expect(
          IssuesOverviewFilterBloc(context: MockBuildContext(), filter: filter)
              .state,
          IssuesOverviewFilterState(
              municipalities: List.empty(),
              categories: List.empty(),
              subCategories: List.empty(),
              issueStates: List.empty(),
              isOnlyShowingOwnIssues: false));
    });

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ButtonPressed -> ResetIssueStates",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: IssuesOverviewFilterButtonEvent.resetIssueStates)),
        expect: () => [isA<IssuesOverviewFilterState>()]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ButtonPressed -> ResetCategories",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: IssuesOverviewFilterButtonEvent.resetCategories)),
        expect: () => [
              bloc.state.copyWith(
                  categories: List.empty(), subCategories: List.empty())
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ButtonPressed -> ResetSubcategories",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: IssuesOverviewFilterButtonEvent.resetSubCategories)),
        expect: () => [bloc.state.copyWith(subCategories: List.empty())]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ButtonPressed -> ResetAll",
        build: () => bloc,
        act: (bloc) => bloc.add(const ButtonPressed(
            buttonEvent: IssuesOverviewFilterButtonEvent.resetAll)),
        expect: () => [bloc.state.copyWith()]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "IssueStatePressed -> IsSelected false to true",
        setUp: () async {
          // Setup default issue states
          bloc.state.issueStates = [
            IssueStateFilterItem(
                isSelected: true, issueState: IssueState(id: 1))
          ];
          // Get item
          var item = bloc.state.issueStates![0];
          // Set isSelected to true
          item.isSelected = true;
          // Get hash code
          hashCode = item.hashCode;
          // Set isSelected to true
          item.isSelected = false;
        },
        build: () => bloc,
        act: (bloc) => bloc.add(IssueStatePressed(
            issueStateFilterItem: bloc.state.issueStates![0])),
        expect: () => [bloc.state.copyWith(updatedItemHashCode: hashCode)]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "CategoryPressed -> Category is removed",
        setUp: () async {
          // Setup default values
          bloc.state.categories = [
            CategoryFilterItem(
                subCategories: null,
                isSelected: true,
                category: Category(id: 1))
          ];
        },
        build: () => bloc,
        act: (bloc) => bloc.add(
            CategoryPressed(categoryFilterItem: bloc.state.categories![0])),
        expect: () => [
              bloc.state.copyWith(
                  categories: List.empty(), subCategories: List.empty())
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "CategoryInSubCategoryPressed -> Subcategories belonging to the category is removed",
        setUp: () async {
          // Setup default values
          bloc.state.categories = [
            CategoryFilterItem(
                subCategories: null,
                isSelected: true,
                category: Category(id: 1))
          ];
          bloc.state.subCategories = [
            SubCategoryFilterItem(
                subCategory: SubCategory(id: 1),
                isSelected: true,
                category: Category(id: 1))
          ];
        },
        build: () => bloc,
        act: (bloc) => bloc.add(CategoryInSubCategoryPressed(
            categoryFilterItem: bloc.state.categories![0])),
        expect: () => [bloc.state.copyWith(subCategories: List.empty())]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "SubCategoryPressed -> SubCategory removed",
        setUp: () async {
          // Setup default values
          bloc.state.categories = [
            CategoryFilterItem(
                subCategories: null,
                isSelected: true,
                category: Category(id: 1))
          ];
          bloc.state.subCategories = [
            SubCategoryFilterItem(
                subCategory: SubCategory(id: 1),
                isSelected: true,
                category: Category(id: 1)),
            SubCategoryFilterItem(
                subCategory: SubCategory(id: 2),
                isSelected: true,
                category: Category(id: 1))
          ];
        },
        build: () => bloc,
        act: (bloc) => bloc.add(SubCategoryPressed(
            subCategoryFilterItem: bloc.state.subCategories![0])),
        expect: () => [
              bloc.state.copyWith(subCategories: [
                SubCategoryFilterItem(
                    subCategory: SubCategory(id: 2),
                    isSelected: true,
                    category: Category(id: 1))
              ])
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "MunicipalityPressed -> Municipality removed",
        setUp: () async {
          // Setup default values
          bloc.state.municipalities = [
            MunicipalityFilterItem(
                municipality: Municipality(id: 1), isSelected: true),
            MunicipalityFilterItem(
                municipality: Municipality(id: 2), isSelected: true)
          ];
        },
        build: () => bloc,
        act: (bloc) => bloc.add(MunicipalityPressed(
            municipalityFilterItem: bloc.state.municipalities![0])),
        expect: () => [
              bloc.state.copyWith(municipalities: [
                MunicipalityFilterItem(
                    municipality: Municipality(id: 2), isSelected: true)
              ])
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "FilterUpdated",
        build: () => bloc,
        act: (bloc) => bloc.add(FilterUpdated(subCategories: [
              SubCategoryFilterItem(
                  subCategory: SubCategory(id: 2),
                  isSelected: true,
                  category: Category(id: 1))
            ], categories: [
              CategoryFilterItem(
                  subCategories: null,
                  isSelected: true,
                  category: Category(id: 1))
            ], municipalities: [
              MunicipalityFilterItem(
                  municipality: Municipality(id: 2), isSelected: true)
            ], issueStates: [
              IssueStateFilterItem(
                  isSelected: true, issueState: IssueState(id: 1))
            ], isOnlyShowingOwnIssues: false)),
        expect: () => [
              bloc.state.copyWith(subCategories: [
                SubCategoryFilterItem(
                    subCategory: SubCategory(id: 2),
                    isSelected: true,
                    category: Category(id: 1))
              ], categories: [
                CategoryFilterItem(
                    subCategories: null,
                    isSelected: true,
                    category: Category(id: 1))
              ], municipalities: [
                MunicipalityFilterItem(
                    municipality: Municipality(id: 2), isSelected: true)
              ], issueStates: [
                IssueStateFilterItem(
                    isSelected: true, issueState: IssueState(id: 1))
              ], isOnlyShowingOwnIssues: false)
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ValueSelected -> Categories",
        build: () => bloc,
        act: (bloc) => bloc.add(ValueSelected(
                valueSelectedEvent:
                    IssuesOverviewFilterValueSelectedEvent.categories,
                value: [
                  CategoryFilterItem(
                      subCategories: null,
                      isSelected: true,
                      category: Category(id: 1))
                ])),
        expect: () => [
              bloc.state.copyWith(categories: [
                CategoryFilterItem(
                    subCategories: null,
                    isSelected: true,
                    category: Category(id: 1))
              ])
            ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ValueSelected -> SubCategories",
        build: () => bloc,
        act: (bloc) => bloc.add(ValueSelected(
            valueSelectedEvent:
            IssuesOverviewFilterValueSelectedEvent.subCategories,
            value: [
              SubCategoryFilterItem(
                  subCategory: SubCategory(id: 2),
                  isSelected: true,
                  category: Category(id: 1))
            ])),
        expect: () => [
          bloc.state.copyWith(subCategories: [
            SubCategoryFilterItem(
                subCategory: SubCategory(id: 2),
                isSelected: true,
                category: Category(id: 1))
          ])
        ]);

    blocTest<IssuesOverviewFilterBloc, IssuesOverviewFilterState>(
        "ValueSelected -> Municipalities",
        build: () => bloc,
        act: (bloc) => bloc.add(ValueSelected(
            valueSelectedEvent:
            IssuesOverviewFilterValueSelectedEvent.municipalities,
            value: [
              MunicipalityFilterItem(
                  municipality: Municipality(id: 2), isSelected: true)
            ])),
        expect: () => [
          bloc.state.copyWith(municipalities: [
            MunicipalityFilterItem(
                municipality: Municipality(id: 2), isSelected: true)
          ])
        ]);
  });
}
