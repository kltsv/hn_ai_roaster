import 'package:html/parser.dart';

String cleanHtmlText(String? text) {
  if (text == null || text.isEmpty) return '';
  
  // Parse HTML and get text content
  final document = parse(text);
  final cleanText = document.body?.text ?? '';
  
  // Replace HTML entities
  return cleanText
      .replaceAll('&amp;', '&')
      .replaceAll('&lt;', '<')
      .replaceAll('&gt;', '>')
      .replaceAll('&quot;', '"')
      .replaceAll('&#x27;', "'")
      .replaceAll('&#x2F;', "/");
}