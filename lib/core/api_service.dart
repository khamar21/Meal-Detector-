import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  
  static const String _deviceUrl = 'http://192.168.31.36:8000';

  static const Duration _timeout = Duration(seconds: 30);

  static String get baseUrl {
  
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) {
      return override;
    }

    // ✅ Always use device IP for real device
    return _deviceUrl;
  }

  /// Test if backend is reachable
  static Future<bool> testConnection() async {
    try {
      debugPrint('Testing connection to $baseUrl');

      final response = await http
          .get(Uri.parse('$baseUrl/'))
          .timeout(_timeout);

      final success = response.statusCode == 200;

      debugPrint(
        'Connection test: ${success ? 'OK' : 'FAILED (${response.statusCode})'}',
      );

      return success;
    } catch (e) {
      debugPrint('❌ Backend connection failed: $e');
      rethrow;
    }
  }

  /// Predict food from image file
  static Future<Map<String, dynamic>> predictFood(File image) async {
    debugPrint('📤 Uploading image to $baseUrl/predict');

    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/predict'),
      );

      request.files.add(
        await http.MultipartFile.fromPath('file', image.path),
      );

      final response = await request.send().timeout(_timeout);
      final res = await http.Response.fromStream(response);

      debugPrint('📥 Response: ${res.body}');

      if (res.statusCode != 200) {
        throw HttpException('Server error: ${res.statusCode}');
      }

      return jsonDecode(res.body);
    } on SocketException {
      throw HttpException('❌ Cannot connect to backend. Check IP & WiFi');
    } on TimeoutException {
      throw HttpException('❌ Request timeout');
    } catch (e) {
      rethrow;
    }
  }
}