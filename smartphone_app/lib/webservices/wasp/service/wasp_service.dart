import 'package:smartphone_app/helpers/rest_helper.dart';
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
  //region Override methods

  @override
  Future<WASPServiceResponse<GetIssueDetails_WASPResponse>> getIssueDetails(
      int issueId) {
    // TODO: implement getIssueDetails
    throw UnimplementedError();
  }

  @override
  Future<WASPServiceResponse<GetListOfIssues_WASPResponse>> getListOfIssues() {
    throw UnimplementedError();
  }

  @override
  Future<WASPServiceResponse<WASPResponse>> verifyIssue(
      {required int citizenId, required int issueId}) {
    // TODO: implement verifyIssue
    throw UnimplementedError();
  }

  @override
  Future<WASPServiceResponse<GetListOfMunicipalities_WASPResponse>>
      getListOfMunicipalities() {
    // TODO: implement getListOfMunicipalities
    throw UnimplementedError();
  }

  @override
  Future<WASPServiceResponse<GetListOfCategories_WASPResponse>> getListOfCategories() {
    // TODO: implement getListOfCategories
    throw UnimplementedError();
  }

//endregion

}
