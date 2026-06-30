import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  /// Base URL for auth/user REST endpoints (includes /api prefix).
  static String get baseUrl {
    const envBaseUrl = String.fromEnvironment('API_BASE_URL', defaultValue: '');
    if (envBaseUrl.isNotEmpty) {
      return envBaseUrl.endsWith('/api') ? envBaseUrl : '$envBaseUrl/api';
    }
    if (kIsWeb) return 'http://localhost:3000/api';
    return 'http://10.0.2.2:3000/api';
  }

  /// Base URL for ML/OCR endpoints (root path — no /api prefix).
  /// Locally the same server handles both: auth under /api/* and ML at root.
  /// For production deploy, pass:
  ///   --dart-define=ML_BASE_URL=https://tellie.pro
  static String get mlBaseUrl {
    const envUrl = String.fromEnvironment('ML_BASE_URL', defaultValue: '');
    if (envUrl.isNotEmpty) return envUrl;
    if (kIsWeb) return 'http://localhost:3000';
    return 'http://10.0.2.2:3000';
  }

  // ── SharedPreferences helpers ─────────────────────────────────────────────

  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  static Future<String?> getUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  static Future<String?> getUserName() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userName');
  }

  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null && token.isNotEmpty;
  }

  static Map<String, String> _headers([String? token]) => {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        if (token != null) 'Authorization': 'Bearer $token',
      };

  static Map<String, dynamic> _decodeBody(String body) {
    if (body.trim().isEmpty) {
      return {};
    }
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map<String, dynamic>) {
        return decoded;
      }
      if (decoded is Map) {
        return Map<String, dynamic>.from(decoded);
      }
    } catch (_) {}
    return {'message': body};
  }

  static Future<Map<String, dynamic>> _postJson(
      String path, Map<String, dynamic> body, [String? token]) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl$path'),
            headers: _headers(token),
            body: jsonEncode(body),
          )
          .timeout(const Duration(seconds: 10));
      final decodedBody = _decodeBody(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return {'statusCode': response.statusCode, ...decodedBody};
      }
      return {
        'statusCode': response.statusCode,
        'message': decodedBody['message'] ?? decodedBody['error'] ?? 'Request failed',
        'error': decodedBody['error'],
      };
    } on TimeoutException catch (_) {
      return {
        'statusCode': 0,
        'message': 'The request timed out. The server may be unavailable.',
      };
    } catch (e) {
      final msg = e.toString().toLowerCase();
      if (msg.contains('socketexception') ||
          msg.contains('err_name_not_resolved') ||
          msg.contains('failed host lookup') ||
          msg.contains('connection refused')) {
        return {
          'statusCode': 0,
          'message': 'Unable to reach the server. Start the backend and verify the API URL.',
        };
      }
      return {'statusCode': 0, 'message': 'Unexpected error: $e'};
    }
  }

  // ── Auth ──────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>> register(
      String name, String email, String password) async {
    return _postJson('/auth/register', {
      'name': name,
      'email': email,
      'password': password,
    });
  }

  static Future<Map<String, dynamic>> login(
      String email, String password) async {
    final response = await _postJson('/auth/login', {
      'email': email,
      'password': password,
    });
    if (response['statusCode'] == 200) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('token', response['token'] as String);
      await prefs.setString('userId', response['userId'] as String);
      await prefs.setString('userName', response['name'] as String);
      await prefs.setBool('voice', response['voice'] as bool? ?? false);
      await prefs.setString('language', response['language'] as String? ?? 'English');
    }
    return response;
  }

  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    await prefs.remove('userId');
    await prefs.remove('userName');
    await prefs.remove('voice');
    await prefs.remove('language');
  }

  // ── Users ─────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        final body = jsonDecode(response.body) as Map<String, dynamic>;
        // Cache locally
        final prefs = await SharedPreferences.getInstance();
        if (body['voice'] != null) await prefs.setBool('voice', body['voice'] as bool);
        if (body['language'] != null) {
          await prefs.setString('language', body['language'] as String);
        }
        if (body['name'] != null) {
          await prefs.setString('userName', body['name'] as String);
        }
        return body;
      }
    } catch (_) {}
    return null;
  }

  static Future<bool> updateUserSettings(String userId,
      {bool? voice, String? language, String? name}) async {
    try {
      final token = await getToken();
      final Map<String, dynamic> payload = {};
      if (voice != null) payload['voice'] = voice;
      if (language != null) payload['language'] = language;
      if (name != null) payload['name'] = name;

      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: _headers(token),
        body: jsonEncode(payload),
      );
      if (response.statusCode == 200) {
        final prefs = await SharedPreferences.getInstance();
        if (voice != null) await prefs.setBool('voice', voice);
        if (language != null) await prefs.setString('language', language);
        if (name != null) await prefs.setString('userName', name);
        return true;
      }
    } catch (_) {}
    return false;
  }

  // ── Audios ────────────────────────────────────────────────────────────────

  static Future<Map<String, dynamic>?> getAudioByDate(
      String userId, String date) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/audios/$userId/bydate/$date'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as Map<String, dynamic>;
      }
    } catch (_) {}
    return null;
  }

  static Future<void> ensureAudioDateExists(String userId, String date) async {
    try {
      final token = await getToken();
      await http.post(
        Uri.parse('$baseUrl/audios/$userId/bydate/$date'),
        headers: _headers(token),
      );
    } catch (_) {}
  }

  static Future<List<dynamic>> getAllAudioDates(String userId) async {
    try {
      final token = await getToken();
      final response = await http.get(
        Uri.parse('$baseUrl/audios/$userId/bydate'),
        headers: _headers(token),
      );
      if (response.statusCode == 200) {
        return jsonDecode(response.body) as List<dynamic>;
      }
    } catch (_) {}
    return [];
  }

  static Future<bool> addAudioUrl(
      String userId, String date, String url) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/audios/$userId/bydate/$date/addurl'),
        headers: _headers(token),
        body: jsonEncode({'url': url}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> removeAudioUrl(
      String userId, String date, String url) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/audios/$userId/bydate/$date/removeurl'),
        headers: _headers(token),
        body: jsonEncode({'url': url}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> updateAudioTitle(
      String userId, String date, String title) async {
    try {
      final token = await getToken();
      final response = await http.put(
        Uri.parse('$baseUrl/audios/$userId/bydate/$date/title'),
        headers: _headers(token),
        body: jsonEncode({'title': title}),
      );
      return response.statusCode == 200;
    } catch (_) {
      return false;
    }
  }
}
