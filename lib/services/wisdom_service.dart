import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;

// A simple class to hold our data uniformly
class WisdomItem {
  final String text;
  final String source; // e.g., "Marcus Aurelius" or "John 3:16"
  final String type; // "quote", "bible", or "tip"

  WisdomItem({required this.text, required this.source, required this.type});
}

class WisdomService {
  // 1. Fetch from Stoic/Inspirational API
  Future<WisdomItem> _getQuote() async {
    try {
      // Using a free API (ZenQuotes)
      final response = await http.get(
        Uri.parse('https://zenquotes.io/api/random'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body); // It returns a list
        return WisdomItem(
          text: data[0]['q'], // 'q' is the quote text
          source: data[0]['a'], // 'a' is the author
          type: 'Stoic/Inspirational',
        );
      } else {
        throw Exception('Failed to load quote');
      }
    } catch (e) {
      // Fallback if API fails (so app doesn't crash)
      return WisdomItem(
        text: "The obstacle is the way.",
        source: "Ryan Holiday",
        type: "Stoic",
      );
    }
  }

  // 2. Fetch from Bible API
  Future<WisdomItem> _getBibleVerse() async {
    try {
      // Using Bible-API.com for a random verse
      final response = await http.get(
        Uri.parse('https://bible-api.com/?random=verse'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return WisdomItem(
          text: data['text'].toString().trim(),
          source: "${data['reference']}", // e.g. John 3:16
          type: 'Bible Verse',
        );
      } else {
        throw Exception('Failed to load verse');
      }
    } catch (e) {
      return WisdomItem(
        text: "Be strong and courageous.",
        source: "Joshua 1:9",
        type: "Bible",
      );
    }
  }

  // 3. The "Brain" - Randomly picks one
  Future<WisdomItem> shakeTheJar() async {
    final random = Random();
    // Generate a number: 0 or 1
    // (We will add the 'User Tip' database logic later as #3)
    int pick = random.nextInt(2);

    if (pick == 0) {
      return await _getQuote();
    } else {
      return await _getBibleVerse();
    }
  }
}
