import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class SelectLocationEvent {}

enum SelectLocationButtonEvent { confirm, changeMapType }

class ButtonPressed extends SelectLocationEvent {
  final SelectLocationButtonEvent selectLocationButtonEvent;

  ButtonPressed({required this.selectLocationButtonEvent});
}

class AddMarker extends SelectLocationEvent {
  final LatLng point;

  AddMarker({required this.point});
}

class RemoveMarker extends SelectLocationEvent {
  final MarkerId markerId;

  RemoveMarker({required this.markerId});
}

class PositionRetrieved extends SelectLocationEvent {
  final Position devicePosition;

  PositionRetrieved({required this.devicePosition});
}

class SelectLocationState {
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
}
