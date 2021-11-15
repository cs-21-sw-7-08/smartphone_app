import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:smartphone_app/localization/localization_helper.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_drawer_tile.dart';
import 'package:smartphone_app/widgets/custom_header.dart';
import 'package:smartphone_app/widgets/custom_list_tile.dart';

import 'issues_overview_bloc.dart';
import 'issues_overview_events_states.dart';

// ignore: must_be_immutable
class IssuesOverviewPage extends StatefulWidget {
  const IssuesOverviewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IssuesOverviewPageState();
}

class _IssuesOverviewPageState extends State<IssuesOverviewPage> {
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late IssuesOverviewBloc bloc;

  @override
  Widget build(BuildContext context) {
    IssuesOverviewBloc bloc = IssuesOverviewBloc(buildContext: context);

    return WillPopScope(
        onWillPop: () async {
          return true;
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
                      child: SafeArea(
                          child: Scaffold(
                              key: _scaffoldKey,
                              drawer: Drawer(
                                child: Container(
                                    color: Colors.white,
                                    child: ListView(
                                      // Important: Remove any padding from the ListView.
                                      padding: EdgeInsets.zero,
                                      children: [
                                        Container(
                                          color: custom_colors.black,
                                          height: 56,
                                          child: Row(
                                            children: [
                                              CustomButton(
                                                onPressed: () {
                                                  Navigator.pop(context);
                                                },
                                                height: 44,
                                                width: 44,
                                                margin: const EdgeInsets.only(
                                                    left: 8),
                                                imagePadding:
                                                    const EdgeInsets.all(10),
                                                showBorder: false,
                                                borderRadius:
                                                    const BorderRadius.all(
                                                        Radius.circular(22)),
                                                defaultBackground: custom_colors
                                                    .transparentGradient,
                                                pressedBackground: custom_colors
                                                    .backButtonGradientPressedDefault,
                                                icon: const Icon(Icons.close,
                                                    color: Colors.white),
                                              )
                                            ],
                                          ),
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(
                                            Icons.settings_outlined,
                                            color: Colors.black,
                                            size: 30,
                                          ),
                                          onPressed: () {},
                                          text: AppLocalizations.of(context)!
                                              .settings,
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(Icons.info_outline,
                                              color: Colors.black, size: 30),
                                          text: AppLocalizations.of(context)!
                                              .help,
                                          onPressed: () async {},
                                        ),
                                        Container(
                                          height: 1,
                                          color: Colors.black,
                                        ),
                                        CustomDrawerTile(
                                          icon: const Icon(
                                              Icons.logout_outlined,
                                              color: Colors.black,
                                              size: 30),
                                          text: AppLocalizations.of(context)!
                                              .log_out,
                                          onPressed: () async {
                                            Navigator.pop(context);

                                            bloc.add(ButtonPressed(
                                                issuesOverviewButtonEvent:
                                                    IssuesOverviewButtonEvent
                                                        .logOut));
                                          },
                                        ),
                                      ],
                                    )),
                              ),
                              appBar: CustomAppBar(
                                title: AppLocalizations.of(context)!.overview,
                                titleColor: Colors.white,
                                background: custom_colors.appBarBackground,
                                appBarLeftButton: AppBarLeftButton.menu,
                                leftButtonPressed: () async =>
                                    {_scaffoldKey.currentState!.openDrawer()},
                                button1Icon: const Icon(Icons.tune_outlined,
                                    color: Colors.white),
                                onButton1Pressed: () {
                                  // Show filter page
                                },
                              ),
                              body: getContent(bloc)))));
            }));
  }

  Widget getContent(IssuesOverviewBloc bloc) {
    return BlocBuilder<IssuesOverviewBloc, IssuesOverviewState>(
      builder: (context, state) {
        return Stack(
          children: [
            _getOverview(bloc, state),
            Align(
                alignment: Alignment.bottomLeft,
                child: CustomButton(
                  onPressed: () => bloc.add(ButtonPressed(
                      issuesOverviewButtonEvent:
                          IssuesOverviewButtonEvent.createIssue)),
                  text: AppLocalizations.of(context)!.create_issue,
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  margin: const EdgeInsets.only(
                      bottom: values.padding,
                      left: values.padding,
                      right: values.padding),
                )),
            Align(
              alignment: Alignment.topRight,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  CustomButton(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.only(
                          right: values.padding, top: values.padding),
                      imagePadding: const EdgeInsets.all(10),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      icon: state.mapType == MapType.hybrid
                          ? const Icon(Icons.layers_outlined,
                              color: Colors.black)
                          : const Icon(Icons.layers, color: Colors.black),
                      onPressed: () => bloc.add(ButtonPressed(
                          issuesOverviewButtonEvent:
                              IssuesOverviewButtonEvent.changeMapType))),
                  CustomButton(
                      height: 50,
                      width: 50,
                      margin: const EdgeInsets.only(
                          right: values.padding,
                          bottom: values.padding,
                          top: values.padding),
                      imagePadding: const EdgeInsets.all(10),
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      icon: const Icon(Icons.refresh_outlined,
                          color: Colors.black),
                      onPressed: () => bloc.add(ButtonPressed(
                          issuesOverviewButtonEvent:
                              IssuesOverviewButtonEvent.getListOfIssues))),
                ],
              ),
            )
          ],
        );
      },
    );
  }

  Widget _getOverview(IssuesOverviewBloc bloc, IssuesOverviewState state) {
    return Container(
        padding: const EdgeInsets.only(bottom: 55 + values.padding * 2),
        color: custom_colors.black,
        child: GoogleMap(
          mapType: state.mapType!,
          initialCameraPosition: CameraPosition(
              target: LatLng(state.devicePosition!.latitude,
                  state.devicePosition!.longitude),
              zoom: 14),
          myLocationEnabled: true,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          buildingsEnabled: false,
          indoorViewEnabled: false,
          markers: state.markers ?? <Marker>{},
          onMapCreated: (GoogleMapController controller) {
            _googleMapCompleter.complete(controller);
          },
        ));
  }
}
