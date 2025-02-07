class Comment {
  final int id;
  final String by;
  final int time;
  final String text;
  final List<int> kids;
  final bool deleted;

  Comment({
    required this.id,
    required this.by,
    required this.time,
    required this.text,
    required this.kids,
    this.deleted = false,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      id: json['id'] as int,
      by: json['by'] as String? ?? '[deleted]',
      time: json['time'] as int,
      text: json['text'] as String? ?? '[deleted]',
      kids: (json['kids'] as List<dynamic>?)?.map((e) => e as int).toList() ?? [],
      deleted: json['deleted'] as bool? ?? false,
    );
  }

  DateTime get dateTime => DateTime.fromMillisecondsSinceEpoch(time * 1000);
}