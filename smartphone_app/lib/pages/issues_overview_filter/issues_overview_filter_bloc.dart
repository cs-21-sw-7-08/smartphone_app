import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/objects/issue_state_filter_item.dart';
import 'package:smartphone_app/objects/municipality_filter_item.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class IssuesOverviewFilterBloc
    extends Bloc<IssuesOverviewFilterEvent, IssuesOverviewFilterState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext _buildContext;

  //endregion

  //region Default values

  List<IssueStateFilterItem> _getDefaultIssueStates() {
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

  List<MunicipalityFilterItem> _getDefaultMunicipalities() {
    // Create list
    List<MunicipalityFilterItem> municipalityFilterItems =
        List.empty(growable: true);
    // Get municipalities
    List<Municipality?> municipalities =
        AppValuesHelper.getInstance().getMunicipalities();
    // Get default municipality ID
    int defaultMunicipalityId = AppValuesHelper.getInstance()
        .getInteger(AppValuesKey.defaultMunicipality)!;
    // Get municipality
    Municipality? municipality;
    try {
      municipality = municipalities.firstWhere(
              (element) => element!.id == defaultMunicipalityId);
    } on StateError catch(_) {

    }
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

  IssuesOverviewFilterBloc({required BuildContext buildContext})
      : super(IssuesOverviewFilterState()) {
    _buildContext = buildContext;
    state.issueStates = _getDefaultIssueStates();
    state.municipalities = _getDefaultMunicipalities();
    state.categories = List.empty(growable: true);
    state.subCategories = List.empty(growable: true);
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
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.selectSubCategories:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.selectMunicipalities:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.onlyShowYourOwnIssues:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.closePressed:
          Navigator.of(_buildContext).pop(null);
          break;
        case IssuesOverviewFilterButtonEvent.applyFilter:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.resetIssueStates:
          yield state.copyWith(issueStates: _getDefaultIssueStates());
          break;
        case IssuesOverviewFilterButtonEvent.resetCategories:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.resetSubCategories:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.resetMunicipalities:
          // TODO: Handle this case.
          break;
        case IssuesOverviewFilterButtonEvent.resetAll:
          yield state.copyWith(issueStates: _getDefaultIssueStates());
          break;
      }
    } else if (event is IssueStatePressed) {
      event.issueStateFilterItem.isSelected =
          !event.issueStateFilterItem.isSelected;
      yield state.copyWith(issueStates: state.issueStates);
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<bool> getValues() async {
    return true;
  }

//endregion

}
