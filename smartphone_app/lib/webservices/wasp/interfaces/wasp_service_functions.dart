import 'package:smartphone_app/webservices/wasp/models/wasp_classes.dart';
import 'package:smartphone_app/webservices/wasp/service/wasp_service.dart';

class IWASPServiceFunctions {
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) async {
    throw UnimplementedError();
  }

  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>>
      getListOfIssues() async {
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

  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>>
  getListOfCategories() async {
    throw UnimplementedError();
  }
}
