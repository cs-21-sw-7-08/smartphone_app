import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:json_annotation/json_annotation.dart';

part 'wasp_classes.g.dart';

@JsonSerializable()
class WASPResponse {
  @JsonKey(name: "IsSuccessful")
  late bool isSuccessful;
  @JsonKey(name: "ErrorNo")
  late int errorNo;
  @JsonKey(name: "ErrorMessage")
  late String? errorMessage;

  WASPResponse({this.isSuccessful = true, this.errorNo = 0, this.errorMessage});

  factory WASPResponse.fromJson(Map<String, dynamic> json) =>
      _$WASPResponseFromJson(json);

  Map<String, dynamic> toJson() => _$WASPResponseToJson(this);

  String? getErrorMessage() {
    if (!isSuccessful && errorNo != 0) {
      return "WASP error: ${errorNo.toString()}";
    } else if (errorMessage != null) {
      return errorMessage;
    }
    return null;
  }
}

@JsonSerializable()
class GetListOfIssues_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late List<Issue>? result;

  GetListOfIssues_WASPResponse({this.result});

  factory GetListOfIssues_WASPResponse.fromJson(Map<String, dynamic> json) =>
      _$GetListOfIssues_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetListOfIssues_WASPResponseToJson(this);
}

@JsonSerializable()
class GetListOfMunicipalities_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late List<Municipality>? result;

  GetListOfMunicipalities_WASPResponse({this.result});

  factory GetListOfMunicipalities_WASPResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetListOfMunicipalities_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GetListOfMunicipalities_WASPResponseToJson(this);
}

@JsonSerializable()
class IsBlockedCitizen_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late bool? result;

  IsBlockedCitizen_WASPResponse({this.result});

  factory IsBlockedCitizen_WASPResponse.fromJson(Map<String, dynamic> json) =>
      _$IsBlockedCitizen_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$IsBlockedCitizen_WASPResponseToJson(this);
}

@JsonSerializable()
class Citizen_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late Citizen? result;

  Citizen_WASPResponse({this.result});

  factory Citizen_WASPResponse.fromJson(Map<String, dynamic> json) =>
      _$Citizen_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$Citizen_WASPResponseToJson(this);
}

@JsonSerializable()
class GetIssueDetails_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late Issue? result;

  GetIssueDetails_WASPResponse({this.result});

  factory GetIssueDetails_WASPResponse.fromJson(Map<String, dynamic> json) =>
      _$GetIssueDetails_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() => _$GetIssueDetails_WASPResponseToJson(this);
}

@JsonSerializable()
class GetListOfCategories_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late List<Category>? result;

  GetListOfCategories_WASPResponse({this.result});

  factory GetListOfCategories_WASPResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetListOfCategories_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GetListOfCategories_WASPResponseToJson(this);
}

@JsonSerializable()
class GetListOfReportCategories_WASPResponse extends WASPResponse {
  @JsonKey(name: "Result")
  late List<ReportCategory>? result;

  GetListOfReportCategories_WASPResponse({this.result});

  factory GetListOfReportCategories_WASPResponse.fromJson(
          Map<String, dynamic> json) =>
      _$GetListOfReportCategories_WASPResponseFromJson(json);

  @override
  Map<String, dynamic> toJson() =>
      _$GetListOfReportCategories_WASPResponseToJson(this);
}

@JsonSerializable()
class Location {
  @JsonKey(name: "Latitude")
  late double latitude;
  @JsonKey(name: "Longitude")
  late double longitude;

  Location({this.latitude = 0, this.longitude = 0});

  factory Location.fromJson(Map<String, dynamic> json) =>
      _$LocationFromJson(json);

  Map<String, dynamic> toJson() => _$LocationToJson(this);

  factory Location.fromLatLng(LatLng latLng) =>
      Location(latitude: latLng.latitude, longitude: latLng.longitude);
}

@JsonSerializable()
class Category {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "Name")
  late String? name;
  @JsonKey(name: "SubCategories")
  late List<SubCategory>? subCategories;

  Category({this.id = 0, this.name, this.subCategories});

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);

  Map<String, dynamic> toJson() => _$CategoryToJson(this);

  @override
  @JsonKey(ignore: true)
  int get hashCode => id;

  @override
  bool operator ==(Object other) {
    if (other is! Category) {
      return false;
    }
    return hashCode == other.hashCode;
  }
}

