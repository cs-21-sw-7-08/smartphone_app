import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:smartphone_app/helpers/rest_helper.dart';
import 'package:smartphone_app/utilities/wasp_util.dart';
import '../interfaces/wasp_service_functions.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';

class WASPServiceResponse<Response extends WASPResponse> {
  String? exception;
  Response? waspResponse;

  WASPServiceResponse.error(this.exception) {
    waspResponse = null;
  }

  WASPServiceResponse.success(this.waspResponse) {
    exception = null;
  }

  bool get isSuccess {
    if (exception != null) return false;
    return waspResponse!.isSuccessful;
  }

  String? get errorMessage {
    if (exception != null) return exception;
    if (waspResponse != null) return waspResponse!.getErrorMessage();
    return null;
  }
}

class WASPService implements IWASPServiceFunctions {
  ///
  /// STATIC
  ///
  //region Static

  static IWASPServiceFunctions? _waspServiceFunctions;

  static init(IWASPServiceFunctions waspServiceFunctions) {
    _waspServiceFunctions = waspServiceFunctions;
  }

  static IWASPServiceFunctions getInstance() {
    return _waspServiceFunctions!;
  }

  static const String issueControllerPath = "/WASP/Issues/";
  static const String municipalityControllerPath = "/WASP/Municipality/";
  static const String citizenControllerPath = "/WASP/Citizen/";

  //endregion

  ///
  /// VARIABLES
  ///
  //region Variables

