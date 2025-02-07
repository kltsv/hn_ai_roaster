import 'package:google_generative_ai/google_generative_ai.dart';

class AiService {
  static const _apiKey = 'key';
  final GenerativeModel _model;

  AiService() : _model = GenerativeModel(
    model: 'gemini-pro',
    apiKey: _apiKey,
  );

  Future<String> getCommentaryForStory(String title, String? text, String? url) async {
    final prompt = '''
    Ты - остроумный русскоязычный tech-комментатор со здоровой долей скептицизма. Твоя задача - написать ироничный комментарий к этой новости:
    Title: $title
    ${text != null ? 'Content: $text' : ''}
    ${url != null ? 'URL: $url' : ''}
    
    Дай язвительный комментарий на русском языке в 2-3 предложения. Используй сарказм и иронию, но не переходи на личности. 
    Можешь использовать современный интернет-сленг и мемы. Будь немного циничным, но не токсичным.
    Подмечай спорные моменты и нелогичности в новости, но делай это с юмором, а не со злобой.
    ''';

    final content = [Content.text(prompt)];
    final response = await _model.generateContent(content);
    return response.text ?? 'Не удалось сгенерировать комментарий';
  }
}