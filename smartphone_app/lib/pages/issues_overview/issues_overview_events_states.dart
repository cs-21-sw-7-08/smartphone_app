import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/objects/place.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

///
/// ENUMS
///
//region Enums

enum IssuesOverviewButtonEvent {
  createIssue,
  logOut,
  changeMapType,
  getListOfIssues,
  showFilter,
  showSettings,
  showHelp
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

class MarkersUpdated extends IssuesOverviewEvent {
  final Set<Marker>? markers;

  MarkersUpdated({required this.markers});
}

//endregion

///
/// STATE
///
//region State

class IssuesOverviewState {
  Set<Marker>? markers;
  Position? devicePosition;
  MapType? mapType;
  List<Issue>? issues;
  List<Place>? places;
  IssuesOverviewFilter? filter;

  IssuesOverviewState(
      {this.mapType,
      this.places,
      this.markers,
      this.devicePosition,
      this.issues,
      this.filter});

  IssuesOverviewState copyWith(
      {Set<Marker>? markers,
      Position? devicePosition,
      MapType? mapType,
      List<Issue>? issues,
      List<Place>? places,
      IssuesOverviewFilter? issuesOverviewFilter}) {
    return IssuesOverviewState(
        mapType: mapType ?? this.mapType,
        issues: issues ?? this.issues,
        places: places ?? this.places,
        filter: issuesOverviewFilter ?? this.filter,
        markers: markers ?? this.markers,
        devicePosition: devicePosition ?? this.devicePosition);
  }
}

//endregion
