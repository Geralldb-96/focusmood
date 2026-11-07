import 'dart:convert';

class UserProfile {
  const UserProfile({
    required this.name,
    required this.email,
    this.career = '',
    this.university = '',
    this.semester,
  });

  final String name;
  final String email;
  final String career;
  final String university;
  final int? semester;

  static const empty = UserProfile(name: '', email: '');

  factory UserProfile.fromJson(Map<String, dynamic> j) {
    var university = '';
    try {
      final prefs = j['preferences'];
      if (prefs is String && prefs.isNotEmpty) {
        university =
            (jsonDecode(prefs) as Map<String, dynamic>)['university']
                as String? ??
            '';
      }
    } catch (_) {
      // preferencias con otro formato: se ignoran
    }
    return UserProfile(
      name: j['name'] as String? ?? '',
      email: j['email'] as String? ?? '',
      career: j['career'] as String? ?? '',
      university: university,
      semester: j['semester'] as int?,
    );
  }

  String get initials {
    final parts = name
        .trim()
        .split(RegExp(r'\s+'))
        .where((p) => p.isNotEmpty)
        .toList();
    return parts.take(2).map((p) => p[0].toUpperCase()).join();
  }

  String get firstName =>
      name.trim().isEmpty ? '' : name.trim().split(RegExp(r'\s+')).first;
}

class Habit {
  const Habit({
    required this.id,
    required this.name,
    required this.description,
    required this.frequency,
    required this.active,
    required this.completedToday,
    this.schedule,
  });

  final int id;
  final String name;
  final String description;
  final String frequency; // DAILY | WEEKDAYS | WEEKLY
  final String? schedule; // MORNING | AFTERNOON | NIGHT
  final bool active;
  final bool completedToday;

  factory Habit.fromJson(Map<String, dynamic> j) => Habit(
    id: j['id'] as int,
    name: j['name'] as String,
    description: j['description'] as String? ?? '',
    frequency: j['frequency'] as String,
    schedule: j['schedule'] as String?,
    active: j['active'] as bool? ?? true,
    completedToday: j['completedToday'] as bool? ?? false,
  );
}

class HabitDraft {
  const HabitDraft({
    required this.name,
    required this.description,
    required this.frequency,
    this.schedule,
  });

  final String name;
  final String description;
  final String frequency;
  final String? schedule;

  Map<String, dynamic> toJson() => {
    'name': name,
    'description': description,
    'frequency': frequency,
    if (schedule != null) 'schedule': schedule,
  };
}

class Recommendation {
  const Recommendation({
    required this.id,
    required this.category,
    required this.title,
    required this.technique,
    required this.durationMinutes,
    required this.instructions,
    required this.source,
    required this.generatedAt,
    required this.activity,
    required this.disclaimer,
    this.score,
  });

  final int id;
  final String category; // STUDY_TECHNIQUE | WELLNESS_ACTIVITY
  final String title;
  final String technique;
  final int durationMinutes;
  final String instructions;
  final String source;
  final DateTime generatedAt;
  final String activity;
  final String disclaimer;
  final int? score;

  bool get isWellness => category == 'WELLNESS_ACTIVITY';
  bool get fromFallback => source == 'reglas-locales';
  bool? get helpful => score == null ? null : score! >= 4;

  List<String> get steps => instructions
      .split(RegExp(r'(?<=[.!?])\s+'))
      .where((s) => s.trim().isNotEmpty)
      .toList();

  factory Recommendation.fromJson(Map<String, dynamic> j) {
    final rating = j['rating'] as Map<String, dynamic>?;
    final context = j['context'] as Map<String, dynamic>? ?? const {};
    return Recommendation(
      id: j['id'] as int,
      category: j['category'] as String? ?? 'STUDY_TECHNIQUE',
      title: j['title'] as String,
      technique: j['technique'] as String,
      durationMinutes: j['durationMinutes'] as int,
      instructions: j['instructions'] as String,
      source: j['source'] as String? ?? '',
      generatedAt: DateTime.parse(j['generatedAt'] as String).toLocal(),
      activity: context['academicActivity'] as String? ?? '',
      disclaimer: j['disclaimer'] as String? ?? '',
      score: rating?['score'] as int?,
    );
  }
}

