import 'package:intl/intl.dart';

class Story {
  final String title;
  final String content;
  final String summary;
  final List<String> morals;
  final String theme;
  final String date;

  Story({
    required this.title,
    required this.content,
    required this.summary,
    required this.morals,
    required this.theme,
    required String date,
  }) : date = _formatDate(date);

  static String _formatDate(String date) {
    try {
      DateTime parsedDate = DateTime.parse(date);
      return DateFormat('dd/MM/yy').format(parsedDate);
    } catch (e) {
      return date;
    }
  }

  Map<String, dynamic> toJson() => {
    'title': title,
    'content': content,
    'summary': summary,
    'morals': morals,
    'theme': theme,
    'date': date,
  };

  factory Story.fromJson(Map<String, dynamic> json) => Story(
    title: json['title'],
    content: json['content'],
    summary: json['summary'],
    morals: List<String>.from(json['morals']),
    theme: json['theme'],
    date: json['date'],
  );
}