  late String url;
  late RestHelper restHelper;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  WASPService({required this.url}) {
    restHelper = RestHelper(url: url);
  }

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<WASPServiceResponse<T>> actionCall<T extends WASPResponse>(
      Future<RestResponse> Function() callAction,
      T Function(RestResponse) getSuccess) async {
    RestResponse response = await callAction();
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    return WASPServiceResponse.success(getSuccess(response));
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  //region Issue controller

  @override
  Future<WASPServiceResponse<WASPResponse>> deleteIssue(int issueId) {
    return actionCall(() {
      return restHelper.sendDeleteRequest("${issueControllerPath}DeleteIssue",
          parameters: [
            RestParameter(name: "issueId", value: issueId.toString())
          ],
          body: null);
    }, (response) => WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    return actionCall(() {
      return restHelper.sendGetRequest("${issueControllerPath}GetIssueDetails",
          parameters: [
            RestParameter(name: "issueId", value: issueId.toString())
          ]);
    },
        (response) =>
            GetIssueDetails_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>> getListOfIssues(
      {required IssuesOverviewFilter filter}) async {
    String jsonFilter = WASPUtil.encodeToJson(filter.toJson());
    print("Filter: $jsonFilter"); // ignore: avoid_print

    return actionCall(() {
      return restHelper.sendPostRequest("${issueControllerPath}GetListOfIssues",
          body: jsonFilter);
    },
        (response) =>
            GetListOfIssues_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) async {
    RestResponse response =
        await restHelper.sendPostRequest("${issueControllerPath}VerifyIssue",
            parameters: [
              RestParameter(name: "issueId", value: issueId.toString()),
              RestParameter(name: "citizenId", value: citizenId.toString())
            ],
            body: null);
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>>
      getListOfCategories() async {
    RestResponse response = await restHelper
        .sendGetRequest("${issueControllerPath}GetListOfCategories");
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        GetListOfCategories_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> createIssue(
      {required IssueCreateDTO issueCreateDTO}) async {
    String jsonIssueCreateDTO = WASPUtil.encodeToJson(issueCreateDTO.toJson());
    print("IssueCreateDTO: $jsonIssueCreateDTO"); // ignore: avoid_print
    RestResponse response = await restHelper.sendPostRequest(
        "${issueControllerPath}CreateIssue",
        body: jsonIssueCreateDTO);
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> reportIssue(
      {required int reportCategoryId, required int issueId}) async {
    RestResponse response =
        await restHelper.sendPostRequest("${issueControllerPath}ReportIssue",
            parameters: [
              RestParameter(name: "issueId", value: issueId.toString()),
              RestParameter(
                  name: "reportCategoryId", value: reportCategoryId.toString())
            ],
            body: null);
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> updateIssue(
      {required int issueId, required List<WASPUpdate> updates}) async {
    var jsonString = jsonEncode(
        updates.map((e) => WASPUtil.removeNullValues(e.toJson())).toList());
    print("WASP Updates: $jsonString"); // ignore: avoid_print
    RestResponse response = await restHelper.sendPostRequest(
        "${issueControllerPath}UpdateIssue",
        parameters: [RestParameter(name: "issueId", value: issueId.toString())],
        body: jsonString);
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<GetListOfReportCategories_WASPResponse>>
      getListOfReportCategories() async {
    RestResponse response = await restHelper
        .sendGetRequest("${issueControllerPath}GetListOfReportCategories");
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        GetListOfReportCategories_WASPResponse.fromJson(response.jsonResponse));
  }

  //endregion

  //region Municipality controller

  @override
  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
      getListOfMunicipalities() async {
    RestResponse response = await restHelper
        .sendGetRequest("${municipalityControllerPath}GetListOfMunicipalities");
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        GetListOfMunicipalities_WASPResponse.fromJson(response.jsonResponse));
  }

  //endregion

  //region Citizen controller

  @override
  Future<WASPServiceResponse<WASPResponse>> deleteCitizen(
      {required int citizenId}) async {
    return actionCall(() {
      return restHelper.sendDeleteRequest(
          "${citizenControllerPath}DeleteCitizen",
          body: null,
          parameters: [
            RestParameter(name: "citizenId", value: citizenId.toString())
          ]);
    }, (response) => WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<Citizen_WASPResponse>> logInCitizen(
      {required Citizen citizen}) {
    String jsonCitizen = WASPUtil.encodeToJson(citizen.toJson());
    print("Citizen: $jsonCitizen"); // ignore: avoid_print

    return actionCall(() {
      return restHelper.sendPostRequest("${citizenControllerPath}LogInCitizen",
          body: jsonCitizen);
    }, (response) => Citizen_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<Citizen_WASPResponse>> signUpCitizen(
      {required Citizen citizen}) async {
    String jsonCitizen = WASPUtil.encodeToJson(citizen.toJson());
    print("Citizen: $jsonCitizen"); // ignore: avoid_print
    RestResponse response = await restHelper.sendPostRequest(
        "${citizenControllerPath}SignUpCitizen",
        body: jsonCitizen);
    // Check for HTTP errors
    if (!response.isSuccess) {
      return WASPServiceResponse.error(response.errorMessage);
    }
    // Return response
    return WASPServiceResponse.success(
        Citizen_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<IsBlockedCitizen_WASPResponse>> isBlockedCitizen(
      {required int citizenId}) {
    return actionCall(() {
      return restHelper.sendGetRequest(
          "${citizenControllerPath}IsBlockedCitizen",
          parameters: [
            RestParameter(name: "citizenId", value: citizenId.toString())
          ]);
    },
        (response) =>
            IsBlockedCitizen_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<Citizen_WASPResponse>> getCitizen(
      {required int citizenId}) {
    return actionCall(() {
      return restHelper.sendGetRequest("${citizenControllerPath}GetCitizen",
          parameters: [
            RestParameter(name: "citizenId", value: citizenId.toString())
          ]);
    }, (response) => Citizen_WASPResponse.fromJson(response.jsonResponse));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> updateCitizen(
      {required int citizenId, required List<WASPUpdate> updates}) async {
    var jsonString = jsonEncode(
        updates.map((e) => WASPUtil.removeNullValues(e.toJson())).toList());
    print("WASP Updates: $jsonString"); // ignore: avoid_print
    return actionCall(() {
      return restHelper.sendPutRequest("${citizenControllerPath}UpdateCitizen",
          parameters: [
            RestParameter(name: "citizenId", value: citizenId.toString())
          ],
          body: jsonString);
    }, (response) => WASPResponse.fromJson(response.jsonResponse));
  }

//endregion

//endregion

}
