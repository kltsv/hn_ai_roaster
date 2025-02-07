class Story {
  final int id;
  final String title;
  final String? url;
  final String? text;
  final String by;
  final int time;
  final int score;
  final int descendants;
  final List<int> kids;

  Story({
    required this.id,
    required this.title,
    this.url,
    this.text,
    required this.by,
    required this.time,
    required this.score,
    required this.descendants,
    required this.kids,
  });

  factory Story.fromJson(Map<String, dynamic> json) {
    return Story(
      id: json['id'] as int,
      title: json['title'] as String,
      url: json['url'] as String?,
      text: json['text'] as String?,
      by: json['by'] as String,
      time: json['time'] as int,
      score: json['score'] as int,
      descendants: json['descendants'] as int? ?? 0,
      kids: (json['kids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(time * 1000);

  String get domain {
    if (url == null) return '';
    try {
      final uri = Uri.parse(url!);
      return uri.host;
    } catch (_) {
      return '';
    }
  }
}