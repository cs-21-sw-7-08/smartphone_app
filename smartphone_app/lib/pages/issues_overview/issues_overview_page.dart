import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_drawer_tile.dart';

import 'issues_overview_bloc.dart';
import 'issues_overview_events_states.dart';

// ignore: must_be_immutable
class IssuesOverviewPage extends StatelessWidget {
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late IssuesOverviewBloc bloc;

  IssuesOverviewPage({Key? key}) : super(key: key);

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
                                          onPressed: () {},
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
            Column(
              children: [
                // Overview
                getOverview(bloc, state),
                // 'Create issue' button
                CustomButton(
                  onPressed: () => bloc.add(ButtonPressed(
                      issuesOverviewButtonEvent:
                          IssuesOverviewButtonEvent.createIssue)),
                  text: AppLocalizations.of(context)!.create_issue,
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
                      issuesOverviewButtonEvent:
                          IssuesOverviewButtonEvent.changeMapType))),
            ),
            Container(
                margin: const EdgeInsets.only(bottom: 55),
                child: Align(
                  alignment: Alignment.bottomRight,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CustomButton(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(right: 8, bottom: 8),
                          imagePadding: const EdgeInsets.all(10),
                          showBorder: true,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          defaultBackground: custom_colors.whiteGradient,
                          pressedBackground: custom_colors.greyGradient,
                          icon: const Icon(Icons.refresh_outlined,
                              color: Colors.black),
                          onPressed: () => bloc.add(ButtonPressed(
                              issuesOverviewButtonEvent:
                                  IssuesOverviewButtonEvent.getListOfIssues))),
                      CustomButton(
                          height: 50,
                          width: 50,
                          margin: const EdgeInsets.only(right: 8, bottom: 8),
                          imagePadding: const EdgeInsets.all(10),
                          showBorder: true,
                          borderRadius:
                              const BorderRadius.all(Radius.circular(25)),
                          defaultBackground: custom_colors.whiteGradient,
                          pressedBackground: custom_colors.greyGradient,
                          icon: state.issuesOverviewPageView ==
                                  IssuesOverviewPageView.map
                              ? const Icon(Icons.format_list_bulleted_outlined,
                                  color: Colors.black)
                              : const Icon(Icons.map_outlined,
                                  color: Colors.black),
                          onPressed: () => bloc.add(ButtonPressed(
                              issuesOverviewButtonEvent:
                                  IssuesOverviewButtonEvent
                                      .changeOverviewType)))
                    ],
                  ),
                ))
          ],
        );
      },
    );
  }

  Widget getOverview(IssuesOverviewBloc bloc, IssuesOverviewState state) {
    switch (state.issuesOverviewPageView!) {
      case IssuesOverviewPageView.map:
        return Expanded(
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
          markers: state.markers ?? <Marker>{},
          onMapCreated: (GoogleMapController controller) {
            _googleMapCompleter.complete(controller);
          },
          /*onTap: (LatLng point) {
            bloc.add(AddMarker(point: point));
          },*/
        ));
      case IssuesOverviewPageView.list:
        return Expanded(child: Container());
    }
  }
}