/// Registro diario tal como lo captura la interfaz (sliders 0-10).
class DailyInput {
  const DailyInput({
    required this.mood,
    required this.energy,
    required this.focus,
  });

  final int mood;
  final int energy;
  final int focus;

  static const _moods = [
    'ESTRESADO',
    'ANSIOSO',
    'TRISTE',
    'CANSADO',
    'NEUTRAL',
    'NEUTRAL',
    'CALMADO',
    'CALMADO',
    'MOTIVADO',
    'FELIZ',
    'FELIZ',
  ];

  /// El backend usa escala 1-5 (modelo relacional 4.4.2) y estados de ánimo discretos.
  static int level(int v) => (v / 2).ceil().clamp(1, 5);

  Map<String, dynamic> toJson() => {
    'mood': _moods[mood.clamp(0, 10)],
    'energyLevel': level(energy),
    'concentrationLevel': level(focus),
  };
}

class StudySession {
  const StudySession({
    required this.id,
    required this.activity,
    required this.durationMinutes,
    required this.startedAt,
  });

  final int id;
  final String activity;
  final int durationMinutes;
  final DateTime startedAt;

  factory StudySession.fromJson(Map<String, dynamic> j) => StudySession(
    id: j['id'] as int,
    activity: j['activity'] as String,
    durationMinutes: j['durationMinutes'] as int,
    startedAt: DateTime.parse(j['startedAt'] as String).toLocal(),
  );
}

class WellnessActivity {
  const WellnessActivity({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    required this.minutes,
  });

  final int id;
  final String name;
  final String description;
  final String category; // RESPIRAR | MOVERTE | DESCANSAR
  final int minutes;

  factory WellnessActivity.fromJson(Map<String, dynamic> j) => WellnessActivity(
    id: j['id'] as int,
    name: j['name'] as String,
    description: j['description'] as String,
    category: j['category'] as String,
    minutes: j['estimatedMinutes'] as int,
  );
}

class MoodPoint {
  const MoodPoint(this.date, this.score);

  final String date;
  final int score;
}

class WeeklySummary {
  const WeeklySummary({
    required this.weekStart,
    required this.weekEnd,
    required this.hasData,
    required this.message,
    required this.averageMood,
    required this.moodPoints,
    required this.habitRate,
    required this.habitsCompleted,
    required this.habitsExpected,
    required this.studyMinutes,
    required this.studySessions,
    required this.recsRated,
    required this.recsHelpful,
  });

  final String weekStart;
  final String weekEnd;
  final bool hasData;
  final String? message;
  final double? averageMood;
  final List<MoodPoint> moodPoints;
  final double? habitRate;
  final int habitsCompleted;
  final int habitsExpected;
  final int studyMinutes;
  final int studySessions;
  final int recsRated;
  final int recsHelpful;

  factory WeeklySummary.fromJson(Map<String, dynamic> j) {
    final mood = j['mood'] as Map<String, dynamic>;
    final habits = j['habits'] as Map<String, dynamic>;
    final study = j['study'] as Map<String, dynamic>;
    final recs = j['recommendations'] as Map<String, dynamic>;
    return WeeklySummary(
      weekStart: j['weekStart'] as String,
      weekEnd: j['weekEnd'] as String,
      hasData: j['hasData'] as bool,
      message: j['message'] as String?,
      averageMood: (mood['averageMood'] as num?)?.toDouble(),
      moodPoints: [
        for (final p in (mood['points'] as List? ?? const []))
          MoodPoint(p['date'] as String, p['moodScore'] as int),
      ],
      habitRate: (habits['completionRate'] as num?)?.toDouble(),
      habitsCompleted: habits['completed'] as int,
      habitsExpected: habits['expected'] as int,
      studyMinutes: study['totalMinutes'] as int,
      studySessions: study['sessions'] as int,
      recsRated: recs['rated'] as int,
      recsHelpful: recs['helpful'] as int,
    );
  }
}
