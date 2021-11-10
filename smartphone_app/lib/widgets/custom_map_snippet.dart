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

  GoogleMapController? controller;

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
      : super(key: key) {
    if (controller != null && marker != null) {
      controller!.moveCamera(CameraUpdate.newCameraPosition(
          CameraPosition(target: marker!.position, zoom: zoom)));
    }
  }

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

  @override
  Widget build(BuildContext context) {
    return Container(
        margin: widget.margin,
        height: widget.height,
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
          zoomGesturesEnabled: false,
          myLocationEnabled: false,
          zoomControlsEnabled: false,
          myLocationButtonEnabled: false,
          buildingsEnabled: false,
          markers:
              widget.marker == null ? <Marker>{} : <Marker>{widget.marker!},
          onMapCreated: (GoogleMapController controller) {
            widget.controller = controller;
            _googleMapCompleter.complete(controller);
          },
        ));
  }
}
