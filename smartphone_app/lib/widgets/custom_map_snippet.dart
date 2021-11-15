import 'dart:async';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

// ignore: must_be_immutable
class GoogleMapSnippet extends StatefulWidget {
  ///
  /// VARIABLES
  ///
  //region Variables

  double height;
  CameraPosition? initialCameraPosition;
  CameraPosition? cameraPosition;
  MapType? mapType;
  Marker? marker;
  double zoom;
  EdgeInsetsGeometry? margin;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  GoogleMapSnippet(
      {Key? key,
      this.height = 200,
      this.marker,
      this.margin,
      this.zoom = 14,
      this.mapType = MapType.normal,
      this.cameraPosition})
      : super(key: key) {}

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  State<StatefulWidget> createState() => _GoogleMapSnippetState();

//endregion
}

class _GoogleMapSnippetState extends State<GoogleMapSnippet> {
  final Completer<GoogleMapController> _googleMapCompleter = Completer();
  GoogleMapController? controller;

  @override
  Widget build(BuildContext context) {
    if (controller != null && widget.marker != null) {
      controller!.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: widget.marker!.position, zoom: widget.zoom)));
    }

    return Container(
        margin: widget.margin,
        height: widget.height,
        padding: const EdgeInsets.all(0),
        child: Center(
            child: ClipRRect(
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(5),
                  topRight: Radius.circular(5),
                  bottomRight: Radius.circular(5),
                  bottomLeft: Radius.circular(5),
                ),
                child: GoogleMap(
                      mapType: widget.mapType ?? MapType.normal,
                      initialCameraPosition: CameraPosition(
                          target: (widget.marker != null
                              ? widget.marker!.position
                              : const LatLng(0, 0)),
                          zoom: 14),
                      scrollGesturesEnabled: false,
                      rotateGesturesEnabled: false,
                      tiltGesturesEnabled: false,
                      indoorViewEnabled: false,
                      zoomGesturesEnabled: false,
                      myLocationEnabled: false,
                      zoomControlsEnabled: false,
                      myLocationButtonEnabled: false,
                      buildingsEnabled: false,
                      markers: widget.marker == null
                          ? <Marker>{}
                          : <Marker>{widget.marker!},
                      onMapCreated: (GoogleMapController controller) {
                        this.controller = controller;
                        _googleMapCompleter.complete(controller);
                      },
                    ))));
  }
}
