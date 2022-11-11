class Log{
  final int id;
  final String title;
  final String message;
  final int type;
  final int date;

  const Log({
    this.id = 0,
    required this.title,
    required this.message,
    required this.type,
    required this.date
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'type': type,
      'date': date
    };
  }
}