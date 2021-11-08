import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/models/google_classes.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/service/google_service.dart';

class IGoogleServiceFunctions {
  Future<GoogleServiceResponse<AddressFromCoordinateResponse>> getAddressFromCoordinate(LatLng coordinate) async {
    throw UnimplementedError();
  }
}