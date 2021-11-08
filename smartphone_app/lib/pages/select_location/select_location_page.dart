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

// ignore: must_be_immutable
class SelectLocationPage extends StatelessWidget {
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  late SelectLocationBloc bloc;

  SelectLocationPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SelectLocationBloc bloc = SelectLocationBloc(buildContext: context);

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
                                title: AppLocalizations.of(context)!.overview,
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton: AppBarLeftButton.back,
                                leftButtonPressed: () => Navigator.pop(context),
                              ),
                              body: getContent(context, bloc, state));
                        },
                      ))));
            }));
  }

  Widget getContent(BuildContext context, SelectLocationBloc bloc,
      SelectLocationState state) {
    return Stack(
      children: [
        Column(
          children: [
            // Overview
            getMap(bloc, state),
            // 'Confirm' button
            if (state.marker != null)
              CustomButton(
                onPressed: () => bloc.add(ButtonPressed(
                    selectLocationButtonEvent:
                    SelectLocationButtonEvent.confirm)),
                text: AppLocalizations.of(context)!.confirm,
                fontWeight: FontWeight.bold,
                border: Border.all(color: Colors.black, width: 1),
                borderRadius: const BorderRadius.all(Radius.circular(0)),
                fontSize: 20,
                showBorder: true,
                defaultBackground: custom_colors.whiteGradient,
                pressedBackground: custom_colors.greyGradient,
              )
          ],
        ),
        Align(
          alignment: Alignment.topRight,
          child: CustomButton(
              height: 50,
              width: 50,
              margin: const EdgeInsets.only(right: 8, top: 8),
              imagePadding: const EdgeInsets.all(10),
              showBorder: true,
              borderRadius: const BorderRadius.all(Radius.circular(25)),
              defaultBackground: custom_colors.whiteGradient,
              pressedBackground: custom_colors.greyGradient,
              icon: state.mapType == MapType.hybrid
                  ? const Icon(Icons.layers_outlined, color: Colors.black)
                  : const Icon(Icons.layers, color: Colors.black),
              onPressed: () => bloc.add(ButtonPressed(
                  selectLocationButtonEvent:
                      SelectLocationButtonEvent.changeMapType))),
        ),
      ],
    );
  }

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
}
