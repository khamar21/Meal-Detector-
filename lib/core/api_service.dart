import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiService {
  static const Duration _timeout = Duration(seconds: 30);
  static const String _fallbackWifiUrl = 'http://192.168.31.36:8000';

  static String get baseUrl {
    const override = String.fromEnvironment('API_BASE_URL');
    if (override.isNotEmpty) return override;
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

  static Future<Map<String, dynamic>> predictFood(File image) {
    return _postMultipart(
      endpointCandidates: const ['/predict', '/food/predict', '/scan'],
      files: [image],
      fileFieldCandidates: const ['file'],
    );
  }

  static Future<List<Map<String, dynamic>>> predictFoodBatch(
    List<File> images,
  ) async {
    final body = await _postMultipart(
      endpointCandidates: const [
        '/predict/batch',
        '/batch-predict',
        '/predict-batch',
      ],
      files: images,
      fileFieldCandidates: const ['files', 'images', 'file'],
      extraFields: const {'batch_mode': 'true'},
    );

    final list = _extractList(body, const ['results', 'items', 'predictions']);
    if (list != null) {
      return list;
    }

    if (body.isNotEmpty) {
      return [body];
    }

    return const [];
  }

  static Future<Map<String, dynamic>> adjustPortion({
    required String foodName,
    required double multiplier,
    Map<String, dynamic>? prediction,
  }) async {
    return _postJson(
      endpointCandidates: const [
        '/portion-adjust',
        '/adjust-portion',
        '/predict/portion',
      ],
      payload: {
        'food': foodName,
        'food_name': foodName,
        'portion_multiplier': multiplier,
        'multiplier': multiplier,
        if (prediction != null) 'prediction': prediction,
      },
    );
  }

  static Future<List<Map<String, dynamic>>> healthierAlternatives(
    String foodName, {
    int limit = 5,
  }) async {
    final body = await _postJson(
      endpointCandidates: const [
        '/healthier-alternatives',
        '/alternatives',
        '/food/alternatives',
      ],
      payload: {'food': foodName, 'food_name': foodName, 'limit': limit},
    );

    final list = _extractList(body, const [
      'alternatives',
      'healthier_alternatives',
      'options',
      'results',
    ]);
    if (list != null) {
      return list;
    }

    if (body.isNotEmpty) {
      return [body];
    }

    return const [];
  }

  static Future<Map<String, dynamic>> predictFoodByText(String text) async {
    throw HttpException('Text endpoint is not available on current backend.');
  }

  static Future<Map<String, dynamic>> _postMultipart({
    required List<String> endpointCandidates,
    required List<File> files,
    required List<String> fileFieldCandidates,
    Map<String, String> extraFields = const {},
  }) async {
    SocketException? socketError;
    TimeoutException? timeoutError;

    for (final endpoint in endpointCandidates) {
      for (final fileFieldName in fileFieldCandidates) {
        try {
          final request = http.MultipartRequest(
            'POST',
            Uri.parse('$baseUrl$endpoint'),
          );
          request.fields.addAll(extraFields);

          for (final file in files) {
            request.files.add(
              await http.MultipartFile.fromPath(fileFieldName, file.path),
            );
          }

          final streamed = await request.send().timeout(_timeout);
          final response = await http.Response.fromStream(streamed);
          final body = _decodeBody(response.body);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            return body;
          }

          if (response.statusCode == 404 || response.statusCode == 405) {
            continue;
          }

          if (response.statusCode == 422 || response.statusCode == 400) {
            // Try the next multipart field name before failing hard.
            continue;
          }

          throw HttpException(_readErrorMessage(body, response.statusCode));
        } on SocketException catch (error) {
          socketError = error;
        } on TimeoutException catch (error) {
          timeoutError = error;
        }
      }
    }

    if (socketError != null) {
      throw HttpException(
        'Cannot connect to backend. Check the backend address and API_BASE_URL.',
      );
    }
    if (timeoutError != null) {
      throw HttpException('Request timeout.');
    }

    throw HttpException('Endpoint not available on backend.');
  }

  static Future<Map<String, dynamic>> _postJson({
    required List<String> endpointCandidates,
    required Map<String, dynamic> payload,
  }) async {
    SocketException? socketError;
    TimeoutException? timeoutError;

    for (final endpoint in endpointCandidates) {
      try {
        final response = await http
            .post(
              Uri.parse('$baseUrl$endpoint'),
              headers: const {'Content-Type': 'application/json'},
              body: jsonEncode(payload),
            )
            .timeout(_timeout);

        final body = _decodeBody(response.body);
        if (response.statusCode >= 200 && response.statusCode < 300) {
          return body;
        }

        if (response.statusCode == 404 || response.statusCode == 405) {
          continue;
        }

        throw HttpException(_readErrorMessage(body, response.statusCode));
      } on SocketException catch (error) {
        socketError = error;
      } on TimeoutException catch (error) {
        timeoutError = error;
      }
    }

    if (socketError != null) {
      throw HttpException(
        'Cannot connect to backend. Check the backend address and API_BASE_URL.',
      );
    }
    if (timeoutError != null) {
      throw HttpException('Request timeout.');
    }

    throw HttpException('Endpoint not available on backend.');
  }

  static Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return <String, dynamic>{};
    }

    final decoded = jsonDecode(body);
    if (decoded is Map<String, dynamic>) {
      return decoded;
    }

    if (decoded is Map) {
      return Map<String, dynamic>.from(decoded);
    }

    return <String, dynamic>{'data': decoded};
  }

  static List<Map<String, dynamic>>? _extractList(
    Map<String, dynamic> body,
    List<String> keys,
  ) {
    for (final key in keys) {
      final candidate = body[key];
      if (candidate is List) {
        return candidate
            .whereType<Map>()
            .map((item) => Map<String, dynamic>.from(item))
            .toList(growable: false);
      }
    }

    if (body['data'] is List) {
      return (body['data'] as List)
          .whereType<Map>()
          .map((item) => Map<String, dynamic>.from(item))
          .toList(growable: false);
    }

    return null;
  }

  static String _readErrorMessage(Map<String, dynamic> body, int statusCode) {
    final message = body['error'] ?? body['detail'] ?? body['message'];
    if (message != null && message.toString().trim().isNotEmpty) {
      return message.toString().trim();
    }

    return 'Server error: $statusCode';
  }
}
