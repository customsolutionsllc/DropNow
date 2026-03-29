import 'package:drop_now/core/models/models.dart';

/// A template for a workout command before tone is applied.
class WorkoutTemplate {
  final WorkoutType type;

  /// Rep/time ranges per difficulty: {Difficulty: (min, max)}
  final Map<Difficulty, (int, int)> ranges;

  const WorkoutTemplate({required this.type, required this.ranges});
}

/// Tone-specific phrase templates.
/// Use {amount} and {exercise} as placeholders.
class ToneTemplates {
  final List<String> commander;
  final List<String> funny;
  final List<String> chill;

  const ToneTemplates({
    required this.commander,
    required this.funny,
    required this.chill,
  });

  List<String> forPersonality(Personality p) {
    switch (p) {
      case Personality.commander:
        return commander;
      case Personality.funny:
        return funny;
      case Personality.chill:
        return chill;
    }
  }
}

class WorkoutLibrary {
  WorkoutLibrary._();

  static const List<WorkoutTemplate> templates = [
    // Pushups
    WorkoutTemplate(
      type: WorkoutType.pushups,
      ranges: {
        Difficulty.easy: (5, 10),
        Difficulty.medium: (12, 20),
        Difficulty.savage: (25, 40),
      },
    ),
    // Squats
    WorkoutTemplate(
      type: WorkoutType.squats,
      ranges: {
        Difficulty.easy: (8, 15),
        Difficulty.medium: (15, 25),
        Difficulty.savage: (30, 50),
      },
    ),
    // Jumping Jacks
    WorkoutTemplate(
      type: WorkoutType.jumpingJacks,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (20, 35),
        Difficulty.savage: (40, 60),
      },
    ),
    // Plank (seconds)
    WorkoutTemplate(
      type: WorkoutType.plank,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 90),
      },
    ),
    // Lunges
    WorkoutTemplate(
      type: WorkoutType.lunges,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (10, 16),
        Difficulty.savage: (18, 30),
      },
    ),
    // Wall Sit (seconds)
    WorkoutTemplate(
      type: WorkoutType.wallSit,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 80),
      },
    ),
    // Sit-Ups
    WorkoutTemplate(
      type: WorkoutType.sitUps,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (15, 25),
        Difficulty.savage: (25, 40),
      },
    ),
    // Burpees
    WorkoutTemplate(
      type: WorkoutType.burpees,
      ranges: {
        Difficulty.easy: (3, 6),
        Difficulty.medium: (8, 12),
        Difficulty.savage: (15, 25),
      },
    ),
    // High Knees
    WorkoutTemplate(
      type: WorkoutType.highKnees,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (20, 35),
        Difficulty.savage: (35, 50),
      },
    ),
    // Mountain Climbers
    WorkoutTemplate(
      type: WorkoutType.mountainClimbers,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (15, 25),
        Difficulty.savage: (25, 40),
      },
    ),
    // Calf Raises
    WorkoutTemplate(
      type: WorkoutType.calfRaises,
      ranges: {
        Difficulty.easy: (10, 15),
        Difficulty.medium: (15, 25),
        Difficulty.savage: (30, 50),
      },
    ),
    // Tricep Dips
    WorkoutTemplate(
      type: WorkoutType.tricepDips,
      ranges: {
        Difficulty.easy: (5, 8),
        Difficulty.medium: (10, 15),
        Difficulty.savage: (18, 30),
      },
    ),
  ];

  /// Tone phrase templates per workout type.
  /// {amount} and {exercise} are replaced at generation time.
  static const Map<WorkoutType, ToneTemplates> toneTemplates = {
    WorkoutType.pushups: ToneTemplates(
      commander: [
        'Drop and give me {amount} pushups. Now.',
        '{amount} pushups. No excuses, soldier.',
        'Hit the floor. {amount} pushups. Move it.',
        '{amount} pushups. Execute immediately.',
      ],
      funny: [
        '{amount} pushups. Your couch can wait.',
        'Do {amount} pushups before your snacks judge you.',
        '{amount} pushups. Pretend the floor missed you.',
        'Quick — {amount} pushups before gravity wins.',
      ],
      chill: [
        'Take a quick break and give me {amount} pushups.',
        'How about {amount} pushups? You got this.',
        '{amount} pushups whenever you\'re ready.',
        'Easy {amount} pushups. No rush.',
      ],
    ),
    WorkoutType.squats: ToneTemplates(
      commander: [
        '{amount} squats. No excuses.',
        'Give me {amount} squats. I\'m watching.',
        '{amount} squats right now. Don\'t think, just do.',
        'Get low. {amount} squats. Go.',
      ],
      funny: [
        '{amount} squats. Your chair doesn\'t need you that much.',
        'Squat like nobody\'s watching. {amount} of them.',
        '{amount} squats. Consider it a standing ovation for yourself.',
        'Do {amount} squats. Your legs will thank you. Eventually.',
      ],
      chill: [
        'Let\'s do {amount} squats. Nice and easy.',
        '{amount} squats — quick little break.',
        'Feeling it? Try {amount} squats.',
        '{amount} casual squats. Take your time.',
      ],
    ),
    WorkoutType.jumpingJacks: ToneTemplates(
      commander: [
        '{amount} jumping jacks. Full extension. Go!',
        'I need {amount} jumping jacks. Now, soldier!',
        '{amount} jumping jacks. Sound off!',
        'On your feet! {amount} jumping jacks!',
      ],
      funny: [
        '{amount} jumping jacks. Channel your inner kid.',
        'Do {amount} jumping jacks. Free cardio, no gym required.',
        '{amount} jumping jacks. Flapping arms burns calories, trust me.',
        'Pop up and do {amount} jumping jacks. Surprise your neighbors.',
      ],
      chill: [
        '{amount} jumping jacks to get the blood flowing.',
        'Quick {amount} jumping jacks. Let\'s go.',
        'How about {amount} jumping jacks?',
        '{amount} jumping jacks. Easy warm-up.',
      ],
    ),
    WorkoutType.plank: ToneTemplates(
      commander: [
        'Plank position. {amount} seconds. Hold it!',
        '{amount}-second plank. Do not break form.',
        'Get down and hold a plank for {amount} seconds. No shaking.',
        '{amount} seconds plank. Hold the line!',
      ],
      funny: [
        'Hold a plank for {amount} seconds. Pretend the floor is lava.',
        '{amount}-second plank. It\'s just time standing still... on your elbows.',
        'Plank for {amount} seconds. Shake if you must, but don\'t quit.',
        '{amount} seconds of planking. Think of it as horizontal meditation.',
      ],
      chill: [
        'Hold a plank for {amount} seconds. You got this.',
        '{amount}-second plank. Nice and steady.',
        'Try a {amount}-second plank. Breathe through it.',
        'Quick plank — {amount} seconds.',
      ],
    ),
    WorkoutType.lunges: ToneTemplates(
      commander: [
        '{amount} lunges. Each leg. Move!',
        'Lunge forward! {amount} reps. Now!',
        '{amount} lunges. Deep and controlled. Execute!',
        'Give me {amount} lunges. No half measures.',
      ],
      funny: [
        '{amount} lunges. Walk like a fancy flamingo.',
        'Do {amount} lunges. Your legs have been too comfortable.',
        '{amount} lunges — pretend you\'re in a slow-motion action movie.',
        'Lunge {amount} times. Your glutes will write you a thank you note.',
      ],
      chill: [
        '{amount} lunges. Take it easy.',
        'Let\'s get {amount} lunges in. No hurry.',
        'How about {amount} lunges? Nice and smooth.',
        '{amount} easy lunges. One step at a time.',
      ],
    ),
    WorkoutType.wallSit: ToneTemplates(
      commander: [
        'Wall sit. {amount} seconds. Don\'t move.',
        'Back against the wall. {amount} seconds. No quitting.',
        '{amount}-second wall sit. I\'ll be watching.',
        'Wall sit — {amount} seconds. Endure it.',
      ],
      funny: [
        'Wall sit for {amount} seconds. Pretend there\'s an invisible chair.',
        '{amount} seconds wall sit. Your wall needs company anyway.',
        'Plant yourself against a wall for {amount} seconds. Gravity is the enemy.',
        '{amount}-second wall sit. Your legs will burn, but so does glory.',
      ],
      chill: [
        '{amount}-second wall sit. Find a wall and relax into it.',
        'Try a wall sit — {amount} seconds.',
        '{amount} seconds wall sit. Breathe steady.',
        'Quick wall sit — just {amount} seconds.',
      ],
    ),
    WorkoutType.sitUps: ToneTemplates(
      commander: [
        '{amount} sit-ups. Full range. Go!',
        'Give me {amount} sit-ups. Don\'t stop.',
        '{amount} sit-ups. Core tight!',
        'Hit the deck! {amount} sit-ups!',
      ],
      funny: [
        '{amount} sit-ups. Your abs are somewhere under there.',
        'Do {amount} sit-ups. It\'s like getting out of bed, but on purpose.',
        '{amount} sit-ups. Because pizza isn\'t going to burn itself.',
        'Crunch time! Literally. {amount} sit-ups.',
      ],
      chill: [
        '{amount} sit-ups. Slow and controlled.',
        'Let\'s do {amount} sit-ups. Take your time.',
        'How about {amount} sit-ups?',
        '{amount} easy sit-ups. Feel the burn.',
      ],
    ),
    WorkoutType.burpees: ToneTemplates(
      commander: [
        '{amount} burpees. Full body. GO!',
        'Drop! {amount} burpees! Move, move, move!',
        '{amount} burpees. No breaks. Execute.',
        'I said {amount} burpees. Don\'t make me repeat myself.',
      ],
      funny: [
        '{amount} burpees. The exercise nobody asked for.',
        'Do {amount} burpees. Yes, I know you hate them. Do them anyway.',
        '{amount} burpees. Flopping counts if you still get up.',
        'Time for {amount} burpees. Embrace the suffering.',
      ],
      chill: [
        '{amount} burpees. Take it at your pace.',
        'Try {amount} burpees. You can do it.',
        'Let\'s get through {amount} burpees together.',
        '{amount} burpees. Rest between reps if you need to.',
      ],
    ),
    WorkoutType.highKnees: ToneTemplates(
      commander: [
        '{amount} high knees. Knees to chest! Go!',
        'High knees! {amount} of them! Speed!',
        '{amount} high knees. Fast feet, soldier!',
        'Run in place! {amount} high knees! Now!',
      ],
      funny: [
        '{amount} high knees. March like you mean it.',
        'Do {amount} high knees. Pretend the floor is hot.',
        '{amount} high knees. It\'s running but you don\'t go anywhere.',
        'Knee time! {amount} high knees. Look alive.',
      ],
      chill: [
        '{amount} high knees. Quick cardio burst.',
        'Let\'s do {amount} high knees. Light and easy.',
        '{amount} high knees to wake up your legs.',
        'Quick {amount} high knees. No sweat.',
      ],
    ),
    WorkoutType.mountainClimbers: ToneTemplates(
      commander: [
        '{amount} mountain climbers. Full speed!',
        'Get down! {amount} mountain climbers! Go!',
        '{amount} mountain climbers. No slowing down.',
        'Mountain climbers! {amount}! Execute!',
      ],
      funny: [
        '{amount} mountain climbers. The mountain is your floor.',
        'Do {amount} mountain climbers. Everest isn\'t going to climb itself.',
        '{amount} mountain climbers. Your Core called — it wants attention.',
        'Crawl your way through {amount} mountain climbers.',
      ],
      chill: [
        '{amount} mountain climbers. Steady pace.',
        'Try {amount} mountain climbers.',
        'Let\'s do {amount} mountain climbers. Nice rhythm.',
        '{amount} mountain climbers. You got this.',
      ],
    ),
    WorkoutType.calfRaises: ToneTemplates(
      commander: [
        '{amount} calf raises. Full extension!',
        'Rise up! {amount} calf raises!',
        '{amount} calf raises. Squeeze at the top!',
        'On your toes! {amount} calf raises! Go!',
      ],
      funny: [
        '{amount} calf raises. Tip-toe your way to greatness.',
        'Do {amount} calf raises. Become the tall person you were meant to be.',
        '{amount} calf raises. Your calves deserve some love too.',
        'Stand on your toes {amount} times. Ballet, but for fitness.',
      ],
      chill: [
        '{amount} calf raises. Easy and controlled.',
        'Quick {amount} calf raises.',
        'Let\'s do {amount} calf raises. Simple.',
        '{amount} calf raises. Take your time.',
      ],
    ),
    WorkoutType.tricepDips: ToneTemplates(
      commander: [
        '{amount} tricep dips. Find a chair. Go!',
        'Dip it! {amount} tricep dips! Now!',
        '{amount} tricep dips. Arms locked. Full range!',
        'Chair dips! {amount}! Move, soldier!',
      ],
      funny: [
        '{amount} tricep dips. Your chair is now gym equipment.',
        'Do {amount} tricep dips. Your arms will thank you. Tomorrow.',
        '{amount} tricep dips. Furniture-assisted fitness.',
        'Time for {amount} tricep dips. No chair left behind.',
      ],
      chill: [
        '{amount} tricep dips. Find a sturdy surface.',
        'Let\'s do {amount} tricep dips. Nice and controlled.',
        'Try {amount} tricep dips when you\'re ready.',
        '{amount} tricep dips. Easy does it.',
      ],
    ),
  };
}
