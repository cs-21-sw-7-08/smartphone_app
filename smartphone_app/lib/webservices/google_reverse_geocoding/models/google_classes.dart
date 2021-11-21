import 'package:json_annotation/json_annotation.dart';

part 'google_classes.g.dart';

@JsonSerializable()
class GoogleResponse {
  @JsonKey(name: "error_message")
  String? errorMessage;
  @JsonKey(name: "status")
  String? status;

  GoogleResponse({this.errorMessage, this.status});

  factory GoogleResponse.fromJson(Map<String, dynamic> json) =>
      _$GoogleResponseFromJson(json);

  Map<String, dynamic> toJson() => _$GoogleResponseToJson(this);
}

@JsonSerializable()
class AddressFromCoordinateResponse extends GoogleResponse {
  List<AddressFromCoordinateResult>? results;

  AddressFromCoordinateResponse(
      {this.results, String? errorMessage, String? status})
      : super(errorMessage: errorMessage, status: status);

  factory AddressFromCoordinateResponse.fromJson(Map<String, dynamic> json) =>
      _$AddressFromCoordinateResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$AddressFromCoordinateResponseToJson(this);

  String? getAddress() {
    if (results == null || results!.isEmpty) return null;
    AddressFromCoordinateResult addressFromCoordinateResult = results![0];
    return addressFromCoordinateResult.formattedAddress!;
  }

  String? getMunicipalityName() {
    AddressFromCoordinateResult addressFromCoordinateResult = results![0];
    var addressComponents = addressFromCoordinateResult.addressComponents!
        .where((element) => element.types.contains("locality"));
    AddressComponent? addressComponent =
        addressComponents.isNotEmpty ? addressComponents.first : null;
    // Check for null value
    if (addressComponent == null) return null;
    // Return municipality name
    return addressComponent.shortName;
  }
}

@JsonSerializable()
class AddressFromCoordinateResult {
  @JsonKey(name: "address_components")
  List<AddressComponent>? addressComponents;
  @JsonKey(name: "formatted_address")
  String? formattedAddress;
  dynamic geometry;
  @JsonKey(name: "place_id")
  String? placeId;
  List<String>? types;

  AddressFromCoordinateResult(
      {this.addressComponents,
      this.formattedAddress,
      this.geometry,
      this.placeId,
      this.types});

  factory AddressFromCoordinateResult.fromJson(Map<String, dynamic> json) =>
      _$AddressFromCoordinateResultFromJson(json);

  Map<String, dynamic> toJson() => _$AddressFromCoordinateResultToJson(this);
}

@JsonSerializable()
class AddressComponent {
  @JsonKey(name: "long_name")
  String longName;
  @JsonKey(name: "short_name")
  String shortName;
  List<String> types;

  AddressComponent(
      {required this.longName, required this.shortName, required this.types});

  factory AddressComponent.fromJson(Map<String, dynamic> json) =>
      _$AddressComponentFromJson(json);

  Map<String, dynamic> toJson() => _$AddressComponentToJson(this);
}
