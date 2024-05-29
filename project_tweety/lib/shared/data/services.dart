import 'dart:convert' as convert;
import 'dart:convert';

import 'package:http/http.dart' as http;

/// TODO:
/// Input Validation
/// Logging (dev purposes and to sentry.io/Firebase)
/// Tests
/// Modularization
/// Security (?)

// Note: Created entirely using DuckDuckGo AI Chat - GPT-3.5 Turbo model
class Services {
  final String _baseUrl = "www.my-base-path.co.za";

  // CREATE
  /// Creates data by sending a POST request to the specified URL.
  ///
  /// [url]: The URL to send the POST request to.
  /// [body]: The data to include in the request body.
  void createData(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Encoding? encoding,
  }) async {
    try {
      var response = await sendHttpRequest('DELETE', path,
          headers: headers, body: body, encoding: encoding);

      if (response.statusCode == 201) {
        print('Data created successfully');
      } else {
        throw Exception('Failed to POST data. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to POST data. Error: $e');
    }
  }

  // READ
  /// Fetches data from the specified URL using a GET request.
  ///
  /// [url]: The URL to fetch data from.
  Future<Map<String, dynamic>> fetchData(
    String path, {
    Map<String, String>? headers,
  }) async {
    try {
      var response = await sendHttpRequest('GET', path, headers: headers);

      if (response.statusCode == 200) {
        return _decodeJsonData(response.body);
      } else {
        throw Exception('Failed to GET data. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to POST data. Error: $e');
    }
  }

  // UPDATE
  /// Updates data by sending a PUT request to the specified URL.
  ///
  /// [url]: The URL to send the PUT request to.
  /// [body]: The data to include in the request body.
  void updateData(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Encoding? encoding,
  }) async {
    try {
      var response = await sendHttpRequest('PUT', path,
          headers: headers, body: body, encoding: encoding);

      if (response.statusCode == 200) {
        print('Data updated successfully');
      } else {
        throw Exception('Failed to PUT data. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to POST data. Error: $e');
    }
  }

  // DELETE
  /// Deletes data by sending a DELETE request to the specified URL.
  ///
  /// [url]: The URL to send the DELETE request to.
  void deleteData(
    String path, {
    Map<String, String>? headers,
    Map<String, String>? body,
    Encoding? encoding,
  }) async {
    try {
      var response = await sendHttpRequest('DELETE', path,
          headers: headers, body: body, encoding: encoding);

      if (response.statusCode == 204) {
        print('Data deleted successfully');
      } else {
        throw Exception('Failed to DELETE data. Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Failed to POST data. Error: $e');
    }
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
    Map<String, String>? body,
    Map<String, String>? headers,
    Encoding? encoding,
  }) async {
    final url = Uri.https(_baseUrl + path);

    switch (method) {
      case 'POST':
        return await http.post(url,
            headers: headers, body: body, encoding: encoding);
      case 'GET':
        return await http.get(url, headers: headers);
      case 'PUT':
        return await http.put(url,
            headers: headers, body: body, encoding: encoding);
      case 'DELETE':
        return await http.delete(url,
            headers: headers, body: body, encoding: encoding);
      default:
        throw Exception('Invalid HTTP method');
    }
  }

  Map<String, dynamic> _decodeJsonData(String data) =>
      convert.jsonDecode(data) as Map<String, dynamic>;

//endregion
}
