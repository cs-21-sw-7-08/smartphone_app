import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/helpers/app_values_helper.dart';
import 'package:smartphone_app/objects/place.dart';
import 'package:smartphone_app/pages/issue/issue_page.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';
import 'package:smartphone_app/pages/issues_overview_filter/issues_overview_filter_page.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/pages/settings/settings_bloc.dart';
import 'package:smartphone_app/pages/settings/settings_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/utilities/wasp_util.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';
import '../../utilities/location/locator_util.dart';
import 'package:darq/darq.dart';
import 'package:smartphone_app/values/values.dart' as values;

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

  IssuesOverviewBloc({required BuildContext context})
      : super(IssuesOverviewState(
            mapType: MapType.hybrid,
            filter: getDefaultIssuesOverviewFilter())) {
    _buildContext = context;
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

        /// Create issue
        case IssuesOverviewButtonEvent.createIssue:
          bool? flag = await GeneralUtil.showPageAsDialog<bool?>(
              _buildContext, IssuePage(mapType: state.mapType!));
          flag ??= false;
          if (flag) {
            await getListOfIssues(state.filter!);
          }
          break;

        /// Log out
        case IssuesOverviewButtonEvent.logOut:
          await _logOut();
          break;
        case IssuesOverviewButtonEvent.changeMapType:
          yield state.copyWith(
              mapType: state.mapType == MapType.hybrid
                  ? MapType.normal
                  : MapType.hybrid);
          break;

        /// Get list of issues
        case IssuesOverviewButtonEvent.getListOfIssues:
          await getListOfIssues(state.filter!);
          break;

        /// Show filter
        case IssuesOverviewButtonEvent.showFilter:
          IssuesOverviewFilter? filter =
              await GeneralUtil.showPageAsDialog<IssuesOverviewFilter?>(
                  _buildContext,
                  IssuesOverviewFilterPage(filter: state.filter!));
          if (filter == null) return;
          await getListOfIssues(filter);
          yield state.copyWith(issuesOverviewFilter: filter);
          break;

        /// Show settings
        case IssuesOverviewButtonEvent.showSettings:
          SettingsCallBackType? callBackType =
              await GeneralUtil.showPageAsDialog<SettingsCallBackType>(
                  _buildContext, SettingsPage());
          if (callBackType == null) return;
          switch (callBackType) {
            case SettingsCallBackType.deleteAccount:
              await _logOut();
              break;
            case SettingsCallBackType.settingsChanged:
              IssuesOverviewFilter filter = state.filter!;
              filter.municipalityIds = [
                AppValuesHelper.getInstance()
                    .getInteger(AppValuesKey.defaultMunicipalityId)!
              ];
              await getListOfIssues(filter);
              yield state.copyWith(issuesOverviewFilter: filter);
              break;
          }
          break;

        /// Show help
        case IssuesOverviewButtonEvent.showHelp:
          // TODO: Handle this case.
          break;
      }
    } else if (event is IssueDetailsRetrieved) {
      bool? flag = await GeneralUtil.showPageAsDialog<bool?>(
          _buildContext,
          IssuePage(
            issue: event.issue,
            mapType: state.mapType!,
          ));
      flag ??= false;
      if (flag) {
        await getListOfIssues(state.filter!);
      }
    } else if (event is ListOfIssuesRetrieved) {
      List<Place> places = event.issues
          .select((element, index) => Place(issue: element))
          .toList();
      yield state.copyWith(places: places, issues: event.issues);
    } else if (event is IssuePressed) {
      await getIssueDetails(event.issue.id!);
    } else if (event is MarkersUpdated) {
      yield state.copyWith(markers: event.markers);
    }
  }

