import 'dart:async';
import 'dart:convert' show Encoding, jsonDecode, utf8;
import 'package:http/http.dart' as http;

class RestResponse {
  http.Response? response;
  dynamic jsonResponse;
  bool timeout;

  RestResponse({required this.response,
    required this.jsonResponse,
    this.timeout = false});

  RestResponse.timeout({this.timeout = true});

  String? get errorMessage {
    if (timeout) {
      return "HTTP error: Timeout";
    }
    if (response!.statusCode != 200) {
      return "HTTP error: " + response!.statusCode.toString();
    }
    return null;
  }

  bool get isSuccess {
    if (timeout) return false;
    if (response!.statusCode != 200) return false;
    return true;
  }
}

class RestParameter {
  String name;
  String value;

  RestParameter({required this.name, required this.value});
}

class RestHelper {
  ///
  /// VARIABLES
  ///
  //region Variables

  late String url;
  late int timeoutInSeconds;

  //endregion

  ///
  /// CONSTRUCTOR
  ///
  //region Constructor

  RestHelper({required this.url, this.timeoutInSeconds = 30});

  //endregion

  ///
  /// METHODS
  ///
  //region Methods

  _receivedResponse(http.Response response) {
    // Print request and response for debug purposes
    print("Response status: ${response.statusCode}");
    print("Response: ${response.body}");
  }

  _timeout() {
    print("Response: Timeout");
  }

  _getParametersString(List<RestParameter>? parameters) {
    if (parameters == null || parameters.isEmpty) return "";
    var tempString = "";
    for (var parameter in parameters) {
      tempString += tempString.isEmpty ? "?" : "&";
      tempString += "${parameter.name}=${parameter.value}";
    }
    return tempString;
  }

  Future<RestResponse> sendGetRequest(String function,
      {List<RestParameter>? parameters}) async {
    String urlComplete = url + function + _getParametersString(parameters);
    http.Response response;
    try {
      // Post request
      response = await http
          .get(
        Uri.parse(urlComplete),
        headers: {
          "Content-Type": "text/json;charset=UTF-8",
          "cache-control": "no-cache"
        },
      )
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    } on TimeoutException catch (_) {
      _timeout();
      return RestResponse.timeout();
    }

    // Check for HTTP error codes
    if (response.statusCode != 200) {
      // HTTP error code
      return RestResponse(response: response, jsonResponse: null);
    }

    // Decode JSON string
    var jsonDecoded = jsonDecode(response.body);
    // Return response with the underlying action objects
    return RestResponse(response: response, jsonResponse: jsonDecoded);
  }

  Future<RestResponse> sendPostRequest(String function,
      {List<RestParameter>? parameters, required String body}) async {
    String urlComplete = url + function + _getParametersString(parameters);
    // Make request
    var bodyString = utf8.encode(body);
    http.Response response;
    try {
      // Post request
      response = await http
          .post(Uri.parse(urlComplete),
          headers: {
            "Content-Type": "text/json;charset=UTF-8",
            "cache-control": "no-cache"
          },
          body: bodyString,
          encoding: Encoding.getByName("UTF-8"))
          .timeout(Duration(seconds: timeoutInSeconds))
          .then((onValue) {
        _receivedResponse(onValue);
        return onValue;
      });
    } on TimeoutException catch (_) {
      _timeout();
      return RestResponse.timeout();
    }

    // Check for HTTP error codes
    if (response.statusCode != 200 && response.statusCode != 202) {
      // HTTP error code
      return RestResponse(response: response, jsonResponse: null);
    }

    // Decode JSON string
    var jsonDecoded = jsonDecode(response.body);
    // Return response with the underlying action objects
    return RestResponse(response: response, jsonResponse: jsonDecoded);
  }

//endregion

}
