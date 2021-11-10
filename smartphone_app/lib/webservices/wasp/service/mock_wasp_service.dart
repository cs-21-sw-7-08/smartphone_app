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
  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>>
      getListOfIssues() async {
    return WASPServiceResponse.success(GetListOfIssues_WASPResponse.fromJson(
        await getJsonData("get_list_of_issues_response.json")));
  }

  @override
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    return WASPServiceResponse.success(GetIssueDetails_WASPResponse.fromJson(
        await getJsonData("get_issue_details_response.json")));
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) {
    return Future.value(WASPServiceResponse.success(WASPResponse()));
  }

  @override
  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
      getListOfMunicipalities() async {
    return WASPServiceResponse.success(
        GetListOfMunicipalities_WASPResponse.fromJson(
            await getJsonData("get_list_of_municipalities_response.json")));
  }

//endregion

}
