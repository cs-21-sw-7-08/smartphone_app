// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'google_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

GoogleResponse _$GoogleResponseFromJson(Map<String, dynamic> json) {
  return GoogleResponse(
    errorMessage: json['error_message'] as String?,
    status: json['status'] as String?,
  );
}

Map<String, dynamic> _$GoogleResponseToJson(GoogleResponse instance) =>
    <String, dynamic>{
      'error_message': instance.errorMessage,
      'status': instance.status,
    };

AddressFromCoordinateResponse _$AddressFromCoordinateResponseFromJson(
    Map<String, dynamic> json) {
  return AddressFromCoordinateResponse(
    results: (json['results'] as List<dynamic>?)
        ?.map((e) =>
            AddressFromCoordinateResult.fromJson(e as Map<String, dynamic>))
        .toList(),
    errorMessage: json['error_message'] as String?,
    status: json['status'] as String?,
  );
}

Map<String, dynamic> _$AddressFromCoordinateResponseToJson(
        AddressFromCoordinateResponse instance) =>
    <String, dynamic>{
      'error_message': instance.errorMessage,
      'status': instance.status,
      'results': instance.results,
    };

AddressFromCoordinateResult _$AddressFromCoordinateResultFromJson(
    Map<String, dynamic> json) {
  return AddressFromCoordinateResult(
    addressComponents: (json['address_components'] as List<dynamic>?)
        ?.map((e) => AddressComponent.fromJson(e as Map<String, dynamic>))
        .toList(),
    formattedAddress: json['formatted_address'] as String?,
    geometry: json['geometry'],
    placeId: json['place_id'] as String?,
    types: (json['types'] as List<dynamic>?)?.map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$AddressFromCoordinateResultToJson(
        AddressFromCoordinateResult instance) =>
    <String, dynamic>{
      'address_components': instance.addressComponents,
      'formatted_address': instance.formattedAddress,
      'geometry': instance.geometry,
      'place_id': instance.placeId,
      'types': instance.types,
    };

AddressComponent _$AddressComponentFromJson(Map<String, dynamic> json) {
  return AddressComponent(
    longName: json['long_name'] as String,
    shortName: json['short_name'] as String,
    types: (json['types'] as List<dynamic>).map((e) => e as String).toList(),
  );
}

Map<String, dynamic> _$AddressComponentToJson(AddressComponent instance) =>
    <String, dynamic>{
      'long_name': instance.longName,
      'short_name': instance.shortName,
      'types': instance.types,
    };
