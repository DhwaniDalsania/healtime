import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

class ApiService {
  static const String baseUrl =
      'https://healtime-production.up.railway.app/api';

  static Future<Map<String, dynamic>?> post(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final url = Uri.parse('$baseUrl$endpoint');
      debugPrint('POST Request: $url - Body: ${jsonEncode(data)}');

      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(data),
      );

      debugPrint('POST Response Status: ${response.statusCode}');
      debugPrint('POST Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty || response.body == 'null') return {};
        try {
          return jsonDecode(response.body) as Map<String, dynamic>;
        } catch (e) {
          debugPrint('JSON Decode Error: $e');
          return {};
        }
      } else {
        debugPrint('POST Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('POST Exception: $e');
      return null;
    }
  }

  static Future<dynamic> get(
    String endpoint, {
    Map<String, String>? queryParams,
  }) async {
    try {
      final uri = Uri.parse(
        '$baseUrl$endpoint',
      ).replace(queryParameters: queryParams);
      final response = await http.get(uri);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (response.body.isEmpty) return null;
        return jsonDecode(response.body);
      } else {
        throw Exception(
          'Server Error: ${response.statusCode} - ${response.body}',
        );
      }
    } catch (e) {
      debugPrint('GET Exception: $e');
      rethrow;
    }
  }

  static Future<List<dynamic>> getDoctors() async {
    return await get('/doctors');
  }

  static Future<Map<String, dynamic>?> getDoctorDetails(String id) async {
    return await get('/doctors/$id');
  }

  static Future<List<dynamic>> getUpcomingAppointments(String userId) async {
    return await get(
      '/appointments',
      queryParams: {'userId': userId, 'role': 'patient'},
    );
  }

  static Future<List<dynamic>> getDoctorSchedule(String doctorId) async {
    return await get(
      '/appointments',
      queryParams: {'userId': doctorId, 'role': 'doctor'},
    );
  }

  static Future<Map<String, dynamic>?> getAppointmentDetails(String id) async {
    return await get('/appointments/$id');
  }

  static Future<List<dynamic>> getRecords(String userId) async {
    return await get('/records', queryParams: {'userId': userId});
  }

  static Future<Map<String, dynamic>?> updateAvailability(
    String doctorId,
    Map<String, dynamic> data,
  ) async {
    return await updateUser(doctorId, data);
  }

  static Future<Map<String, dynamic>?> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/users/$userId'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('PUT Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('PUT Exception: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getMessages(
    String userId1,
    String userId2,
  ) async {
    return await get('/messages/$userId1/$userId2');
  }

  static Future<Map<String, dynamic>?> sendMessage(
    String senderId,
    String receiverId,
    String content,
  ) async {
    return await post('/messages', {
      'senderId': senderId,
      'receiverId': receiverId,
      'content': content,
    });
  }

  static Future<Map<String, dynamic>?> addRecordWithFile({
    required String patientId,
    required String doctorId,
    required String doctorName,
    required String date,
    required String diagnosis,
    required String prescription,
    Uint8List? fileBytes,
    String? fileName,
  }) async {
    try {
      final url = Uri.parse('$baseUrl/records');
      final request = http.MultipartRequest('POST', url);

      request.fields['patientId'] = patientId;
      request.fields['doctorId'] = doctorId;
      request.fields['doctorName'] = doctorName;
      request.fields['date'] = date;
      request.fields['diagnosis'] = diagnosis;
      request.fields['prescription'] = prescription;

      if (fileBytes != null && fileName != null && fileName.isNotEmpty) {
        request.files.add(
          http.MultipartFile.fromBytes('file', fileBytes, filename: fileName),
        );
      }

      debugPrint('POST Multipart Request: $url');
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      debugPrint('POST Multipart Response Status: ${response.statusCode}');
      debugPrint('POST Multipart Response Body: ${response.body}');

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return jsonDecode(response.body);
      } else {
        return null;
      }
    } catch (e) {
      debugPrint('Multipart POST Exception: $e');
      return null;
    }
  }

  static Future<List<dynamic>> getChatContacts(String userId) async {
    return await get('/messages/contacts/$userId');
  }

  static Future<Map<String, dynamic>?> patch(
    String endpoint,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await http.patch(
        Uri.parse('$baseUrl$endpoint'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(data),
      );

      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        debugPrint('PATCH Error: ${response.statusCode} - ${response.body}');
        return null;
      }
    } catch (e) {
      debugPrint('PATCH Exception: $e');
      return null;
    }
  }

  static Future<bool> delete(String endpoint) async {
    try {
      final response = await http.delete(Uri.parse('$baseUrl$endpoint'));
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return true;
      }
      debugPrint('DELETE Error: ${response.statusCode} - ${response.body}');
      return false;
    } catch (e) {
      debugPrint('DELETE Exception: $e');
      return false;
    }
  }
}
