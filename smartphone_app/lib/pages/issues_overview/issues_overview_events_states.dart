import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum IssuesOverviewPageView { map, list }
enum IssuesOverviewButtonEvent {
  createIssue,
  logOut,
  changeMapType,
  changeOverviewType,
  getListOfIssues
}

//endregion

///
/// EVENT
///
//region Event

class IssuesOverviewEvent {}

class ButtonPressed extends IssuesOverviewEvent {
  final IssuesOverviewButtonEvent issuesOverviewButtonEvent;

  ButtonPressed({required this.issuesOverviewButtonEvent});
}

class PositionRetrieved extends IssuesOverviewEvent {
  final Position devicePosition;

  PositionRetrieved({required this.devicePosition});
}

class ListOfIssuesRetrieved extends IssuesOverviewEvent {
  final List<Issue> issues;

  ListOfIssuesRetrieved({required this.issues});
}

class IssueDetailsRetrieved extends IssuesOverviewEvent {
  final Issue issue;

  IssueDetailsRetrieved({required this.issue});
}

class IssuePressed extends IssuesOverviewEvent {
  final Issue issue;

  IssuePressed({required this.issue});
}

//endregion

///
/// STATE
///
//region State

class IssuesOverviewState {
  Set<Marker>? markers;
  Position? devicePosition;
  IssuesOverviewPageView? issuesOverviewPageView;
  MapType? mapType;
  List<Issue>? issues;

  IssuesOverviewState(
      {this.issuesOverviewPageView,
      this.mapType,
      this.markers,
      this.devicePosition,
      this.issues});

  IssuesOverviewState copyWith(
      {Set<Marker>? markers,
      Position? devicePosition,
      MapType? mapType,
      List<Issue>? issues,
      IssuesOverviewPageView? issuesOverviewPageView}) {
    return IssuesOverviewState(
        mapType: mapType ?? this.mapType,
        issues: issues ?? this.issues,
        issuesOverviewPageView:
            issuesOverviewPageView ?? this.issuesOverviewPageView,
        markers: markers ?? this.markers,
        devicePosition: devicePosition ?? this.devicePosition);
  }
}

//endregion
