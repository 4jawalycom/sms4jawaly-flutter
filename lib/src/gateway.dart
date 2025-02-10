import 'dart:convert';
import 'package:http/http.dart' as http;

class Gateway {
  static const String _apiBaseUrl = 'https://api-sms.4jawaly.com/api/v1';
  static const String _appType = 'flutter';
  static const String _appVersion = '1.0.0';
  final String _apiKey;
  final String _apiSecret;
  final http.Client _client;

  Gateway({
    required String apiKey,
    required String apiSecret,
  })  : _apiKey = apiKey,
        _apiSecret = apiSecret,
        _client = http.Client();

  Map<String, String> get _headers => {
        'Authorization':
            'Basic ${base64Encode(utf8.encode('${_apiKey}:${_apiSecret}'))}',
        'Accept': 'application/json',
        'Content-Type': 'application/json',
      };

  /// Get account balance
  Future<Map<String, dynamic>> getBalance() async {
    try {
      final response = await _client.get(
        Uri.parse('$_apiBaseUrl/account/area/me/packages')
            .replace(queryParameters: {
          'is_active': '1',
          'p_type': '1',
        }),
        headers: _headers,
      );

      return {
        'success': true,
        'data': jsonDecode(response.body),
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Get sender names
  Future<Map<String, dynamic>> getSenders() async {
    try {
      final allSenders = <String>[];
      final defaultSenders = <String>[];
      var page = 1;

      do {
        final response = await _client.get(
          Uri.parse('$_apiBaseUrl/account/area/senders')
              .replace(queryParameters: {
                'page': page.toString(),
                'return_collection': '1',
              }),
          headers: _headers,
        );

        final data = jsonDecode(response.body);
        final items = data['items'];

        for (final item in items['data']) {
          final senderName = item['sender_name'];
          allSenders.add(senderName);
          if (item['is_default'] == 1) {
            defaultSenders.add(senderName);
          }
        }

        page++;
      } while (page <= items['last_page']);

      return {
        'success': true,
        'all_senders': allSenders,
        'default_senders': defaultSenders,
        'message': 'تم',
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Send SMS messages
  Future<Map<String, dynamic>> sendSms({
    required String message,
    required List<String> numbers,
    required String sender,
  }) async {
    final result = {
      'success': true,
      'total_success': 0,
      'total_failed': 0,
      'job_ids': <String>[],
      'errors': <String, List<String>>{},
    };

    try {
      final response = await _client.post(
        Uri.parse('$_apiBaseUrl/account/area/sms/send'),
        headers: _headers,
        body: jsonEncode({
          'app': _appType,
          'ver': _appVersion,
          'messages': [
            {
              'text': message,
              'numbers': numbers,
              'sender': sender,
            }
          ],
        }),
      );

      final data = jsonDecode(response.body);
      result['total_success'] = numbers.length;
      if (data['job_id'] != null) {
        (result['job_ids'] as List<String>).add(data['job_id']);
      }
    } catch (e) {
      result['success'] = false;
      result['total_failed'] = numbers.length;
      (result['errors'] as Map<String, List<String>>)[e.toString()] = numbers;
    }

    return result;
  }

  /// Dispose the HTTP client when done
  void dispose() {
    _client.close();
  }
}
