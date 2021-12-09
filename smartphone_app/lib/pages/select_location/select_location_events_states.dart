import 'package:equatable/equatable.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

///
/// ENUMS
///
//region Enums

enum SelectLocationButtonEvent { confirm, changeMapType }

//endregion

///
/// EVENT
///
//region Event

abstract class SelectLocationEvent extends Equatable {
  const SelectLocationEvent();

  @override
  List<Object?> get props => [];
}

class ButtonPressed extends SelectLocationEvent {
  final SelectLocationButtonEvent buttonEvent;

  const ButtonPressed({required this.buttonEvent});

  @override
  List<Object?> get props => [buttonEvent];
}

class AddMarker extends SelectLocationEvent {
  final LatLng point;

  const AddMarker({required this.point});

  @override
  List<Object?> get props => [point];
}

class RemoveMarker extends SelectLocationEvent {
  const RemoveMarker();
}

class PositionRetrieved extends SelectLocationEvent {
  final Position devicePosition;

  const PositionRetrieved({required this.devicePosition});

  @override
  List<Object?> get props => [devicePosition];
}

//endregion

///
/// STATE
///
//region State

// ignore: must_be_immutable
class SelectLocationState extends Equatable {
  Position? devicePosition;
  Marker? marker;
  MapType? mapType;

  SelectLocationState({this.marker, this.devicePosition, this.mapType});

  SelectLocationState copyWith(
      {Marker? marker, Position? devicePosition, MapType? mapType}) {
    return SelectLocationState(
        marker: marker ?? this.marker,
        devicePosition: devicePosition ?? this.devicePosition,
        mapType: mapType ?? this.mapType);
  }

  @override
  List<Object?> get props => [devicePosition, marker, mapType];
}

//endregion
