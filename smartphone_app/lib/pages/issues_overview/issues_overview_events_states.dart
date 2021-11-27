import 'package:equatable/equatable.dart';
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
  showSettings
}

//endregion

///
/// EVENT
///
//region Event

abstract class IssuesOverviewEvent extends Equatable {
  const IssuesOverviewEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends IssuesOverviewEvent {
  final IssuesOverviewButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class PositionRetrieved extends IssuesOverviewEvent {
  final Position devicePosition;

  const PositionRetrieved({required this.devicePosition});

  @override
  List<Object?> get props => [devicePosition];
}

class ListOfIssuesRetrieved extends IssuesOverviewEvent {
  final List<Issue> issues;

  const ListOfIssuesRetrieved({required this.issues});

  @override
  List<Object?> get props => [issues];
}

class IssueDetailsRetrieved extends IssuesOverviewEvent {
  final Issue issue;

  const IssueDetailsRetrieved({required this.issue});

  @override
  List<Object?> get props => [issue];
}

class IssuePressed extends IssuesOverviewEvent {
  final Issue issue;

  const IssuePressed({required this.issue});

  @override
  List<Object?> get props => [issue];
}

class MarkersUpdated extends IssuesOverviewEvent {
  final Set<Marker>? markers;

  const MarkersUpdated({required this.markers});

  @override
  List<Object?> get props => [markers];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
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
      IssuesOverviewFilter? filter}) {
    return IssuesOverviewState(
        mapType: mapType ?? this.mapType,
        issues: issues ?? this.issues,
        places: places ?? this.places,
        filter: filter ?? this.filter,
        markers: markers ?? this.markers,
        devicePosition: devicePosition ?? this.devicePosition);
  }

  @override
  List<Object?> get props =>
      [markers, devicePosition, mapType, issues, places, filter];
}

//endregion
