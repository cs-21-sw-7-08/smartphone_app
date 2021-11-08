import 'package:google_maps_flutter_platform_interface/src/types/location.dart';
import 'package:smartphone_app/helpers/rest_helper.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/interfaces/google_service_functions.dart';
import 'package:smartphone_app/webservices/google_reverse_geocoding/models/google_classes.dart';

class GoogleServiceResponse<Response extends GoogleResponse> {
  String? exception;
  Response? googleResponse;

  GoogleServiceResponse.error(this.exception) {
    googleResponse = null;
  }

  GoogleServiceResponse.success(this.googleResponse) {
    exception = null;
  }

  bool get isSuccess {
    if (exception != null) return false;
    if (googleResponse != null &&
        googleResponse!.status != null &&
        googleResponse!.status != "OK") return false;
    return true;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    if (googleResponse != null &&
        googleResponse!.status != null &&
        googleResponse!.status != "OK") return googleResponse!.errorMessage;
    return null;
  }
}

class GoogleService implements IGoogleServiceFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static IGoogleServiceFunctions? _googleServiceFunctions;

  static init(IGoogleServiceFunctions googleServiceFunctions) {
    _googleServiceFunctions = googleServiceFunctions;
  }

  static IGoogleServiceFunctions getInstance() {
    return _googleServiceFunctions!;
  }

  //endregion

  ///
  /// CONSTANTS
  ///
  //region Constants

  static const String url = "https://maps.googleapis.com";
  static const String apiKey = "AIzaSyAiHjPFfpvyQRlZCVeBp1ysPFD60klv9ok";

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late RestHelper restHelper;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  GoogleService() {
    restHelper = RestHelper(url: url);
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<GoogleServiceResponse<AddressFromCoordinateResponse>>
      getAddressFromCoordinate(LatLng coordinate) async {
    // Send GET request
    RestResponse restResponse =
        await restHelper.sendGetRequest("/maps/api/geocode/json",
            parameters: List.of({
              RestParameter(name: "key", value: apiKey),
              RestParameter(
                  name: "latlng",
                  value: "${coordinate.latitude},${coordinate.longitude}")
            }));
    // Check for errors
    if (!restResponse.isSuccess) {
      return GoogleServiceResponse.error(restResponse.errorMessage);
    }
    // Decode json
    AddressFromCoordinateResponse response =
        AddressFromCoordinateResponse.fromJson(restResponse.jsonResponse);
    // Return success response
    return GoogleServiceResponse.success(response);
  }

//endregion

}
