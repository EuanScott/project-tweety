import 'dart:convert' as convert;
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

/// TODO:
/// Logging (dev purposes and to sentry.io/Firebase) - Put this rather in the code itself. This file should only be for making the service call. This way it can more easily be modularized if/when required.
/// Tests
/// Modularization
/// Security (?)

/// A class that provides various HTTP services.
///
/// This class provides methods for sending HTTP requests, including GET, POST, PUT, and DELETE.
/// It also includes helper methods for sending HTTP requests and decoding JSON data.
///
/// Note: Created entirely using DuckDuckGo AI Chat (GPT-3.5 Turbo model) && Github Co-pilot
class Services {
  // TODO: When I get around to using this, make this configurable. Either from a build config, or if running tests, by using whatever I have set in code
  final String _baseUrl = "https://jsonplaceholder.typicode.com";

  /// Creates data by sending a POST request to the specified URL.
  ///
  /// [url]: The URL to send the POST request to.
  /// [body]: The data to include in the request body.
  Future<Map<String, dynamic>> postData(
    String path, {
    Map<String, String>? headers,
    required Map<String, dynamic> body,
    Encoding? encoding,
  }) async {
    var response = await sendHttpRequest(
      'POST',
      path,
      headers: headers,
      body: body,
      encoding: encoding,
    );

    if (response.statusCode != 201) {
      throw Exception('Failed to POST data. Error: ${response.statusCode}');
    }
    return _decodeJsonData(response.body);
  }

  /// Fetches data from the specified URL using a GET request.
  ///
  /// [url]: The URL to fetch data from.
  ///
  /// Returns either a Map<String, dynamic> representation of the JSON data or a List<Map<String, dynamic>> if the response is an array.
  Future<dynamic> getData(
    String path, {
    Map<String, String>? headers,
  }) async {
    var response = await sendHttpRequest('GET', path, headers: headers);

    if (response.statusCode != 200) {
      throw Exception('Failed to GET data. Error: ${response.statusCode}');
    }
    return _decodeJsonData(response.body);
  }

  /// Updates data by sending a PUT request to the specified URL.
  ///
  /// [url]: The URL to send the PUT request to.
  /// [body]: The data to include in the request body.
  Future<Map<String, dynamic>> putData(
    String path, {
    Map<String, String>? headers,
    required Map<String, dynamic> body,
    Encoding? encoding,
  }) async {
    var response = await sendHttpRequest('PUT', path,
        headers: headers, body: body, encoding: encoding);

    if (response.statusCode != 200) {
      throw Exception('Failed to PUT data. Error: ${response.statusCode}');
    }
    return _decodeJsonData(response.body);
  }

  /// Deletes data by sending a DELETE request to the specified URL.
  ///
  /// [url]: The URL to send the DELETE request to.
  Future<Map<String, dynamic>> deleteData(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Encoding? encoding,
  }) async {
    var response = await sendHttpRequest('DELETE', path,
        headers: headers, body: body, encoding: encoding);

    if (response.statusCode != 200) {
      throw Exception('Failed to DELETE data. Error: ${response.statusCode}');
    }
    return _decodeJsonData(response.body);
  }

  //region Helpers

  /// Sends an HTTP request based on the specified method.
  ///
  /// [method]: The HTTP method to use (GET, POST, PUT, DELETE).
  /// [baseUrl]: The base URL of the API.
  /// [path]: The path to the specific endpoint.
  /// [body]: The request body data (if applicable).
  /// [headers]: The request headers (if applicable).
  /// [encoding]: The encoding to use for the request body.
  ///
  /// Returns a [http.Response] object representing the response from the server.
  Future<http.Response> sendHttpRequest(
    String method,
    String path, {
    Map<String, dynamic>? body,
    Map<String, String>? headers,
    Encoding? encoding = utf8,
  }) async {
    // TODO: See about setting default headers here

    final url = Uri.parse(_baseUrl + path);
    String? encodedBody;
    if (body != null) {
      encodedBody = _encodeJsonData(body);
    }

    if (kDebugMode) {
      print('Sending $method request to $url');
    }

    switch (method) {
      case 'POST':
        return await http.post(url,
            headers: headers, body: encodedBody, encoding: encoding);
      case 'GET':
        return await http.get(url, headers: headers);
      case 'PUT':
        return await http.put(url,
            headers: headers, body: encodedBody, encoding: encoding);
      case 'DELETE':
        return await http.delete(url,
            headers: headers, body: encodedBody, encoding: encoding);
      default:
        throw Exception('Invalid HTTP method');
    }
  }

  /// Decodes a JSON string into a dynamic data structure.
  ///
  /// This method takes a JSON string as input and uses the `jsonDecode` function
  /// from the `dart:convert` library to convert the JSON string into a dynamic data structure.
  /// The structure could be a `Map<String, dynamic>` for JSON objects or a `List<dynamic>`
  /// for JSON arrays, depending on the structure of the input JSON string.
  ///
  /// [data] A JSON string to be decoded.
  ///
  /// Returns a dynamic representation of the decoded JSON string.
  dynamic _decodeJsonData(String data) => convert.jsonDecode(data);

  /// Encodes a [Map<String, dynamic>] into a JSON string.
  ///
  /// This method takes a map containing data that you want to encode into a JSON string.
  /// It uses the `jsonEncode` function from the `dart:convert` library to perform the encoding.
  ///
  /// [data] The map data to be encoded.
  ///
  /// Returns a JSON string representation of [data].
  _encodeJsonData(Map<String, dynamic> data) => convert.jsonEncode(data);

//endregion
}
