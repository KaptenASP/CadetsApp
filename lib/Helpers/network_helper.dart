import 'package:http/http.dart' as http;
import '../Constants/cadetnet_api.dart';
import 'dart:convert';
import 'dart:async';

class CadetNetSession extends http.BaseClient {
  final http.Client _client = http.Client();
  final Set<String> _cookies = {};

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    // Set the user agent:
    request.headers['User-Agent'] =
        "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0";
    request.headers['Cookie'] = _cookies.toString().replaceAll(",", "");

    dynamic allHeaders = request.headers;
    dynamic requestBody;

    if (request.method == "POST") {
      requestBody = (request as http.Request).body;
    }

    // We will manually follow redirects:
    request.followRedirects = false;

    http.StreamedResponse response = await _client.send(request);

    // Save cookies from the response:
    if (response.headers['set-cookie'] != null) {
      List<String> setCookies = response.headers['set-cookie']!.split(',');

      _cookies.addAll(setCookies.map((e) {
        if (e.contains("Path")) {
          return e.split('Path')[0];
        }
        return e.split('path')[0];
      }));
    }

    // Manually follow the redirect requests:
    while (response.isRedirect || response.statusCode == 302) {
      if (response.headers['location'] == null) {
        break;
      }

      const baseUrl = "https://apps.cadetnet.gov.au";
      final location = response.headers['location'] ?? '';
      final newUrl = Uri.parse(baseUrl).resolve(location).toString();

      request = http.Request(request.method, Uri.parse(newUrl));

      // Update to new location
      request = http.Request(request.method, Uri.parse(newUrl));

      if (request.method == "POST") {
        request.body = requestBody;
      }

      if (request.method == 'Post') {}

      // Add headers:
      request.headers.addAll(allHeaders);
      request.headers['Cookie'] = _cookies.toString().replaceAll(",", "");

      request.headers['User-Agent'] =
          "Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:109.0) Gecko/20100101 Firefox/115.0";

      // Redirect manually
      request.followRedirects = false;
      response = await _client.send(request);

      // Save cookies from the redirected response
      if (response.headers['set-cookie'] != null) {
        List<String> setCookies = response.headers['set-cookie']!.split(',');

        _cookies.addAll(setCookies.map((e) {
          if (e.indexOf("secure") < e.indexOf("path")) {
            return e.split('secure')[0];
          }
          if (e.contains("Path")) {
            return e.split('Path')[0];
          }
          return e.split('path')[0];
        }));
      }
    }
    return response;
  }
}

class Session {
  static var client = CadetNetSession();
  static var api = CadetnetApi();

  // Auth based calls
  Future<void> getCookies() async {
    await client.get(
      Uri.parse(api.getBaseCookies.url),
      headers: api.getBaseCookies.headers,
    );

    await client.get(
      Uri.parse(api.getBaseCookies2.url),
      headers: api.getBaseCookies2.headers,
    );
  }

  Future<void> login() async {
    await client.post(
      Uri.parse(api.postLogin.url),
      body: api.postLogin.data,
      headers: api.postLogin.headers,
    );
  }

  // User based calls
  Future<Map> getDetails() async {
    http.Response response = await client.get(
      Uri.parse(api.getUserDetails.url),
      headers: api.getUserDetails.headers,
    );

    return json.decode(response.body);
  }

  Future<Map> getUserMapping() async {
    http.Response response = await client.post(
      Uri.parse(api.postUserMapping.url),
      headers: api.postUserMapping.headers,
      body: json.encode(api.postUserMapping.data),
    );

    return json.decode(response.body);
  }

  // Activity Based Calls
  Future<Map> getActivities() async {
    http.Response response = await client.post(
      Uri.parse(api.postActivities.url),
      headers: api.postActivities.headers,
      body: json.encode(api.postActivities.data),
    );

    return json.decode(response.body);
  }

  Future<Map> getActivityAttendees(APIPostRequest post) async {
    http.Response response = await client.post(
      Uri.parse(post.url),
      headers: post.headers,
      body: json.encode(post.data),
    );

    return json.decode(response.body);
  }
}
