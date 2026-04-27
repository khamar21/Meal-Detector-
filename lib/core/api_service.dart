import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  static const String _fallbackWifiUrl = 'http://192.168.31.37:8000';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
    // Default to the LAN backend so physical devices can connect without adb reverse.
    return _fallbackWifiUrl;
  }

  static Future<bool> testConnection() async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/')).timeout(_timeout);
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> predictFood(File image) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(await http.MultipartFile.fromPath('file', image.path));

      final streamed = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(streamed);

      final body = res.body.isNotEmpty
          ? Map<String, dynamic>.from(jsonDecode(res.body))
          : <String, dynamic>{};

      if (res.statusCode != 200) {
        final msg =
            (body['error'] ??
                    body['detail'] ??
                    'Server error: ${res.statusCode}')
                .toString();
        throw HttpException(msg);
      }

      return body;
    } on SocketException {
      throw HttpException(
        'Cannot connect to backend. Check backend run and API_BASE_URL value.',
      );
    } on TimeoutException {
      throw HttpException('Request timeout.');
    }
  }

  static Future<Map<String, dynamic>> predictFoodByText(String text) async {
    throw HttpException('Text endpoint is not available on current backend.');
  }
}
