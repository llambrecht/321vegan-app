import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  static Future<String?> toFrench(String text) async {
    try {
      final uri = Uri.parse(
        'https://translate.googleapis.com/translate_a/single'
        '?client=gtx&sl=auto&tl=fr&dt=t&q=${Uri.encodeComponent(text)}',
      );
      final response = await http
          .get(uri, headers: {'User-Agent': '321Vegan - Flutter App'})
          .timeout(const Duration(seconds: 10));
      final data = jsonDecode(response.body) as List<dynamic>;
      return (data[0] as List<dynamic>)
          .map((part) => (part as List<dynamic>)[0] as String? ?? '')
          .join();
    } catch (_) {
      return null;
    }
  }
}
