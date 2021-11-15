import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class IWASPServiceFunctions {
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>> getListOfIssues(
      {required IssuesOverviewFilter filter}) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
      getListOfMunicipalities() async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<WASPResponse>> updateIssue(
      {required int issueId, required List<WASPUpdate> updates}) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<WASPResponse>> reportIssue(
      {required int reportCategoryId, required int issueId}) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>>
      getListOfCategories() async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<WASPResponse>> createIssue({
      required int citizenId,
      required int municipalityId,
      required int subCategoryId,
      required String description,
      required Location location,
      String? picture1,
      String? picture2,
      String? picture3}) async {
    throw UnimplementedError();
  }
}