//endregion

  ///
  /// METHODS
  ///
  //region Methods

  static IssuesOverviewFilter getDefaultIssuesOverviewFilter() {
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

    return IssuesOverviewFilter(
        municipalityIds: municipality == null ? null : [municipality.id],
        issueStateIds: [1, 2],
        citizenIds: null,
        subCategoryIds: null,
        isBlocked: false,
        categoryIds: null);
  }

  Set<Marker> getMarkersFromIssues(List<Issue> issues) {
    Set<Marker> markers = <Marker>{};
    for (var issue in issues) {
      var markerId = MarkerId(issue.id.toString());

      markers.add(Marker(
          markerId: markerId,
          position: LatLng(issue.location!.latitude, issue.location!.longitude),
          consumeTapEvents: true,
          onTap: () => add(IssuePressed(issue: issue)),
          icon: WASPUtil.getIssueStateMarkerIcon(issue.issueState!)));
    }
    return markers;
  }

  Future<void> _logOut() async {
    await TaskUtil.runTask<bool>(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.logging_out,
        doInBackground: (runTask) async {
          // Sign out
          await ThirdPartySignInUtil.signOut();
          // Reset Citizen ID
          await AppValuesHelper.getInstance()
              .saveInteger(AppValuesKey.citizenId, null);
          return null;
        },
        taskCancelled: () {});

    GeneralUtil.goToPage(_buildContext, LoginPage());
  }

  Future<bool> getValues() async {
    return await Future.delayed(
        const Duration(milliseconds: values.pageTransitionTime), () async {
      bool isBlocked = false;
      var flag = await TaskUtil.runTask(
          buildContext: _buildContext,
          progressMessage: AppLocalizations.of(_buildContext)!.getting_issues,
          doInBackground: (runTask) async {
            // Get user's current position
            Position position = await LocatorUtil.determinePosition();
            // Fire event
            add(PositionRetrieved(devicePosition: position));

            // Get if the citizen is blocked
            WASPServiceResponse<IsBlockedCitizen_WASPResponse>
                isBlockedCitizenResponse = await WASPService.getInstance()
                    .isBlockedCitizen(
                        citizenId: AppValuesHelper.getInstance()
                            .getInteger(AppValuesKey.citizenId)!);
            if (!isBlockedCitizenResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await isBlockedCitizenResponse.errorMessage)!);
              return false;
            }
            if (isBlockedCitizenResponse.waspResponse!.result!) {
              isBlocked = true;
              return false;
            }

            // Get list of municipalities
            WASPServiceResponse<GetListOfMunicipalities_WASPResponse>
                getListOfMunicipalitiesResponse =
                await WASPService.getInstance().getListOfMunicipalities();
            if (!getListOfMunicipalitiesResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await getListOfMunicipalitiesResponse.errorMessage)!);
              return false;
            }
            AppValuesHelper.getInstance().saveMunicipalities(
                getListOfMunicipalitiesResponse.waspResponse!.result!);

            // Get list of categories
            WASPServiceResponse<GetListOfCategories_WASPResponse>
                getListOfCategoriesResponse =
                await WASPService.getInstance().getListOfCategories();
            if (!getListOfCategoriesResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await getListOfCategoriesResponse.errorMessage)!);
              return false;
            }
            AppValuesHelper.getInstance().saveCategories(
                getListOfCategoriesResponse.waspResponse!.result!);

            // Get list of report categories
            WASPServiceResponse<GetListOfReportCategories_WASPResponse>
                getListOfReportCategoriesResponse =
                await WASPService.getInstance().getListOfReportCategories();
            if (!getListOfReportCategoriesResponse.isSuccess) {
              GeneralUtil.showToast(
                  (await getListOfReportCategoriesResponse.errorMessage)!);
              return false;
            }
            AppValuesHelper.getInstance().saveReportCategories(
                getListOfReportCategoriesResponse.waspResponse!.result!);

            // Get list of issues
            var response = await WASPService.getInstance()
                .getListOfIssues(filter: state.filter!);
            // Check for errors
            if (!response.isSuccess) {
              GeneralUtil.showToast((await response.errorMessage)!);
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
      // Is the citizen blocked?
      if (isBlocked) {
        GeneralUtil.showToast(
            AppLocalizations.of(_buildContext)!.this_user_is_blocked);
        await _logOut();
      }
      flag ??= false;
      return flag;
    });
  }

  Future<void> getListOfIssues(IssuesOverviewFilter filter) async {
    await TaskUtil.runTask(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.getting_issues,
        doInBackground: (runTask) async {
          // Get list of issues
          var response =
              await WASPService.getInstance().getListOfIssues(filter: filter);
          // Check for errors
          if (!response.isSuccess) {
            GeneralUtil.showToast((await response.errorMessage)!);
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
            GeneralUtil.showToast((await response.errorMessage)!);
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
