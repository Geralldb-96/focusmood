class FocusSession {
  FocusSession(this.minutes, this.date, {this.name = 'Sesión de enfoque'});

  factory FocusSession.fromJson(Map<String, dynamic> json) {
    return FocusSession(
      (json['minutes'] as num).toInt(),
      json['date'] as String,
      name: json['name'] as String? ?? 'Sesión de enfoque',
    );
  }

  final int minutes;
  final String date;
  final String name;

  Map<String, dynamic> toJson() {
    return {'name': name, 'minutes': minutes, 'date': date};
  }
}
