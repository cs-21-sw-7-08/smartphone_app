import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/select_location/select_location_events_states.dart';
import 'package:smartphone_app/utilities/general_util.dart';
import 'package:smartphone_app/utilities/location/locator_util.dart';
import 'package:smartphone_app/values/values.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SelectLocationBloc
    extends Bloc<SelectLocationEvent, SelectLocationState> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late BuildContext context;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SelectLocationBloc({required this.context, required MapType mapType})
      : super(SelectLocationState(mapType: mapType));

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Stream<SelectLocationState> mapEventToState(
      SelectLocationEvent event) async* {
    if (event is AddMarker) {
      var markerId = MarkerId(event.point.toString());
      var marker = Marker(
          markerId: markerId,
          position: event.point,
          consumeTapEvents: true,
          onTap: () => add(const RemoveMarker()),
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed));
      yield state.copyWith(marker: marker);
    } else if (event is RemoveMarker) {
      yield state.copyWith(marker: null);
    } else if (event is PositionRetrieved) {
      yield state.copyWith(devicePosition: event.devicePosition);
    } else if (event is ButtonPressed) {
      switch (event.buttonEvent) {

        /// Confirm
        case SelectLocationButtonEvent.confirm:
          if (state.marker == null) {
            GeneralUtil.showToast(
                AppLocalizations.of(context)!.please_place_a_marker_first);
            return;
          }
          Navigator.pop(context, state.marker!.position);
          break;

        /// Change map type
        case SelectLocationButtonEvent.changeMapType:
          yield state.copyWith(
              mapType: state.mapType == MapType.hybrid
                  ? MapType.normal
                  : MapType.hybrid);
          break;
      }
    }
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<bool> getValues() async {
    return await Future.delayed(
        const Duration(milliseconds: pageTransitionTime), () async {
      // Get user's current position
      Position position = await LocatorUtil.determinePosition();
      // Fire event
      add(PositionRetrieved(devicePosition: position));
      return true;
    });
  }

//endregion

}