@JsonSerializable()
class SubCategory {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "CategoryId")
  late int categoryId;
  @JsonKey(name: "Name")
  late String? name;

  SubCategory({this.id = 0, this.categoryId = 0, this.name});

  factory SubCategory.fromJson(Map<String, dynamic> json) =>
      _$SubCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$SubCategoryToJson(this);

  @override
  @JsonKey(ignore: true)
  int get hashCode => id;

  @override
  bool operator ==(Object other) {
    if (other is! SubCategory) {
      return false;
    }
    return hashCode == other.hashCode;
  }
}

@JsonSerializable()
class Municipality {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "Name")
  late String? name;

  Municipality({this.id = 0, this.name});

  factory Municipality.fromJson(Map<String, dynamic> json) =>
      _$MunicipalityFromJson(json);

  Map<String, dynamic> toJson() => _$MunicipalityToJson(this);

  @override
  @JsonKey(ignore: true)
  int get hashCode => id.hashCode;

  @override
  bool operator ==(Object other) {
    if (other is! Municipality) {
      return false;
    }
    return hashCode == other.hashCode;
  }
}

@JsonSerializable()
class ReportCategory {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "Name")
  late String? name;

  ReportCategory({this.id = 0, this.name});

  factory ReportCategory.fromJson(Map<String, dynamic> json) =>
      _$ReportCategoryFromJson(json);

  Map<String, dynamic> toJson() => _$ReportCategoryToJson(this);
}

enum IssueStates { created, approved, resolved, notResolved }

@JsonSerializable()
class IssueState {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "Name")
  late String? name;

  IssueState({this.id = 0, this.name});

  factory IssueState.fromJson(Map<String, dynamic> json) =>
      _$IssueStateFromJson(json);

  Map<String, dynamic> toJson() => _$IssueStateToJson(this);

  IssueStates getEnum() => IssueStates.values[id - 1];
}

@JsonSerializable()
class MunicipalityResponse {
  @JsonKey(name: "Id")
  late int id;
  @JsonKey(name: "IssueId")
  late int issueId;
  @JsonKey(name: "MunicipalityUserId")
  late int municipalityUserId;
  @JsonKey(name: "Response")
  late String response;
  @JsonKey(name: "DateCreated")
  late DateTime? dateCreated;
  @JsonKey(name: "DateEdited")
  late DateTime? dateEdited;

  MunicipalityResponse(
      {this.id = 0,
      this.issueId = 0,
      this.dateEdited,
      this.municipalityUserId = 0,
      this.response = "",
      this.dateCreated});

  factory MunicipalityResponse.fromJson(Map<String, dynamic> json) =>
      _$MunicipalityResponseFromJson(json);

  Map<String, dynamic> toJson() => _$MunicipalityResponseToJson(this);
}

@JsonSerializable()
class Issue {
  @JsonKey(name: "Id")
  late int? id;
  @JsonKey(name: "CitizenId")
  late int? citizenId;
  @JsonKey(name: "Description")
  late String? description;
  @JsonKey(name: "DateCreated")
  late DateTime? dateCreated;
  @JsonKey(name: "DateEdited")
  late DateTime? dateEdited;
  @JsonKey(name: "Location")
  late Location? location;
  @JsonKey(name: "Address")
  late String? address;
  @JsonKey(name: "Picture1")
  late String? picture1;
  @JsonKey(name: "Picture2")
  late String? picture2;
  @JsonKey(name: "Picture3")
  late String? picture3;
  @JsonKey(name: "Category")
  late Category? category;
  @JsonKey(name: "SubCategory")
  late SubCategory? subCategory;
  @JsonKey(name: "Municipality")
  late Municipality? municipality;
  @JsonKey(name: "IssueState")
  late IssueState? issueState;
  @JsonKey(name: "MunicipalityResponses")
  late List<MunicipalityResponse>? municipalityResponses;
  @JsonKey(name: "IssueVerificationCitizenIds")
  late List<int>? issueVerificationCitizenIds;

