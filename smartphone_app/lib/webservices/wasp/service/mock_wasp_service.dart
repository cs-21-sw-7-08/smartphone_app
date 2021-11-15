import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class MockWASPService extends WASPService {
  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  MockWASPService() : super(url: "");

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  Future<dynamic> getJsonData(String assetName) async {
    String jsonStr =
        await rootBundle.loadString('assets/mock_data/' + assetName);
    return await json.decode(jsonStr);
  }

  //endregion

  ///
  /// OVERRIDE METHODS
  ///
  //region Override methods

  @override
  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>> getListOfIssues(
      {required IssuesOverviewFilter filter}) async {
    return WASPServiceResponse.success(GetListOfIssues_WASPResponse.fromJson(
        await getJsonData("get_list_of_issues_response.json")));
  }

  @override
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    if (issueId % 2 == 0) {
      return WASPServiceResponse.success(GetIssueDetails_WASPResponse.fromJson(
          await getJsonData("get_issue_details_response.json")));
    } else {
      return WASPServiceResponse.success(GetIssueDetails_WASPResponse.fromJson(
          await getJsonData("get_issue_details_response_2.json")));
    }
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> updateIssue(
      {required int issueId, required List<WASPUpdate> updates}) {
    return Future.value(WASPServiceResponse.success(WASPResponse()));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) {
    return Future.value(WASPServiceResponse.success(WASPResponse()));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> reportIssue(
      {required int reportCategoryId, required int issueId}) {
    return Future.value(WASPServiceResponse.success(WASPResponse()));
  }

  @override
  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
      getListOfMunicipalities() async {
    return WASPServiceResponse.success(
        GetListOfMunicipalities_WASPResponse.fromJson(
            await getJsonData("get_list_of_municipalities_response.json")));
  }

  @override
  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>>
      getListOfCategories() async {
    return WASPServiceResponse.success(
        GetListOfCategories_WASPResponse.fromJson(
            await getJsonData("get_list_of_categories_response.json")));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> createIssue(
      {required int citizenId,
      required int municipalityId,
      required int subCategoryId,
      required String description,
      required Location location,
      String? picture1,
      String? picture2,
      String? picture3}) {
    return Future.value(WASPServiceResponse.success(WASPResponse()));
  }

//endregion

}
