import 'dart:math';
import 'package:drop_now/core/models/models.dart';

/// Personality-aligned feedback messages for DONE / SKIPPED actions.
class FeedbackService {
  static final _random = Random();

  static String onDone(Personality personality) {
    final phrases = _donePhrases[personality]!;
    return phrases[_random.nextInt(phrases.length)];
  }

  static String onSkipped(Personality personality) {
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
    ],
    Personality.funny: [
      'Look at you being all healthy and stuff.',
      'Your muscles just sent a thank you card.',
      'Achievement unlocked: Actually doing it.',
      'Plot twist: you\'re getting fit.',
      'Your future self just high-fived you.',
    ],
    Personality.chill: [
      'Nice work. Every rep counts.',
      'That felt good, right?',
      'Solid effort. Keep it up.',
      'You showed up. That\'s what matters.',
      'Good vibes. Good reps.',
    ],
  };

  static const Map<Personality, List<String>> _skippedPhrases = {
    Personality.commander: [
      'Weak. Don\'t let that happen again.',
      'You skipped that. I noticed.',
      'Unacceptable. The next one better be done.',
      'Skipping is not a strategy, soldier.',
      'Noted. Do better.',
    ],
    Personality.funny: [
      'So close. And by close I mean... you didn\'t.',
      'Your couch won this round.',
      'Skip button: 1. You: 0.',
      'That exercise will remember this betrayal.',
      'Bold move, skipping. Let\'s see how that works out.',
    ],
    Personality.chill: [
      'No worries. Catch the next one.',
      'It happens. Try the next one.',
      'All good — just don\'t make it a habit.',
      'Skipped this time. Next time\'s yours.',
      'Rest is fine. Just come back stronger.',
    ],
  };
}
