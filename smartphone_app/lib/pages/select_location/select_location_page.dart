// ignore: must_be_immutable
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/pages/select_location/select_location_events_states.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/pages/select_location/select_location_bloc.dart';
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/values/values.dart' as values;

// ignore: must_be_immutable
class SelectLocationPage extends StatelessWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  late SelectLocationBloc bloc;
  MapType mapType;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  SelectLocationPage({Key? key, required this.mapType}) : super(key: key);

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Widget build(BuildContext context) {
    SelectLocationBloc bloc =
        SelectLocationBloc(context: context, mapType: mapType);

    return WillPopScope(
        onWillPop: () async {
          Navigator.pop(context);
          return false;
        },
        child: FutureBuilder<bool>(
            future: bloc.getValues(),
            builder: (context, snapshot) {
              if (snapshot.connectionState != ConnectionState.done) {
                return Container(color: Colors.white);
              }
              return BlocProvider(
                  create: (_) => bloc,
                  child: Container(
                      color: custom_colors.appSafeAreaColor,
                      child: SafeArea(child:
                          BlocBuilder<SelectLocationBloc, SelectLocationState>(
                        builder: (context, state) {
                          return Scaffold(
                              appBar: CustomAppBar(
                                title: AppLocalizations.of(context)!
                                    .select_location,
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton: AppBarLeftButton.close,
                                leftButtonPressed: () => Navigator.pop(context),
                              ),
                              body: _getContent(context, bloc, state));
                        },
                      ))));
            }));
  }

  /// All the content shown below the action bar
  Widget _getContent(BuildContext context, SelectLocationBloc bloc,
      SelectLocationState state) {
    return Stack(
      children: [
        // Map with button at the bottom
        Column(
          children: [
            // Overview
            getMap(bloc, state),
            // 'Confirm' button
            Container(
                padding: const EdgeInsets.all(values.padding),
                color: custom_colors.black,
                child: CustomButton(
                  onPressed: () => bloc.add(const ButtonPressed(
                      buttonEvent: SelectLocationButtonEvent.confirm)),
                  text: AppLocalizations.of(context)!.confirm,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                ))
          ],
        ),
        // Circular button in top right corner on top of map
        Align(
          alignment: Alignment.topRight,
          child: CustomButton(
              height: 50,
              width: 50,
              margin: const EdgeInsets.only(
                  right: values.padding, top: values.padding),
              imagePadding: const EdgeInsets.all(10),
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              icon: state.mapType == MapType.hybrid
                  ? const Icon(Icons.layers_outlined, color: Colors.black)
                  : const Icon(Icons.layers, color: Colors.black),
              onPressed: () => bloc.add(const ButtonPressed(
                  buttonEvent: SelectLocationButtonEvent.changeMapType))),
        ),
      ],
    );
  }

  /// Map shown on the page
  Widget getMap(SelectLocationBloc bloc, SelectLocationState state) {
    return Expanded(
        child: GoogleMap(
      mapType: state.mapType!,
      initialCameraPosition: CameraPosition(
          target: LatLng(
              state.devicePosition!.latitude, state.devicePosition!.longitude),
          zoom: 14),
      myLocationEnabled: true,
      zoomControlsEnabled: false,
      myLocationButtonEnabled: false,
      buildingsEnabled: false,
      markers: state.marker == null ? <Marker>{} : <Marker>{state.marker!},
      onMapCreated: (GoogleMapController controller) {
        _googleMapCompleter.complete(controller);
      },
      onTap: (LatLng point) {
        bloc.add(AddMarker(point: point));
      },
    ));
  }

//endregion
}
