enum Personality { commander, funny, chill }

extension PersonalityExtension on Personality {
  String get label {
    switch (this) {
      case Personality.commander:
        return 'Commander';
      case Personality.funny:
        return 'Funny';
      case Personality.chill:
        return 'Chill';
    }
  }

  String get description {
    switch (this) {
      case Personality.commander:
        return 'Drill Sergeant mode. No excuses.';
      case Personality.funny:
        return 'Sarcastic motivation to get you moving.';
      case Personality.chill:
        return 'Friendly nudges. No pressure.';
    }
  }

  String get emoji {
    switch (this) {
      case Personality.commander:
        return '🎖️';
      case Personality.funny:
        return '😂';
      case Personality.chill:
        return '😌';
    }
  }
}
