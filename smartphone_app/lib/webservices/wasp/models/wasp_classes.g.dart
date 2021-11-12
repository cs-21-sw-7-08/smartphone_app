// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'wasp_classes.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

WASPResponse _$WASPResponseFromJson(Map<String, dynamic> json) {
  return WASPResponse(
    isSuccessful: json['IsSuccessful'] as bool,
    errorNo: json['ErrorNo'] as int,
    errorMessage: json['ErrorMessage'] as String?,
  );
}

Map<String, dynamic> _$WASPResponseToJson(WASPResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
    };

GetListOfIssues_WASPResponse _$GetListOfIssues_WASPResponseFromJson(
    Map<String, dynamic> json) {
  return GetListOfIssues_WASPResponse(
    result: (json['Result'] as List<dynamic>?)
        ?.map((e) => Issue.fromJson(e as Map<String, dynamic>))
        .toList(),
  )
    ..isSuccessful = json['IsSuccessful'] as bool
    ..errorNo = json['ErrorNo'] as int
    ..errorMessage = json['ErrorMessage'] as String?;
}

Map<String, dynamic> _$GetListOfIssues_WASPResponseToJson(
        GetListOfIssues_WASPResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
      'Result': instance.result,
    };

GetListOfMunicipalities_WASPResponse
    _$GetListOfMunicipalities_WASPResponseFromJson(Map<String, dynamic> json) {
  return GetListOfMunicipalities_WASPResponse(
    result: (json['Result'] as List<dynamic>?)
        ?.map((e) => Municipality.fromJson(e as Map<String, dynamic>))
        .toList(),
  )
    ..isSuccessful = json['IsSuccessful'] as bool
    ..errorNo = json['ErrorNo'] as int
    ..errorMessage = json['ErrorMessage'] as String?;
}

Map<String, dynamic> _$GetListOfMunicipalities_WASPResponseToJson(
        GetListOfMunicipalities_WASPResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
      'Result': instance.result,
    };

GetIssueDetails_WASPResponse _$GetIssueDetails_WASPResponseFromJson(
    Map<String, dynamic> json) {
  return GetIssueDetails_WASPResponse(
    result: json['Result'] == null
        ? null
        : Issue.fromJson(json['Result'] as Map<String, dynamic>),
  )
    ..isSuccessful = json['IsSuccessful'] as bool
    ..errorNo = json['ErrorNo'] as int
    ..errorMessage = json['ErrorMessage'] as String?;
}

Map<String, dynamic> _$GetIssueDetails_WASPResponseToJson(
        GetIssueDetails_WASPResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
      'Result': instance.result,
    };

GetListOfCategories_WASPResponse _$GetListOfCategories_WASPResponseFromJson(
    Map<String, dynamic> json) {
  return GetListOfCategories_WASPResponse(
    result: (json['Result'] as List<dynamic>?)
        ?.map((e) => Category.fromJson(e as Map<String, dynamic>))
        .toList(),
  )
    ..isSuccessful = json['IsSuccessful'] as bool
    ..errorNo = json['ErrorNo'] as int
    ..errorMessage = json['ErrorMessage'] as String?;
}

Map<String, dynamic> _$GetListOfCategories_WASPResponseToJson(
        GetListOfCategories_WASPResponse instance) =>
    <String, dynamic>{
      'IsSuccessful': instance.isSuccessful,
      'ErrorNo': instance.errorNo,
      'ErrorMessage': instance.errorMessage,
      'Result': instance.result,
    };

Location _$LocationFromJson(Map<String, dynamic> json) {
  return Location(
    latitude: (json['Latitude'] as num).toDouble(),
    longitude: (json['Longitude'] as num).toDouble(),
  );
}

Map<String, dynamic> _$LocationToJson(Location instance) => <String, dynamic>{
      'Latitude': instance.latitude,
      'Longitude': instance.longitude,
    };

Category _$CategoryFromJson(Map<String, dynamic> json) {
  return Category(
    id: json['Id'] as int,
    name: json['Name'] as String?,
    subCategories: (json['SubCategories'] as List<dynamic>?)
        ?.map((e) => SubCategory.fromJson(e as Map<String, dynamic>))
        .toList(),
  );
}

