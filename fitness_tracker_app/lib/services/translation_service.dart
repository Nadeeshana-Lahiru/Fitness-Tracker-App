import 'dart:convert';
import 'package:http/http.dart' as http;

class TranslationService {
  // Mock translations for demonstration if API fails or not provided
  static final Map<String, Map<String, String>> _staticTranslations = {
    'Sinhala': {
      'Settings': 'සැකසුම්',
      'Daily Goals': 'දිනපතා ඉලක්ක',
      'Step Goal': 'පියවර ඉලක්කය',
      'Calorie Burn Goal': 'කැලරි දහන ඉලක්කය',
      'Water Goal': 'ජල ඉලක්කය',
      'Active Minutes Goal': 'සක්‍රිය මිනිත්තු ඉලක්කය',
      'Notifications': 'දැනුම්දීම්',
      'Workout Reminder': 'ව්‍යායාම මතක් කිරීම',
      'Water Reminders': 'ජල මතක් කිරීම්',
      'Preferences': 'මනාප',
      'Language': 'භාෂාව',
      'Theme': 'තේමාව',
      'Units': 'ඒකක',
      'About': 'පිළිබඳ',
      'Logout': 'පිටවීම',
      'Good Morning ☀️': 'සුභ උදෑසනක් ☀️',
      'Good Afternoon 🌤️': 'සුභ දහවලක් 🌤️',
      'Good Evening 🌙': 'සුභ සන්ධ්‍යාවක් 🌙',
      'Today\'s Goals': 'අද ඉලක්ක',
      'Calories': 'කැලරි',
      'Steps': 'පියවර',
      'Water': 'ජලය',
      'Active': 'සක්‍රිය',
      'Quick Add Water': 'ඉක්මනින් ජලය එක් කරන්න',
      'Exercise Type': 'ව්‍යායාම වර්ගය',
      'Sleep': 'නිදාගැනීම',
      'Recent Activity': 'මෑත කාලීන ක්‍රියාකාරකම්',
      'Total Sleep': 'මුළු නින්ද',
      'Save': 'සුරකින්න',
      'Cancel': 'අවලංගු කරන්න',
    },
    'Tamil': {
      'Settings': 'அமைப்புகள்',
      'Daily Goals': 'தினசரி இலக்குகள்',
      'Step Goal': 'படி இலக்கு',
      'Calorie Burn Goal': 'கலோரி எரிப்பு இலக்கு',
      'Water Goal': 'தண்ணீர் இலக்கு',
      'Active Minutes Goal': 'செயலில் உள்ள நிமிட இலக்கு',
      'Notifications': 'அறிவிப்புகள்',
      'Workout Reminder': 'உடற்பயிற்சி நினைவூட்டல்',
      'Water Reminders': 'தண்ணீர் நினைவූட்டல்கள்',
      'Preferences': 'விருப்பங்கள்',
      'Language': 'மொழி',
      'Theme': 'தீம்',
      'Units': 'அலகுகள்',
      'About': 'பற்றி',
      'Logout': 'வெளியேறு',
      'Good Morning ☀️': 'காலை வணக்கம் ☀️',
      'Good Afternoon 🌤️': 'மதிய வணக்கம் 🌤️',
      'Good Evening 🌙': 'மாலை வணக்கம் 🌙',
      'Today\'s Goals': 'இன்றைய இலக்குகள்',
      'Calories': 'கலோரிகள்',
      'Steps': 'படிகள்',
      'Water': 'தண்ணீர்',
      'Active': 'செயலில்',
      'Quick Add Water': 'விரைவாக தண்ணீர் சேர்க்கவும்',
      'Exercise Type': 'உடற்பயிற்சி வகை',
      'Sleep': 'தூக்கம்',
      'Recent Activity': 'சமீபத்திய நடவடிக்கை',
      'Total Sleep': 'மொத்த தூக்கம்',
      'Save': 'சேமி',
      'Cancel': 'ரத்துசெய்',
    },
  };

  static String translate(String text, String targetLanguage) {
    if (targetLanguage == 'English') return text;
    
    final langMap = _staticTranslations[targetLanguage];
    if (langMap != null && langMap.containsKey(text)) {
      return langMap[text]!;
    }
    
    // In a real app, you would call Google Translate API here
    // example: return await _fetchFromGoogleTranslate(text, targetLanguage);
    
    return text; // Fallback to English
  }

  // Example of how you would call the actual API
  static Future<String> fetchFromGoogleTranslate(String text, String targetLangCode) async {
    // Requires API Key: https://cloud.google.com/translate/docs/setup
    const apiKey = 'YOUR_GOOGLE_TRANSLATE_API_KEY';
    final url = 'https://translation.googleapis.com/language/translate/v2?key=$apiKey';
    
    try {
      final response = await http.post(
        Uri.parse(url),
        body: json.encode({
          'q': text,
          'target': targetLangCode,
        }),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data']['translations'][0]['translatedText'];
      }
    } catch (e) {
      print('Translation error: $e');
    }
    return text;
  }
}