  Issue(
      {this.id = 0,
      this.citizenId = 0,
      this.description,
      this.dateCreated,
      this.dateEdited,
      this.location,
      this.address,
      this.category,
      this.subCategory,
      this.municipality,
      this.issueState,
      this.municipalityResponses,
      this.issueVerificationCitizenIds}) {
    municipalityResponses ??= List.empty();
    issueVerificationCitizenIds ??= List.empty();
  }

  factory Issue.fromJson(Map<String, dynamic> json) => _$IssueFromJson(json);

  Map<String, dynamic> toJson() => _$IssueToJson(this);
}

@JsonSerializable()
class IssueCreateDTO {
  @JsonKey(name: "CitizenId")
  late int? citizenId;
  @JsonKey(name: "Description")
  late String? description;
  @JsonKey(name: "Location")
  late Location? location;
  @JsonKey(name: "Address")
  late String? address;
  @JsonKey(name: "Picture1")
  late String? picture1;
  @JsonKey(name: "Picture2")
  late String? picture2;
  @JsonKey(name: "Picture3")
  late String? picture3;
  @JsonKey(name: "SubCategoryId")
  late int? subCategoryId;
  @JsonKey(name: "MunicipalityId")
  late int? municipalityId;

  IssueCreateDTO(
      {this.citizenId = 0,
      this.description,
      this.location,
      this.address,
      this.subCategoryId,
      this.municipalityId,
      this.picture1,
      this.picture2,
      this.picture3});

  factory IssueCreateDTO.fromJson(Map<String, dynamic> json) =>
      _$IssueCreateDTOFromJson(json);

  Map<String, dynamic> toJson() => _$IssueCreateDTOToJson(this);
}

@JsonSerializable()
class Citizen {
  @JsonKey(name: "Id")
  late int? id;
  @JsonKey(name: "Email")
  late String? email;
  @JsonKey(name: "PhoneNo")
  late String? phoneNo;
  @JsonKey(name: "Name")
  late String? name;
  @JsonKey(name: "IsBlocked")
  late bool? isBlocked;
  @JsonKey(name: "Municipality")
  late Municipality? municipality;
  @JsonKey(name: "MunicipalityId")
  late int? municipalityId;

  Citizen(
      {this.id,
      this.email,
      this.phoneNo,
      this.name,
      this.isBlocked,
      this.municipality,
      this.municipalityId});

  factory Citizen.fromJson(Map<String, dynamic> json) =>
      _$CitizenFromJson(json);

  Map<String, dynamic> toJson() => _$CitizenToJson(this);
}

@JsonSerializable()
class IssuesOverviewFilter {
  @JsonKey(name: "FromTime")
  late DateTime? fromTime;
  @JsonKey(name: "ToTime")
  late DateTime? toTime;
  @JsonKey(name: "MunicipalityIds")
  late List<int>? municipalityIds;
  @JsonKey(name: "IssueStateIds")
  late List<int>? issueStateIds;
  @JsonKey(name: "CategoryIds")
  late List<int>? categoryIds;
  @JsonKey(name: "SubCategoryIds")
  late List<int>? subCategoryIds;
  @JsonKey(name: "CitizenIds")
  late List<int>? citizenIds;
  @JsonKey(name: "IsBlocked")
  late bool? isBlocked;

  IssuesOverviewFilter(
      {this.fromTime,
      this.toTime,
      this.municipalityIds,
      this.issueStateIds,
      this.categoryIds,
      this.citizenIds,
      this.subCategoryIds,
      this.isBlocked});

  factory IssuesOverviewFilter.fromJson(Map<String, dynamic> json) =>
      _$IssuesOverviewFilterFromJson(json);

  Map<String, dynamic> toJson() => _$IssuesOverviewFilterToJson(this);
}

@JsonSerializable()
class WASPUpdate {
  @JsonKey(name: "Name")
  late String? name;
  @JsonKey(name: "Value")
  late String? value;

  WASPUpdate({this.name, this.value});

  factory WASPUpdate.fromJson(Map<String, dynamic> json) =>
      _$WASPUpdateFromJson(json);

  Map<String, dynamic> toJson() => _$WASPUpdateToJson(this);
}
