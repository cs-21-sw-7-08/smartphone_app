import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/pages/create_issue/create_issue_page.dart';
import 'package:smartphone_app/pages/issue_details/issue_details_page.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import '../../utilities/location/locator_util.dart';

class IssuesOverviewBloc
    extends Bloc<IssuesOverviewEvent, IssuesOverviewState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  // ignore: unused_field
  late BuildContext _buildContext;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  IssuesOverviewBloc({required BuildContext buildContext})
      : super(IssuesOverviewState(
            issuesOverviewPageView: IssuesOverviewPageView.map,
            mapType: MapType.hybrid)) {
    _buildContext = buildContext;
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<IssuesOverviewState> mapEventToState(
      IssuesOverviewEvent event) async* {
    if (event is PositionRetrieved) {
      yield state.copyWith(devicePosition: event.devicePosition);
    } else if (event is ButtonPressed) {
      switch (event.issuesOverviewButtonEvent) {
        case IssuesOverviewButtonEvent.createIssue:
          GeneralUtil.showPageAsDialog(
              _buildContext, CreateIssuePage(mapType: state.mapType!));
          break;
        case IssuesOverviewButtonEvent.logOut:
          await logOut();
          break;
        case IssuesOverviewButtonEvent.changeMapType:
          yield state.copyWith(
              mapType: state.mapType == MapType.hybrid
                  ? MapType.normal
                  : MapType.hybrid);
          break;
        case IssuesOverviewButtonEvent.changeOverviewType:
          yield state.copyWith(
              issuesOverviewPageView:
                  state.issuesOverviewPageView == IssuesOverviewPageView.map
                      ? IssuesOverviewPageView.list
                      : IssuesOverviewPageView.map);
          break;
        case IssuesOverviewButtonEvent.getListOfIssues:
          await getListOfIssues();
          break;
      }
    } else if (event is IssueDetailsRetrieved) {
      GeneralUtil.showPopup(_buildContext,
          IssueDetailsPage(issue: event.issue, mapType: state.mapType!));
    } else if (event is ListOfIssuesRetrieved) {
      yield state.copyWith(markers: getMarkersFromIssues(event.issues));
    }
  }

//endregion

  ///
  /// METHODS
  ///
  //region Methods

  Set<Marker> getMarkersFromIssues(List<Issue> issues) {
    Set<Marker> markers = <Marker>{};
    for (var issue in issues) {
      var markerId = MarkerId(issue.id.toString());
      markers.add(Marker(
          markerId: markerId,
          position: LatLng(issue.location!.latitude, issue.location!.longitude),
          consumeTapEvents: true,
          onTap: () => getIssueDetails(issue.id),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed)));
    }
    return markers;
  }

  Future<void> logOut() async {
    await TaskUtil.runTask<bool>(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.logging_out,
        doInBackground: (runTask) async {
          await ThirdPartySignInUtil.signOut();
          return null;
        },
        taskCancelled: () {});
    GeneralUtil.goToPage(_buildContext, LoginPage());
  }

  Future<bool> getValues() async {
    var flag = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.getting_issues,
        doInBackground: (runTask) async {
          // Get user's current position
          Position position = await LocatorUtil.determinePosition();
          // Fire event
          add(PositionRetrieved(devicePosition: position));

          // Get list of municipalities
          WASPServiceResponse<GetListOfMunicipalities_WASPResponse>
              getListOfMunicipalitiesResponse =
              await WASPService.getInstance().getListOfMunicipalities();
          if (!getListOfMunicipalitiesResponse.isSuccess) {
            GeneralUtil.showToast(getListOfMunicipalitiesResponse.exception!);
            return false;
          }
          AppValuesHelper.getInstance().saveMunicipalities(
              getListOfMunicipalitiesResponse.waspResponse!.result!);

          // Get list of municipalities
          WASPServiceResponse<GetListOfCategories_WASPResponse>
              getListOfCategoriesResponse =
              await WASPService.getInstance().getListOfCategories();
          if (!getListOfCategoriesResponse.isSuccess) {
            GeneralUtil.showToast(getListOfCategoriesResponse.exception!);
            return false;
          }
          AppValuesHelper.getInstance().saveCategories(
              getListOfCategoriesResponse.waspResponse!.result!);

          // Get list of issues
          var response = await WASPService.getInstance().getListOfIssues();
          // Check for errors
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return false;
          }
          // Get issues
          var issues = response.waspResponse!.result!;
          // Fire event
          add(ListOfIssuesRetrieved(issues: issues));
          // Return true
          return true;
        },
        taskCancelled: () {});
    return flag!;
  }

  Future<void> getListOfIssues() async {
    await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.getting_issues,
        doInBackground: (runTask) async {
          // Get list of issues
          var response = await WASPService.getInstance().getListOfIssues();
          // Check for errors
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return false;
          }
          // Get issues
          var issues = response.waspResponse!.result!;
          // Fire event
          add(ListOfIssuesRetrieved(issues: issues));
          // Return true
          return true;
        },
        taskCancelled: () {});
  }

  Future<void> getIssueDetails(int issueId) async {
    Issue? issue = await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage:
            AppLocalizations.of(_buildContext)!.getting_issue_details,
        doInBackground: (runTask) async {
          // Get issue details
          var response =
              await WASPService.getInstance().getIssueDetails(issueId);
          // Check for errors
          if (!response.isSuccess) {
            GeneralUtil.showToast(response.exception!);
            return null;
          }
          // Get issue
          Issue issue = response.waspResponse!.result!;
          // Return issue
          return issue;
        },
        taskCancelled: () {});
    if (issue != null) {
      // Fire event
      add(IssueDetailsRetrieved(issue: issue));
    }
  }

//endregion

}
