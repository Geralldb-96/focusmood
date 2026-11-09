class Habit {
  Habit({
    required this.id,
    required this.name,
    this.goal = '15 minutos',
    this.icon = 'walk',
    this.done = false,
    this.days = const [0, 1, 2, 3, 4],
    this.reminder = true,
    this.moment = 'Tarde',
  });

  factory Habit.fromJson(Map<String, dynamic> json) {
    return Habit(
      id: json['id'] as int,
      name: json['name'] as String,
      goal: json['goal'] as String? ?? '15 minutos',
      icon: json['icon'] as String? ?? 'walk',
      done: json['done'] == true,
      days: (json['days'] as List?)?.cast<int>() ?? [0, 1, 2, 3, 4],
      reminder: json['reminder'] as bool? ?? true,
      moment: json['moment'] as String? ?? 'Tarde',
    );
  }

  final int id;
  String name;
  String goal;
  String icon;
  String moment;
  bool done;
  bool reminder;
  List<int> days;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'goal': goal,
      'icon': icon,
      'done': done,
      'days': days,
      'reminder': reminder,
      'moment': moment,
    };
  }
}
