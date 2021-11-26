import 'dart:async';
import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:google_maps_cluster_manager/google_maps_cluster_manager.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/objects/place.dart';
import 'package:smartphone_app/utilities/wasp_util.dart';
import 'package:smartphone_app/values/colors.dart' as custom_colors;
import 'package:smartphone_app/values/values.dart' as values;
import 'package:smartphone_app/widgets/custom_app_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:smartphone_app/widgets/custom_button.dart';
import 'package:smartphone_app/widgets/custom_drawer_tile.dart';

import 'issues_overview_bloc.dart';
import 'issues_overview_events_states.dart';

// ignore: must_be_immutable
class IssuesOverviewPage extends StatefulWidget {
  const IssuesOverviewPage({Key? key}) : super(key: key);

  @override
  State<StatefulWidget> createState() => _IssuesOverviewPageState();
}

class _IssuesOverviewPageState extends State<IssuesOverviewPage> {
  ///
  /// VARIABLES
  ///
  //region Variables

  late ClusterManager _clusterManager;
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey();
  late IssuesOverviewBloc bloc;

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  _updateMarkers(Set<Marker> markers) {
    // ignore: avoid_print
    print('Updated ${markers.length} markers');
    bloc.add(MarkersUpdated(markers: markers));
  }

  Future<Marker> _markerBuilder(Cluster<ClusterItem> cluster) async {
    return Marker(
      markerId: MarkerId(cluster.getId()),
      position: cluster.location,
      onTap: () {
        if (cluster.isMultiple) {
          // TODO: Zoom in on children of the current cluster
        } else {
          ClusterItem item = cluster.items.first;
          if (item is Place) {
            bloc.add(IssuePressed(issue: item.issue));
          }
        }
      },
      consumeTapEvents: true,
      icon: await _getMarkerBitmap(cluster),
    );
  }

  Future<BitmapDescriptor> _getMarkerBitmap(
      Cluster<ClusterItem> cluster) async {
    if (cluster.isMultiple) {
      int size = 125;
      String text = cluster.count.toString();

      final PictureRecorder pictureRecorder = PictureRecorder();
      final Canvas canvas = Canvas(pictureRecorder);
      final Paint paint1 = Paint()..shader = custom_colors.orangeYellowShader;

      canvas.drawCircle(Offset(size / 2, size / 2), size / 2.0, paint1);

      TextPainter painter = TextPainter(textDirection: TextDirection.ltr);
      painter.text = TextSpan(
        text: text,
        style: TextStyle(
            fontSize: size / 3,
            color: Colors.black,
            fontWeight: FontWeight.bold),
      );
      painter.layout();
      painter.paint(
        canvas,
        Offset(size / 2 - painter.width / 2, size / 2 - painter.height / 2),
      );

      final img = await pictureRecorder.endRecording().toImage(size, size);
      final data =
          await img.toByteData(format: ImageByteFormat.png) as ByteData;

      return BitmapDescriptor.fromBytes(data.buffer.asUint8List());
    } else {
      ClusterItem item = cluster.items.first;
      if (item is Place) {
        return WASPUtil.getIssueStateMarkerIcon(item.issue.issueState!);
      }
      return BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRose);
    }
  }

  //endregion

  ///
  /// BUILD METHOD
  ///
  //region Build method

  @override
  Widget build(BuildContext context) {
    bloc = IssuesOverviewBloc(context: context);

    _clusterManager = ClusterManager(
        bloc.state.places ?? List.empty(), _updateMarkers,
        levels: const [1, 4.25, 6.75, 8.25, 13.5],
        markerBuilder: _markerBuilder,
        stopClusteringZoom: 13.5);

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
                      child: BlocListener<IssuesOverviewBloc,
                              IssuesOverviewState>(
                          listener: (context, state) {
                            if (state.places != null) {
                              if (_clusterManager.items.hashCode !=
                                  state.places.hashCode) {
                                _clusterManager.setItems(state.places!);
                              }
                            }
                          },
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
                                                    margin:
                                                        const EdgeInsets.only(
                                                            left: 8),
                                                    imagePadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    showBorder: false,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                22)),
                                                    defaultBackground:
                                                        custom_colors
                                                            .transparentGradient,
                                                    pressedBackground: custom_colors
                                                        .backButtonGradientPressedDefault,
                                                    icon: const Icon(
                                                        Icons.close,
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
                                              onPressed: () {
                                                Navigator.pop(context);
                                                bloc.add(
                                                    ButtonPressed(
                                                        issuesOverviewButtonEvent:
                                                        IssuesOverviewButtonEvent
                                                            .showSettings));
                                              },
                                              text:
                                                  AppLocalizations.of(context)!
                                                      .settings,
                                            ),
                                            CustomDrawerTile(
                                              icon: const Icon(
                                                  Icons.logout_outlined,
                                                  color: Colors.black,
                                                  size: 30),
                                              text:
                                                  AppLocalizations.of(context)!
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
                                    title:
                                        AppLocalizations.of(context)!.overview,
                                    titleColor: Colors.white,
                                    background: custom_colors.appBarBackground,
                                    appBarLeftButton: AppBarLeftButton.menu,
                                    leftButtonPressed: () async => {
                                      _scaffoldKey.currentState!.openDrawer()
                                    },
                                    button1Icon: const Icon(Icons.tune_outlined,
                                        color: Colors.white),
                                    onButton1Pressed: () => bloc.add(
                                        ButtonPressed(
                                            issuesOverviewButtonEvent:
                                                IssuesOverviewButtonEvent
                                                    .showFilter)),
                                  ),
                                  body: _getContent(bloc))))));
            }));
  }

  Widget _getContent(IssuesOverviewBloc bloc) {
    return BlocBuilder<IssuesOverviewBloc, IssuesOverviewState>(
      builder: (context, state) {
        return Stack(
          children: [
            _getOverview(bloc, state),
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
    return Column(
      children: [
        Expanded(
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
          onCameraMove: _clusterManager.onCameraMove,
          onCameraIdle: _clusterManager.updateMap,
          markers: state.markers ?? <Marker>{},
          onMapCreated: (GoogleMapController controller) {
            _googleMapCompleter.complete(controller);
            _clusterManager.setMapId(controller.mapId);
          },
        )),
        Container(
            color: custom_colors.black,
            padding: const EdgeInsets.all(values.padding),
            child: CustomButton(
              onPressed: () => bloc.add(ButtonPressed(
                  issuesOverviewButtonEvent:
                      IssuesOverviewButtonEvent.createIssue)),
              text: AppLocalizations.of(context)!.create_issue,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ))
      ],
    );
  }

//endregion
}