Map<String, dynamic> _$CategoryToJson(Category instance) => <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
      'SubCategories': instance.subCategories,
    };

SubCategory _$SubCategoryFromJson(Map<String, dynamic> json) {
  return SubCategory(
    id: json['Id'] as int,
    categoryId: json['CategoryId'] as int,
    name: json['Name'] as String?,
  );
}

Map<String, dynamic> _$SubCategoryToJson(SubCategory instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'CategoryId': instance.categoryId,
      'Name': instance.name,
    };

Municipality _$MunicipalityFromJson(Map<String, dynamic> json) {
  return Municipality(
    id: json['Id'] as int,
    name: json['Name'] as String?,
  );
}

Map<String, dynamic> _$MunicipalityToJson(Municipality instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
    };

IssueState _$IssueStateFromJson(Map<String, dynamic> json) {
  return IssueState(
    id: json['Id'] as int,
    name: json['Name'] as String?,
  );
}

Map<String, dynamic> _$IssueStateToJson(IssueState instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'Name': instance.name,
    };

MunicipalityResponse _$MunicipalityResponseFromJson(Map<String, dynamic> json) {
  return MunicipalityResponse(
    id: json['Id'] as int,
    issueId: json['IssueId'] as int,
    municipalityUserId: json['MunicipalityUserId'] as int,
    response: json['Response'] as String,
    dateCreated: json['DateCreated'] == null
        ? null
        : DateTime.parse(json['DateCreated'] as String),
  );
}

Map<String, dynamic> _$MunicipalityResponseToJson(
        MunicipalityResponse instance) =>
    <String, dynamic>{
      'Id': instance.id,
      'IssueId': instance.issueId,
      'MunicipalityUserId': instance.municipalityUserId,
      'Response': instance.response,
      'DateCreated': instance.dateCreated?.toIso8601String(),
    };

Issue _$IssueFromJson(Map<String, dynamic> json) {
  return Issue(
    id: json['Id'] as int,
    citizenId: json['CitizenId'] as int,
    description: json['Description'] as String?,
    dateCreated: json['DateCreated'] == null
        ? null
        : DateTime.parse(json['DateCreated'] as String),
    location: json['Location'] == null
        ? null
        : Location.fromJson(json['Location'] as Map<String, dynamic>),
    category: json['Category'] == null
        ? null
        : Category.fromJson(json['Category'] as Map<String, dynamic>),
    subCategory: json['SubCategory'] == null
        ? null
        : SubCategory.fromJson(json['SubCategory'] as Map<String, dynamic>),
    municipality: json['Municipality'] == null
        ? null
        : Municipality.fromJson(json['Municipality'] as Map<String, dynamic>),
    issueState: json['IssueState'] == null
        ? null
        : IssueState.fromJson(json['IssueState'] as Map<String, dynamic>),
    municipalityResponses: (json['MunicipalityResponses'] as List<dynamic>?)
        ?.map((e) => MunicipalityResponse.fromJson(e as Map<String, dynamic>))
        .toList(),
    issueVerificationCitizenIds:
        (json['IssueVerificationCitizenIds'] as List<dynamic>?)
            ?.map((e) => e as int)
            .toList(),
  )
    ..picture1 = json['Picture1'] as String?
    ..picture2 = json['Picture2'] as String?
    ..picture3 = json['Picture3'] as String?;
}

Map<String, dynamic> _$IssueToJson(Issue instance) => <String, dynamic>{
      'Id': instance.id,
      'CitizenId': instance.citizenId,
      'Description': instance.description,
      'DateCreated': instance.dateCreated?.toIso8601String(),
      'Location': instance.location,
      'Picture1': instance.picture1,
      'Picture2': instance.picture2,
      'Picture3': instance.picture3,
      'Category': instance.category,
      'SubCategory': instance.subCategory,
      'Municipality': instance.municipality,
      'IssueState': instance.issueState,
      'MunicipalityResponses': instance.municipalityResponses,
      'IssueVerificationCitizenIds': instance.issueVerificationCitizenIds,
    };
