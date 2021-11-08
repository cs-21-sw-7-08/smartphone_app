import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/select_location/select_location_page.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/models/google_classes.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/service/google_service.dart';
import '../../webservices/wasp/interfaces/wasp_service_functions.dart';
import 'package:smartphone_app/pages/issue_details/issue_details_page.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_events_states.dart';
import 'package:smartphone_app/pages/issues_overview/issues_overview_page.dart';
import 'package:smartphone_app/pages/login/login_page.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/sign_in/third_party_sign_in_util.dart';
import 'package:smartphone_app/utilities/task_util.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/mock_wasp_service.dart';
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
  late IWASPServiceFunctions _waspServiceFunctions;

  IWASPServiceFunctions get waspService {
    return _waspServiceFunctions;
  }

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
    _waspServiceFunctions = MockWASPService();
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
          // TODO: Handle this case.
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
    await TaskUtil.runTask<bool, bool>(
        buildContext: _buildContext,
        progressMessage: AppLocalizations.of(_buildContext)!.logging_out,
        doInBackground: (runTask) async {
          await ThirdPartySignInUtil.signOut();
          return null;
        },
        afterBackground: (value) {
          GeneralUtil.goToPage(_buildContext, LoginPage());
        },
        taskCancelled: () {});
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

          // Get list of issues
          var response = await waspService.getListOfIssues();
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
        afterBackground: (bool? value) {
          return value;
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
          var response = await waspService.getListOfIssues();
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
        afterBackground: (bool? value) {
          return value;
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
        afterBackground: (Issue? issue) {
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
