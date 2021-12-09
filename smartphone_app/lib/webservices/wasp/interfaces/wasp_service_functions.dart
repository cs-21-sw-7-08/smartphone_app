import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class IWASPServiceFunctions {

  //region Municipality controller

  // Get
  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
  getListOfMunicipalities() async {
    throw UnimplementedError();
  }

  //endregion

  //region Issue controller

  // Get
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    throw UnimplementedError();
  }

  // Delete
  Future<WASPServiceResponse<WASPResponse>> deleteIssue(
      int issueId) async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>> getListOfIssues(
      {required IssuesOverviewFilter filter}) async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) async {
    throw UnimplementedError();
  }

  // Put
  Future<WASPServiceResponse<WASPResponse>> updateIssue(
      {required int issueId, required List<WASPUpdate> updates}) async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<WASPResponse>> reportIssue(
      {required int reportCategoryId, required int issueId}) async {
    throw UnimplementedError();
  }

  // Get
  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>>
      getListOfCategories() async {
    throw UnimplementedError();
  }

  // Get
  Future<WASPServiceResponse<GetListOfReportCategories_WASPResponse>>
      getListOfReportCategories() async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<WASPResponse>> createIssue(
      {required IssueCreateDTO issueCreateDTO}) async {
    throw UnimplementedError();
  }

  //endregion

  //region Citizen controller

  // Get
  Future<WASPServiceResponse<IsBlockedCitizen_WASPResponse>> isBlockedCitizen(
      {required int citizenId}) async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<Citizen_WASPResponse>> signUpCitizen(
      {required Citizen citizen}) async {
    throw UnimplementedError();
  }

  // Post
  Future<WASPServiceResponse<Citizen_WASPResponse>> logInCitizen(
      {required Citizen citizen}) async {
    throw UnimplementedError();
  }

  // Get
  Future<WASPServiceResponse<Citizen_WASPResponse>> getCitizen(
      {required int citizenId}) async {
    throw UnimplementedError();
  }

  // Delete
  Future<WASPServiceResponse<WASPResponse>> deleteCitizen(
      {required int citizenId}) async {
    throw UnimplementedError();
  }

  // Put
  Future<WASPServiceResponse<WASPResponse>> updateCitizen(
      {required int citizenId, required List<WASPUpdate> updates}) async {
    throw UnimplementedError();
  }

  //endregion
}
