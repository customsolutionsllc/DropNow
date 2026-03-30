import 'dart:math';
import 'package:drop_now/core/models/models.dart';

/// Personality-aligned feedback messages for DONE / SKIPPED actions.
/// Includes streak-aware messages when streak count is provided.
class FeedbackService {
  static final _random = Random();

  static String onDone(Personality personality, {int? streak}) {
    if (streak != null && streak > 0) {
      final streakPhrases = _streakDonePhrases[personality]!;
      final phrase = streakPhrases[_random.nextInt(streakPhrases.length)];
      return phrase.replaceAll('{streak}', streak.toString());
    }
    final phrases = _donePhrases[personality]!;
    return phrases[_random.nextInt(phrases.length)];
  }

  static String onSkipped(Personality personality, {int? streak}) {
    if (streak != null && streak > 0) {
      final streakPhrases = _streakSkippedPhrases[personality]!;
      final phrase = streakPhrases[_random.nextInt(streakPhrases.length)];
      return phrase.replaceAll('{streak}', streak.toString());
    }
    final phrases = _skippedPhrases[personality]!;
    return phrases[_random.nextInt(phrases.length)];
  }

  static const Map<Personality, List<String>> _donePhrases = {
    Personality.commander: [
      'Good. Keep moving.',
      'Mission complete. Stand by for the next.',
      'That\'s what discipline looks like.',
      'Solid execution, soldier.',
      'Stay consistent. That\'s an order.',
      'Good. Stay sharp.',
      'Executed. No hesitation. I respect that.',
      'You didn\'t flinch. Neither will I.',
    ],
    Personality.funny: [
      'Look at you being all healthy and stuff.',
      'Your muscles just sent a thank you card.',
      'Achievement unlocked: Actually doing it.',
      'Plot twist: you\'re getting fit.',
      'Your future self just high-fived you.',
      'Somebody call the flex police. 💪',
      'You actually did it. I\'m genuinely shocked.',
      'Fitness level: slightly less potato.',
    ],
    Personality.chill: [
      'Nice work. Every rep counts.',
      'That felt good, right?',
      'Solid effort. Keep it up.',
      'You showed up. That\'s what matters.',
      'Good vibes. Good reps.',
      'Flow state unlocked. Smooth.',
      'Easy does it. And you did it.',
      'Respect the process. You just did.',
    ],
  };

  static const Map<Personality, List<String>> _skippedPhrases = {
    Personality.commander: [
      'Weak. Don\'t let that happen again.',
      'You skipped that. I noticed.',
      'Unacceptable. The next one better be done.',
      'Skipping is not a strategy, soldier.',
      'Noted. Do better.',
      'You hesitated. That\'s weakness.',
      'The enemy doesn\'t rest. Neither should you.',
      'Weakness is a choice. Choose again.',
    ],
    Personality.funny: [
      'So close. And by close I mean... you didn\'t.',
      'Your couch won this round.',
      'Skip button: 1. You: 0.',
      'That exercise will remember this betrayal.',
      'Bold move, skipping. Let\'s see how that works out.',
      'Gravity: 1. Your motivation: 0.',
      'Netflix isn\'t going anywhere. Do the reps.',
      'I\'ll pretend I didn\'t see that.',
    ],
    Personality.chill: [
      'No worries. Catch the next one.',
      'It happens. Try the next one.',
      'All good — just don\'t make it a habit.',
      'Skipped this time. Next time\'s yours.',
      'Rest is fine. Just come back stronger.',
      'Take a breath. Then show up next time.',
      'Even waves pull back before they crash.',
      'Reset. Refocus. You got the next one.',
    ],
  };

  static const Map<Personality, List<String>> _streakDonePhrases = {
    Personality.commander: [
      '{streak} days strong. Don\'t break now.',
      '{streak}-day streak. You\'re earning your rank.',
      'Day {streak}. The mission continues.',
      '{streak} in a row. That\'s not luck — that\'s discipline.',
    ],
    Personality.funny: [
      '{streak} days! Your couch is filing a missing person report.',
      'Day {streak}! At this point you\'re basically an athlete.',
      '{streak}-day streak? Who are you and what have you done with the old you?',
      '{streak} days strong — send this to your gym teacher.',
    ],
    Personality.chill: [
      '{streak} days flowing. Beautiful consistency.',
      'Day {streak}. The rhythm is real.',
      '{streak}-day streak. You\'re in the zone.',
      '{streak} days — this is becoming who you are.',
    ],
  };

  static const Map<Personality, List<String>> _streakSkippedPhrases = {
    Personality.commander: [
      'Your {streak}-day streak is watching. Don\'t disappoint it.',
      '{streak} days of discipline — and you skip NOW?',
      'That {streak}-day streak won\'t protect itself.',
      '{streak} days on the line. Make the next one count.',
    ],
    Personality.funny: [
      'Your {streak}-day streak just gasped dramatically.',
      '{streak} days of glory... and then this. Yikes.',
      'Streak: {streak}. Skip count: concerning.',
      'Your {streak}-day streak is giving you the side-eye.',
    ],
    Personality.chill: [
      '{streak} days going — keep it alive with the next one.',
      'The streak lives at {streak}. Don\'t let it fade.',
      '{streak} days of flow. One skip won\'t break it... probably.',
      'Still at {streak}. But show up next time, yeah?',
    ],
  };
}
