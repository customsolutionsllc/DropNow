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
    // Flutter Kicks
    WorkoutTemplate(
      type: WorkoutType.flutterKicks,
      ranges: {
        Difficulty.easy: (10, 16),
        Difficulty.medium: (18, 30),
        Difficulty.savage: (35, 50),
      },
    ),
    // Bicycle Crunches
    WorkoutTemplate(
      type: WorkoutType.bicycleCrunches,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 26),
        Difficulty.savage: (30, 50),
      },
    ),
    // Glute Bridges
    WorkoutTemplate(
      type: WorkoutType.gluteBridges,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (25, 40),
      },
    ),
    // Superman Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.supermanHold,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 70),
      },
    ),
    // Leg Raises
    WorkoutTemplate(
      type: WorkoutType.legRaises,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Star Jumps
    WorkoutTemplate(
      type: WorkoutType.starJumps,
      ranges: {
        Difficulty.easy: (6, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (25, 40),
      },
    ),
    // Lateral Lunges
    WorkoutTemplate(
      type: WorkoutType.lateralLunges,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (10, 16),
        Difficulty.savage: (18, 28),
      },
    ),
    // Inchworms
    WorkoutTemplate(
      type: WorkoutType.inchworms,
      ranges: {
        Difficulty.easy: (3, 6),
        Difficulty.medium: (7, 12),
        Difficulty.savage: (14, 20),
      },
    ),
    // Jump Squats
    WorkoutTemplate(
      type: WorkoutType.jumpSquats,
      ranges: {
        Difficulty.easy: (5, 10),
        Difficulty.medium: (12, 20),
        Difficulty.savage: (22, 35),
      },
    ),
    // Diamond Pushups
    WorkoutTemplate(
      type: WorkoutType.diamondPushups,
      ranges: {
        Difficulty.easy: (3, 7),
        Difficulty.medium: (8, 14),
        Difficulty.savage: (16, 28),
      },
    ),
    // Wide Pushups
    WorkoutTemplate(
      type: WorkoutType.widePushups,
      ranges: {
        Difficulty.easy: (5, 10),
        Difficulty.medium: (12, 20),
        Difficulty.savage: (22, 35),
      },
    ),
    // Pike Pushups
    WorkoutTemplate(
      type: WorkoutType.pikePushups,
      ranges: {
        Difficulty.easy: (3, 6),
        Difficulty.medium: (8, 14),
        Difficulty.savage: (16, 25),
      },
    ),
    // Shoulder Taps
    WorkoutTemplate(
      type: WorkoutType.shoulderTaps,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 24),
        Difficulty.savage: (26, 40),
      },
    ),
    // Russian Twists
    WorkoutTemplate(
      type: WorkoutType.russianTwists,
      ranges: {
        Difficulty.easy: (10, 16),
        Difficulty.medium: (18, 28),
        Difficulty.savage: (30, 50),
      },
    ),
    // V-Ups
    WorkoutTemplate(
      type: WorkoutType.vUps,
      ranges: {
        Difficulty.easy: (5, 8),
        Difficulty.medium: (10, 16),
        Difficulty.savage: (18, 28),
      },
    ),
    // Reverse Crunches
    WorkoutTemplate(
      type: WorkoutType.reverseCrunches,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (24, 36),
      },
    ),
    // Donkey Kicks
    WorkoutTemplate(
      type: WorkoutType.donkeyKicks,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (24, 36),
      },
    ),
    // Fire Hydrants
    WorkoutTemplate(
      type: WorkoutType.fireHydrants,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (24, 36),
      },
    ),
    // Bird Dogs
    WorkoutTemplate(
      type: WorkoutType.birdDogs,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Dead Bugs
    WorkoutTemplate(
      type: WorkoutType.deadBugs,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Scissor Kicks
    WorkoutTemplate(
      type: WorkoutType.scissorKicks,
      ranges: {
        Difficulty.easy: (10, 16),
        Difficulty.medium: (18, 28),
        Difficulty.savage: (30, 46),
      },
    ),
    // Tuck Jumps
    WorkoutTemplate(
      type: WorkoutType.tuckJumps,
      ranges: {
        Difficulty.easy: (3, 6),
        Difficulty.medium: (8, 14),
        Difficulty.savage: (16, 24),
      },
    ),
    // Skaters
    WorkoutTemplate(
      type: WorkoutType.skaters,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 24),
        Difficulty.savage: (26, 40),
      },
    ),
    // Frog Jumps
    WorkoutTemplate(
      type: WorkoutType.frogJumps,
      ranges: {
        Difficulty.easy: (4, 8),
        Difficulty.medium: (10, 16),
        Difficulty.savage: (18, 28),
      },
    ),
    // Curtsy Lunges
    WorkoutTemplate(
      type: WorkoutType.curtsyLunges,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Squat Pulses
    WorkoutTemplate(
      type: WorkoutType.squatPulses,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 26),
        Difficulty.savage: (28, 44),
      },
    ),
    // Plank Jacks
    WorkoutTemplate(
      type: WorkoutType.plankJacks,
      ranges: {
        Difficulty.easy: (8, 12),
        Difficulty.medium: (14, 22),
        Difficulty.savage: (24, 36),
      },
    ),
    // Bear Crawl Steps
    WorkoutTemplate(
      type: WorkoutType.bearCrawlSteps,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Toe Touches
    WorkoutTemplate(
      type: WorkoutType.toeTouches,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 24),
        Difficulty.savage: (26, 40),
      },
    ),
    // Hip Thrusts
    WorkoutTemplate(
      type: WorkoutType.hipThrusts,
      ranges: {
        Difficulty.easy: (8, 14),
        Difficulty.medium: (16, 24),
        Difficulty.savage: (26, 40),
      },
    ),
    // Reverse Lunges
    WorkoutTemplate(
      type: WorkoutType.reverseLunges,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Side Plank Dips
    WorkoutTemplate(
      type: WorkoutType.sidePlankDips,
      ranges: {
        Difficulty.easy: (5, 8),
        Difficulty.medium: (10, 16),
        Difficulty.savage: (18, 26),
      },
    ),
    // Crunches
    WorkoutTemplate(
      type: WorkoutType.crunches,
      ranges: {
        Difficulty.easy: (10, 16),
        Difficulty.medium: (18, 28),
        Difficulty.savage: (30, 50),
      },
    ),
    // Side Plank (seconds)
    WorkoutTemplate(
      type: WorkoutType.sidePlank,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 70),
      },
    ),
    // Hollow Body Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.hollowBodyHold,
      ranges: {
        Difficulty.easy: (10, 18),
        Difficulty.medium: (20, 35),
        Difficulty.savage: (40, 60),
      },
    ),
    // Bear Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.bearHold,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 70),
      },
    ),
    // Boat Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.boatHold,
      ranges: {
        Difficulty.easy: (10, 18),
        Difficulty.medium: (20, 35),
        Difficulty.savage: (40, 60),
      },
    ),
    // Bridge Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.bridgeHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 80),
      },
    ),
    // Warrior I Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.warriorIHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 75),
      },
    ),
    // Warrior II Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.warriorIIHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 75),
      },
    ),
    // Chair Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.chairPoseHold,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 70),
      },
    ),
    // Tree Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.treePoseHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 50),
        Difficulty.savage: (55, 90),
      },
    ),
    // Downward Dog Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.downwardDogHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 50),
        Difficulty.savage: (55, 80),
      },
    ),
    // Cobra Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.cobraPoseHold,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 65),
      },
    ),
    // Child's Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.childsPoseHold,
      ranges: {
        Difficulty.easy: (20, 30),
        Difficulty.medium: (35, 50),
        Difficulty.savage: (55, 90),
      },
    ),
    // Warrior III Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.warriorIIIHold,
      ranges: {
        Difficulty.easy: (8, 15),
        Difficulty.medium: (18, 30),
        Difficulty.savage: (35, 55),
      },
    ),
    // Crow Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.crowPoseHold,
      ranges: {
        Difficulty.easy: (5, 10),
        Difficulty.medium: (12, 22),
        Difficulty.savage: (25, 40),
      },
    ),
    // Pigeon Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.pigeonPoseHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 50),
        Difficulty.savage: (55, 90),
      },
    ),
    // Bridge Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.bridgePoseHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 75),
      },
    ),
    // Cat-Cow Cycles (reps)
    WorkoutTemplate(
      type: WorkoutType.catCowCycles,
      ranges: {
        Difficulty.easy: (6, 10),
        Difficulty.medium: (12, 18),
        Difficulty.savage: (20, 30),
      },
    ),
    // Low Lunge Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.lowLungeHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 45),
        Difficulty.savage: (50, 75),
      },
    ),
    // High Plank Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.highPlankHold,
      ranges: {
        Difficulty.easy: (15, 25),
        Difficulty.medium: (30, 50),
        Difficulty.savage: (55, 90),
      },
    ),
    // Goddess Pose Hold (seconds)
    WorkoutTemplate(
      type: WorkoutType.goddessPoseHold,
      ranges: {
        Difficulty.easy: (10, 20),
        Difficulty.medium: (25, 40),
        Difficulty.savage: (45, 70),
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
    WorkoutType.flutterKicks: ToneTemplates(
      commander: [
        '{amount} flutter kicks. Keep those legs straight!',
        'On your back! {amount} flutter kicks! Move!',
        '{amount} flutter kicks. Do not let your feet touch the ground!',
        'Flutter kicks! {amount}! Fast and controlled!',
      ],
      funny: [
        '{amount} flutter kicks. Pretend you\'re swimming on land.',
        'Do {amount} flutter kicks. Your abs didn\'t sign up for this.',
        '{amount} flutter kicks. Kick like a happy fish.',
        'Time for {amount} flutter kicks. Splash-free cardio.',
      ],
      chill: [
        '{amount} flutter kicks. Keep it steady.',
        'Let\'s do {amount} flutter kicks. Nice and easy.',
        'Try {amount} flutter kicks when you\'re ready.',
        '{amount} flutter kicks. Breathe through it.',
      ],
    ),
    WorkoutType.bicycleCrunches: ToneTemplates(
      commander: [
        '{amount} bicycle crunches. Full rotation! Go!',
        'Pedal it out! {amount} bicycle crunches!',
        '{amount} bicycle crunches. Touch elbow to knee!',
        'Bicycle crunches! {amount}! No slacking!',
      ],
      funny: [
        '{amount} bicycle crunches. Tour de Floor.',
        'Do {amount} bicycle crunches. Free bike ride, no bike needed.',
        '{amount} bicycle crunches. Pretend you\'re cycling to pizza.',
        'Pedal away! {amount} bicycle crunches. Zero miles traveled.',
      ],
      chill: [
        '{amount} bicycle crunches. Slow and controlled.',
        'Let\'s do {amount} bicycle crunches. Easy rhythm.',
        'Try {amount} bicycle crunches. Take your time.',
        '{amount} bicycle crunches. Feel each rep.',
      ],
    ),
    WorkoutType.gluteBridges: ToneTemplates(
      commander: [
        '{amount} glute bridges. Squeeze at the top!',
        'Bridge up! {amount} reps! Full extension!',
        '{amount} glute bridges. Hold the squeeze!',
        'Glute bridges! {amount}! Don\'t drop your hips!',
      ],
      funny: [
        '{amount} glute bridges. Build a bridge and get over it.',
        'Do {amount} glute bridges. Your backside will appreciate this.',
        '{amount} glute bridges. The only bridge that builds you.',
        'Bridge time! {amount} reps. Structural engineering for your body.',
      ],
      chill: [
        '{amount} glute bridges. Nice and controlled.',
        'Let\'s do {amount} glute bridges. Easy pace.',
        'Try {amount} glute bridges. Squeeze at the top.',
        '{amount} glute bridges. No rush.',
      ],
    ),
    WorkoutType.supermanHold: ToneTemplates(
      commander: [
        'Superman hold. {amount} seconds. Arms and legs up!',
        '{amount} seconds superman hold. Off the ground! Now!',
        'Hold superman position for {amount} seconds. Don\'t drop!',
        '{amount}-second superman hold. Like steel, soldier!',
      ],
      funny: [
        'Superman hold for {amount} seconds. Cape not included.',
        '{amount} seconds of flying on your stomach. You\'re basically a superhero.',
        'Hold superman for {amount} seconds. No phone booth required.',
        '{amount}-second superman hold. Saving the world, one second at a time.',
      ],
      chill: [
        'Superman hold for {amount} seconds. You got this.',
        '{amount}-second superman hold. Breathe steady.',
        'Try a {amount}-second superman hold.',
        'Hold superman position for {amount} seconds. Easy.',
      ],
    ),
    WorkoutType.legRaises: ToneTemplates(
      commander: [
        '{amount} leg raises. Legs straight! Go!',
        'On your back! {amount} leg raises! Now!',
        '{amount} leg raises. Control the motion!',
        'Leg raises! {amount}! Slow on the way down!',
      ],
      funny: [
        '{amount} leg raises. Your lower abs called in a complaint.',
        'Do {amount} leg raises. Defy gravity with your legs.',
        '{amount} leg raises. It\'s just pointing your feet at the ceiling. Repeatedly.',
        'Raise those legs {amount} times. The ceiling needs to see your shoes.',
      ],
      chill: [
        '{amount} leg raises. Take it slow.',
        'Let\'s do {amount} leg raises. Controlled and steady.',
        'Try {amount} leg raises when you\'re ready.',
        '{amount} leg raises. Easy does it.',
      ],
    ),
    WorkoutType.starJumps: ToneTemplates(
      commander: [
        '{amount} star jumps. Full extension! Explode!',
        'Star jumps! {amount}! Max effort!',
        '{amount} star jumps. Spread wide and jump high!',
        'Jump! {amount} star jumps! Like your life depends on it!',
      ],
      funny: [
        '{amount} star jumps. Be the star you already are.',
        'Do {amount} star jumps. You\'ll look ridiculous. Do it anyway.',
        '{amount} star jumps. Jumping jacks\' dramatic cousin.',
        'Star jump {amount} times. Hollywood audition starts now.',
      ],
      chill: [
        '{amount} star jumps. Quick burst of energy.',
        'Let\'s do {amount} star jumps. Have fun with it.',
        'Try {amount} star jumps. Light and bouncy.',
        '{amount} star jumps whenever you\'re ready.',
      ],
    ),
    WorkoutType.lateralLunges: ToneTemplates(
      commander: [
        '{amount} lateral lunges. Side to side! Move!',
        'Lateral lunges! {amount}! Deep and controlled!',
        '{amount} lateral lunges. Push off hard!',
        'Side lunges! {amount}! Full range of motion!',
      ],
      funny: [
        '{amount} lateral lunges. Crab people training starts now.',
        'Do {amount} lateral lunges. Sideways is a direction too.',
        '{amount} lateral lunges. Your inner thighs didn\'t see this coming.',
        'Slide into {amount} lateral lunges. No DMs involved.',
      ],
      chill: [
        '{amount} lateral lunges. Nice and smooth.',
        'Let\'s do {amount} lateral lunges. Side to side.',
        'Try {amount} lateral lunges. Easy pace.',
        '{amount} lateral lunges. Stretch into it.',
      ],
    ),
    WorkoutType.inchworms: ToneTemplates(
      commander: [
        '{amount} inchworms. Walk it out! Go!',
        'Inchworms! {amount}! Hands to the floor!',
        '{amount} inchworms. Full extension at the bottom!',
        'Walk it out! {amount} inchworms! Move!',
      ],
      funny: [
        '{amount} inchworms. Crawl your way to fitness.',
        'Do {amount} inchworms. You\'re a caterpillar before the butterfly.',
        '{amount} inchworms. Touching your toes was never this exhausting.',
        'Inchworm {amount} times. Longest commute of your life.',
      ],
      chill: [
        '{amount} inchworms. Slow and controlled.',
        'Let\'s do {amount} inchworms. Walk it out.',
        'Try {amount} inchworms. Take your time.',
        '{amount} inchworms. Feel the stretch.',
      ],
    ),
    WorkoutType.jumpSquats: ToneTemplates(
      commander: [
        '{amount} jump squats. Explode up! Go!',
        'Jump squats! {amount}! Full power!',
        '{amount} jump squats. Get airborne, soldier!',
        'Launch! {amount} jump squats! No weak jumps!',
      ],
      funny: [
        '{amount} jump squats. Squats, but with flair.',
        'Do {amount} jump squats. Defy gravity briefly.',
        '{amount} jump squats. Your downstairs neighbors love this.',
        'Bounce through {amount} jump squats. Be a human pogo stick.',
      ],
      chill: [
        '{amount} jump squats. Land soft.',
        'Let\'s do {amount} jump squats. Nice and controlled.',
        'Try {amount} jump squats at your own pace.',
        '{amount} jump squats. Easy landings.',
      ],
    ),
    WorkoutType.diamondPushups: ToneTemplates(
      commander: [
        '{amount} diamond pushups. Hands together! Go!',
        'Diamond pushups! {amount}! Tight form!',
        '{amount} diamond pushups. Triceps burning is success!',
        'Diamonds! {amount}! Full range! Execute!',
      ],
      funny: [
        '{amount} diamond pushups. Fancy pushups for fancy people.',
        'Do {amount} diamond pushups. Your triceps send their complaints.',
        '{amount} diamond pushups. Diamonds are forever, this set isn\'t.',
        'Make a diamond and push {amount} times. Jewelry-free workout.',
      ],
      chill: [
        '{amount} diamond pushups. Keep it controlled.',
        'Let\'s try {amount} diamond pushups. Hands close together.',
        '{amount} diamond pushups. Go at your pace.',
        'Try {amount} diamond pushups. Take breaks if needed.',
      ],
    ),
    WorkoutType.widePushups: ToneTemplates(
      commander: [
        '{amount} wide pushups. Hands wide! Chest to floor!',
        'Wide pushups! {amount}! Spread out and push!',
        '{amount} wide pushups. Full range of motion!',
        'Go wide! {amount} pushups! Move it!',
      ],
      funny: [
        '{amount} wide pushups. Spread your wings and push.',
        'Do {amount} wide pushups. Wingspan workout.',
        '{amount} wide pushups. Your chest called — it wants attention.',
        'Time for {amount} wide pushups. Eagle style.',
      ],
      chill: [
        '{amount} wide pushups. Nice and steady.',
        'Let\'s do {amount} wide pushups. Easy pace.',
        'Try {amount} wide pushups. Broader grip, same you.',
        '{amount} wide pushups. Take your time.',
      ],
    ),
    WorkoutType.pikePushups: ToneTemplates(
      commander: [
        '{amount} pike pushups. Hips high! Go!',
        'Pike pushups! {amount}! Head toward the floor!',
        '{amount} pike pushups. Shoulders are the target!',
        'Pike position! {amount} pushups! Move!',
      ],
      funny: [
        '{amount} pike pushups. Downward dog meets pushup.',
        'Do {amount} pike pushups. Yoga\'s aggressive cousin.',
        '{amount} pike pushups. Your shoulders didn\'t see this coming.',
        'Bend over and push {amount} times. It\'s called fitness.',
      ],
      chill: [
        '{amount} pike pushups. Stay controlled.',
        'Let\'s try {amount} pike pushups. Hips stay high.',
        '{amount} pike pushups whenever you\'re ready.',
        'Try {amount} pike pushups. Take it easy.',
      ],
    ),
    WorkoutType.shoulderTaps: ToneTemplates(
      commander: [
        '{amount} shoulder taps. Plank position! Go!',
        'Shoulder taps! {amount}! Don\'t rock those hips!',
        '{amount} shoulder taps. Solid core! Execute!',
        'Tap! {amount} shoulder taps! Stay tight!',
      ],
      funny: [
        '{amount} shoulder taps. Pat yourself on the shoulder. Literally.',
        'Do {amount} shoulder taps. Self-congratulation as exercise.',
        '{amount} shoulder taps. Your shoulders need reassurance.',
        'Tap those shoulders {amount} times. Good job, you.',
      ],
      chill: [
        '{amount} shoulder taps. Keep your hips still.',
        'Let\'s do {amount} shoulder taps. Nice and stable.',
        'Try {amount} shoulder taps. Easy rhythm.',
        '{amount} shoulder taps. No rush.',
      ],
    ),
    WorkoutType.russianTwists: ToneTemplates(
      commander: [
        '{amount} Russian twists. Full rotation! Go!',
        'Russian twists! {amount}! Touch each side!',
        '{amount} Russian twists. Obliques on fire!',
        'Twist! {amount}! Fast and controlled!',
      ],
      funny: [
        '{amount} Russian twists. No passport required.',
        'Do {amount} Russian twists. Your obliques have been summoned.',
        '{amount} Russian twists. Pretend you\'re dodging responsibilities.',
        'Twist {amount} times. International core training.',
      ],
      chill: [
        '{amount} Russian twists. Steady rotation.',
        'Let\'s do {amount} Russian twists. Side to side.',
        'Try {amount} Russian twists. Stay balanced.',
        '{amount} Russian twists. Breathe through each one.',
      ],
    ),
    WorkoutType.vUps: ToneTemplates(
      commander: [
        '{amount} V-ups. Hands to toes! Go!',
        'V-ups! {amount}! Full extension!',
        '{amount} V-ups. Touch your feet at the top!',
        'Fold and snap! {amount} V-ups! Now!',
      ],
      funny: [
        '{amount} V-ups. Make yourself a human jackknife.',
        'Do {amount} V-ups. Your abs will write an angry letter.',
        '{amount} V-ups. It\'s like a sit-up had an upgrade.',
        'V-up {amount} times. The V stands for very hard.',
      ],
      chill: [
        '{amount} V-ups. Take your time with each one.',
        'Let\'s do {amount} V-ups. Controlled movement.',
        'Try {amount} V-ups. Reach for your toes.',
        '{amount} V-ups. Go at your own pace.',
      ],
    ),
    WorkoutType.reverseCrunches: ToneTemplates(
      commander: [
        '{amount} reverse crunches. Knees to chest! Go!',
        'Reverse crunches! {amount}! Lift those hips!',
        '{amount} reverse crunches. Lower abs engaged!',
        'Crunch it! {amount} reverse crunches! Move!',
      ],
      funny: [
        '{amount} reverse crunches. Crunches, but backwards. Revolutionary.',
        'Do {amount} reverse crunches. Confuse your abs.',
        '{amount} reverse crunches. Your lower abs are hiding. Find them.',
        'Reverse crunch {amount} times. Uno reverse for your core.',
      ],
      chill: [
        '{amount} reverse crunches. Slow and steady.',
        'Let\'s do {amount} reverse crunches. Easy does it.',
        'Try {amount} reverse crunches. Breathe through it.',
        '{amount} reverse crunches. Nice and controlled.',
      ],
    ),
    WorkoutType.donkeyKicks: ToneTemplates(
      commander: [
        '{amount} donkey kicks. Each leg! Fire those glutes!',
        'Donkey kicks! {amount}! Kick it back! Hard!',
        '{amount} donkey kicks. Squeeze at the top!',
        'Kick! {amount} donkey kicks! Full extension!',
      ],
      funny: [
        '{amount} donkey kicks. Channel your inner donkey.',
        'Do {amount} donkey kicks. Hee-haw your way to fitness.',
        '{amount} donkey kicks. Your glutes haven\'t had this much fun.',
        'Kick back {amount} times. Donkey style. Don\'t ask questions.',
      ],
      chill: [
        '{amount} donkey kicks. Smooth and controlled.',
        'Let\'s do {amount} donkey kicks. Feel the glutes.',
        'Try {amount} donkey kicks. No rush.',
        '{amount} donkey kicks. Easy pace.',
      ],
    ),
    WorkoutType.fireHydrants: ToneTemplates(
      commander: [
        '{amount} fire hydrants. Each side! Open up!',
        'Fire hydrants! {amount}! Hips open! Go!',
        '{amount} fire hydrants. Full range of motion!',
        'Lift! {amount} fire hydrants! Don\'t cheat the range!',
      ],
      funny: [
        '{amount} fire hydrants. Named after dogs for a reason.',
        'Do {amount} fire hydrants. Your hips will thank you. Dogs will judge you.',
        '{amount} fire hydrants. The most awkward-looking effective exercise.',
        'Fire hydrant {amount} times. Woof.',
      ],
      chill: [
        '{amount} fire hydrants. Open those hips.',
        'Let\'s do {amount} fire hydrants. Easy movement.',
        'Try {amount} fire hydrants. Stay balanced.',
        '{amount} fire hydrants. Slow and controlled.',
      ],
    ),
    WorkoutType.birdDogs: ToneTemplates(
      commander: [
        '{amount} bird dogs. Opposite arm and leg! Go!',
        'Bird dogs! {amount}! Perfect balance!',
        '{amount} bird dogs. Core tight! Don\'t wobble!',
        'Extend! {amount} bird dogs! Control it!',
      ],
      funny: [
        '{amount} bird dogs. Half bird, half dog, all fitness.',
        'Do {amount} bird dogs. Balance like a flamingo, loyalty like a dog.',
        '{amount} bird dogs. If you fall over, it doesn\'t count.',
        'Bird dog {amount} times. Animal hybrid training.',
      ],
      chill: [
        '{amount} bird dogs. Focus on balance.',
        'Let\'s do {amount} bird dogs. Slow extension.',
        'Try {amount} bird dogs. Steady and controlled.',
        '{amount} bird dogs. Take your time.',
      ],
    ),
    WorkoutType.deadBugs: ToneTemplates(
      commander: [
        '{amount} dead bugs. Arms and legs moving! Go!',
        'Dead bugs! {amount}! Keep your back flat!',
        '{amount} dead bugs. Core engaged the whole time!',
        'On your back! {amount} dead bugs! Execute!',
      ],
      funny: [
        '{amount} dead bugs. Play dead but keep moving.',
        'Do {amount} dead bugs. You\'ll look silly. Your core won\'t care.',
        '{amount} dead bugs. The most dramatic core exercise.',
        'Flail around {amount} times. Controlled flailing. That\'s the key.',
      ],
      chill: [
        '{amount} dead bugs. Keep your back pressed down.',
        'Let\'s do {amount} dead bugs. Nice and controlled.',
        'Try {amount} dead bugs. Easy rhythm.',
        '{amount} dead bugs. Breathe steadily.',
      ],
    ),
    WorkoutType.scissorKicks: ToneTemplates(
      commander: [
        '{amount} scissor kicks. Legs straight! Go!',
        'Scissor kicks! {amount}! Don\'t let your feet drop!',
        '{amount} scissor kicks. Cross and switch! Fast!',
        'Kick! {amount} scissor kicks! Keep them elevated!',
      ],
      funny: [
        '{amount} scissor kicks. Pretend you\'re cutting invisible paper.',
        'Do {amount} scissor kicks. Legs: the scissors. Air: the paper.',
        '{amount} scissor kicks. Edward Scissorhands workout.',
        'Snip snip! {amount} scissor kicks. Craft time for your abs.',
      ],
      chill: [
        '{amount} scissor kicks. Keep it steady.',
        'Let\'s do {amount} scissor kicks. Alternate smoothly.',
        'Try {amount} scissor kicks. Easy pace.',
        '{amount} scissor kicks. Breathe through it.',
      ],
    ),
    WorkoutType.tuckJumps: ToneTemplates(
      commander: [
        '{amount} tuck jumps. Knees to chest! Explode!',
        'Tuck jumps! {amount}! Max height!',
        '{amount} tuck jumps. Pull those knees up!',
        'Jump and tuck! {amount}! Full power!',
      ],
      funny: [
        '{amount} tuck jumps. Cannonball without the pool.',
        'Do {amount} tuck jumps. Become briefly airborne.',
        '{amount} tuck jumps. Your knees and chest: a love story.',
        'Tuck and jump {amount} times. Gravity is just a suggestion.',
      ],
      chill: [
        '{amount} tuck jumps. Land softly.',
        'Let\'s do {amount} tuck jumps. Take breaks if needed.',
        'Try {amount} tuck jumps. At your own pace.',
        '{amount} tuck jumps. Rest between reps.',
      ],
    ),
    WorkoutType.skaters: ToneTemplates(
      commander: [
        '{amount} skaters. Side to side! Full reach!',
        'Skaters! {amount}! Push off hard!',
        '{amount} skaters. Land and hold! Control!',
        'Leap! {amount} skaters! Each side!',
      ],
      funny: [
        '{amount} skaters. Ice skating without the ice or the skating.',
        'Do {amount} skaters. Side-hop your way to glory.',
        '{amount} skaters. Olympic training starts here.',
        'Glide through {amount} skaters. No rink needed.',
      ],
      chill: [
        '{amount} skaters. Easy hops side to side.',
        'Let\'s do {amount} skaters. Light and controlled.',
        'Try {amount} skaters. Find your rhythm.',
        '{amount} skaters. No rush.',
      ],
    ),
    WorkoutType.frogJumps: ToneTemplates(
      commander: [
        '{amount} frog jumps. Deep squat! Explode up!',
        'Frog jumps! {amount}! Jump forward! Now!',
        '{amount} frog jumps. Power from the legs!',
        'Leap! {amount} frog jumps! Full send!',
      ],
      funny: [
        '{amount} frog jumps. Ribbit your way to fitness.',
        'Do {amount} frog jumps. Embrace your inner amphibian.',
        '{amount} frog jumps. Hop to it. Literally.',
        'Frog jump {amount} times. Kiss a prince on the way up.',
      ],
      chill: [
        '{amount} frog jumps. Deep squat, gentle jump.',
        'Let\'s do {amount} frog jumps. Take it easy.',
        'Try {amount} frog jumps. Land soft.',
        '{amount} frog jumps. At your own pace.',
      ],
    ),
    WorkoutType.curtsyLunges: ToneTemplates(
      commander: [
        '{amount} curtsy lunges. Cross behind! Deep! Go!',
        'Curtsy lunges! {amount}! Full depth!',
        '{amount} curtsy lunges. Control the crossover!',
        'Cross and drop! {amount} curtsy lunges!',
      ],
      funny: [
        '{amount} curtsy lunges. Bow to the queen of fitness.',
        'Do {amount} curtsy lunges. Fancy lunges for fancy legs.',
        '{amount} curtsy lunges. Royal workout protocol.',
        'Curtsy {amount} times. Your Majesty would approve.',
      ],
      chill: [
        '{amount} curtsy lunges. Smooth crossover.',
        'Let\'s do {amount} curtsy lunges. Nice and easy.',
        'Try {amount} curtsy lunges. Balance is key.',
        '{amount} curtsy lunges. Take your time.',
      ],
    ),
    WorkoutType.squatPulses: ToneTemplates(
      commander: [
        '{amount} squat pulses. Stay low! Pulse it!',
        'Squat pulses! {amount}! Don\'t come up!',
        '{amount} squat pulses. Feel the burn! Stay down!',
        'Pulse! {amount}! Keep those legs loaded!',
      ],
      funny: [
        '{amount} squat pulses. Tiny squats with maximum regret.',
        'Do {amount} squat pulses. Your thighs are about to file a complaint.',
        '{amount} squat pulses. Bouncing in place, but make it painful.',
        'Pulse {amount} times. Your legs will shake. That\'s normal.',
      ],
      chill: [
        '{amount} squat pulses. Stay in the squat and pulse.',
        'Let\'s do {amount} squat pulses. Gentle bouncing.',
        'Try {amount} squat pulses. Keep it small.',
        '{amount} squat pulses. Breathe through the burn.',
      ],
    ),
    WorkoutType.plankJacks: ToneTemplates(
      commander: [
        '{amount} plank jacks. In plank! Feet in and out!',
        'Plank jacks! {amount}! Fast feet! Go!',
        '{amount} plank jacks. Don\'t drop your hips!',
        'Jack it! {amount} plank jacks! Core tight!',
      ],
      funny: [
        '{amount} plank jacks. Jumping jacks had a baby with a plank.',
        'Do {amount} plank jacks. Multitasking at its finest.',
        '{amount} plank jacks. Two exercises in one. Efficiency.',
        'Plank jack {amount} times. Your core and cardio in one move.',
      ],
      chill: [
        '{amount} plank jacks. Keep a steady rhythm.',
        'Let\'s do {amount} plank jacks. Easy pace.',
        'Try {amount} plank jacks. Stay stable up top.',
        '{amount} plank jacks. Breathe steadily.',
      ],
    ),
    WorkoutType.bearCrawlSteps: ToneTemplates(
      commander: [
        '{amount} bear crawl steps. Low to the ground! Move!',
        'Bear crawl! {amount} steps! Knees off the floor!',
        '{amount} bear crawl steps. Stay tight! Go!',
        'Crawl! {amount} steps! Like a bear! Fast!',
      ],
      funny: [
        '{amount} bear crawl steps. Unleash your inner grizzly.',
        'Do {amount} bear crawl steps. Crawling: it\'s not just for babies.',
        '{amount} bear crawl steps. The floor is your playground.',
        'Bear crawl {amount} steps. Terrify your pets.',
      ],
      chill: [
        '{amount} bear crawl steps. Stay low, move slow.',
        'Let\'s do {amount} bear crawl steps. Steady pace.',
        'Try {amount} bear crawl steps. Keep knees hovering.',
        '{amount} bear crawl steps. Take it easy.',
      ],
    ),
    WorkoutType.toeTouches: ToneTemplates(
      commander: [
        '{amount} toe touches. On your back! Reach up!',
        'Toe touches! {amount}! Legs vertical! Go!',
        '{amount} toe touches. Touch those toes every rep!',
        'Reach! {amount} toe touches! Full extension!',
      ],
      funny: [
        '{amount} toe touches. Finally, a reason to reach for your toes.',
        'Do {amount} toe touches. Your toes miss your fingers.',
        '{amount} toe touches. The reunion your body needed.',
        'Touch your toes {amount} times. They\'ve been waiting.',
      ],
      chill: [
        '{amount} toe touches. Legs up, reach and tap.',
        'Let\'s do {amount} toe touches. Controlled reach.',
        'Try {amount} toe touches. Nice and easy.',
        '{amount} toe touches. Breathe out as you reach.',
      ],
    ),
    WorkoutType.hipThrusts: ToneTemplates(
      commander: [
        '{amount} hip thrusts. Drive up! Squeeze!',
        'Hip thrusts! {amount}! Full lockout at the top!',
        '{amount} hip thrusts. Power through the hips!',
        'Thrust! {amount}! Max squeeze! Go!',
      ],
      funny: [
        '{amount} hip thrusts. The most confidently named exercise.',
        'Do {amount} hip thrusts. Your glutes will be sculpted. Eventually.',
        '{amount} hip thrusts. Awkward looking, extremely effective.',
        'Thrust {amount} times. No further comment needed.',
      ],
      chill: [
        '{amount} hip thrusts. Squeeze at the top.',
        'Let\'s do {amount} hip thrusts. Nice and controlled.',
        'Try {amount} hip thrusts. Feel the glutes work.',
        '{amount} hip thrusts. Easy pace.',
      ],
    ),
    WorkoutType.reverseLunges: ToneTemplates(
      commander: [
        '{amount} reverse lunges. Step back! Deep!',
        'Reverse lunges! {amount}! Control the step!',
        '{amount} reverse lunges. Full range! Go!',
        'Step back! {amount} reverse lunges! Execute!',
      ],
      funny: [
        '{amount} reverse lunges. Lunges, but in reverse. Innovation.',
        'Do {amount} reverse lunges. Walking backwards, but productive.',
        '{amount} reverse lunges. Your legs don\'t know which way is up.',
        'Reverse lunge {amount} times. Rewind those legs.',
      ],
      chill: [
        '{amount} reverse lunges. Step back gently.',
        'Let\'s do {amount} reverse lunges. Easy rhythm.',
        'Try {amount} reverse lunges. Controlled steps.',
        '{amount} reverse lunges. Take your time.',
      ],
    ),
    WorkoutType.sidePlankDips: ToneTemplates(
      commander: [
        '{amount} side plank dips. Each side! Dip and drive!',
        'Side plank dips! {amount}! Don\'t collapse!',
        '{amount} side plank dips. Obliques engaged!',
        'Dip! {amount} side plank dips! Hold that form!',
      ],
      funny: [
        '{amount} side plank dips. Dipping sideways is a skill.',
        'Do {amount} side plank dips. Your obliques didn\'t volunteer for this.',
        '{amount} side plank dips. Love handles hate this exercise.',
        'Side dip {amount} times. Salsa dancing for your core.',
      ],
      chill: [
        '{amount} side plank dips. Controlled dipping.',
        'Let\'s do {amount} side plank dips. Steady rhythm.',
        'Try {amount} side plank dips. Each side.',
        '{amount} side plank dips. Take it easy.',
      ],
    ),
    WorkoutType.crunches: ToneTemplates(
      commander: [
        '{amount} crunches. Core tight! Go!',
        'Crunches! {amount}! Don\'t pull your neck!',
        '{amount} crunches. Squeeze at the top!',
        'Crunch it! {amount}! Fast and controlled!',
      ],
      funny: [
        '{amount} crunches. The classic. The legend. The burn.',
        'Do {amount} crunches. Your abs remember these from gym class.',
        '{amount} crunches. Old school, still works.',
        'Crunch {amount} times. Breakfast isn\'t the only crunch today.',
      ],
      chill: [
        '{amount} crunches. Nice and easy.',
        'Let\'s do {amount} crunches. Slow and controlled.',
        'Try {amount} crunches. Breathe out on the crunch.',
        '{amount} crunches. Take your time.',
      ],
    ),
    WorkoutType.sidePlank: ToneTemplates(
      commander: [
        'Side plank. {amount} seconds. Each side! Hold!',
        '{amount}-second side plank. Don\'t drop!',
        'Hold that side plank for {amount} seconds! Solid!',
        '{amount} seconds side plank. Like a steel beam!',
      ],
      funny: [
        'Side plank for {amount} seconds. Lean into it. Literally.',
        '{amount}-second side plank. Pretend you\'re a human shelf.',
        'Hold a side plank for {amount} seconds. Your obliques send regards.',
        '{amount} seconds of side planking. Sideways suffering.',
      ],
      chill: [
        'Side plank for {amount} seconds. You got this.',
        '{amount}-second side plank. Stay steady.',
        'Try a {amount}-second side plank. Breathe.',
        'Hold side plank — {amount} seconds. Easy.',
      ],
    ),
    WorkoutType.hollowBodyHold: ToneTemplates(
      commander: [
        'Hollow body hold. {amount} seconds. Arms overhead! Hold!',
        '{amount}-second hollow body hold. Stay tight!',
        'Hollow hold! {amount} seconds! Back flat on the floor!',
        '{amount} seconds hollow body. No arching! Execute!',
      ],
      funny: [
        'Hollow body hold for {amount} seconds. Become a banana.',
        '{amount}-second hollow hold. You\'re basically a canoe now.',
        'Hold hollow body for {amount} seconds. Abs will have opinions.',
        '{amount} seconds of being a hollow shell. Deep stuff.',
      ],
      chill: [
        'Hollow body hold, {amount} seconds. Press your back down.',
        '{amount}-second hollow hold. Steady breathing.',
        'Try a {amount}-second hollow body hold.',
        '{amount} seconds hollow hold. Stay relaxed but engaged.',
      ],
    ),
    WorkoutType.bearHold: ToneTemplates(
      commander: [
        'Bear hold. {amount} seconds. Knees hovering! Don\'t move!',
        '{amount}-second bear hold! Stay locked in!',
        'Hold the bear position for {amount} seconds! Solid!',
        '{amount} seconds bear hold. Knees one inch off the ground!',
      ],
      funny: [
        'Bear hold for {amount} seconds. Hibernation but harder.',
        '{amount}-second bear hold. Crouch like a bear. A very still bear.',
        'Hold bear position for {amount} seconds. Bear with me.',
        '{amount} seconds of bear holding. Growling optional.',
      ],
      chill: [
        'Bear hold, {amount} seconds. Hover those knees.',
        '{amount}-second bear hold. Breathe easy.',
        'Try a {amount}-second bear hold. Stay low.',
        '{amount} seconds bear hold. You got this.',
      ],
    ),
    WorkoutType.boatHold: ToneTemplates(
      commander: [
        'Boat hold. {amount} seconds. Legs up! Arms forward!',
        '{amount}-second boat hold! Don\'t sink!',
        'Hold boat position for {amount} seconds! Core engaged!',
        '{amount} seconds boat hold. Balance and power!',
      ],
      funny: [
        'Boat hold for {amount} seconds. Row, row, row your... never mind, just hold.',
        '{amount}-second boat hold. You\'re a human V. A very shaky V.',
        'Hold boat for {amount} seconds. No water, all struggle.',
        '{amount} seconds of boat hold. Don\'t capsize.',
      ],
      chill: [
        'Boat hold, {amount} seconds. Balance on your sit bones.',
        '{amount}-second boat hold. Stay steady.',
        'Try a {amount}-second boat hold. Breathe through it.',
        '{amount} seconds boat hold. Nice and calm.',
      ],
    ),
    WorkoutType.bridgeHold: ToneTemplates(
      commander: [
        'Bridge hold. {amount} seconds. Hips up! Squeeze!',
        '{amount}-second bridge hold! Lock those glutes!',
        'Hold bridge for {amount} seconds! No sagging!',
        '{amount} seconds bridge hold. Eyes on the ceiling!',
      ],
      funny: [
        'Bridge hold for {amount} seconds. Be the bridge your city needs.',
        '{amount}-second bridge hold. Engineering meets exercise.',
        'Hold bridge for {amount} seconds. Your glutes are the foundation.',
        '{amount} seconds being a bridge. Cars not included.',
      ],
      chill: [
        'Bridge hold, {amount} seconds. Hips up, relax your shoulders.',
        '{amount}-second bridge hold. Squeeze gently.',
        'Try a {amount}-second bridge hold. Easy.',
        '{amount} seconds bridge hold. Breathe steadily.',
      ],
    ),
    WorkoutType.warriorIHold: ToneTemplates(
      commander: [
        'Warrior I. {amount} seconds. Lunge deep! Arms up!',
        '{amount}-second Warrior I! Stand strong, soldier!',
        'Hold Warrior I for {amount} seconds! No wobbling!',
        '{amount} seconds Warrior I. Chest up! Power stance!',
      ],
      funny: [
        'Warrior I for {amount} seconds. Feel like a Viking.',
        '{amount}-second Warrior I. Yoga meets battle stance.',
        'Hold Warrior I for {amount} seconds. Conquer your living room.',
        '{amount} seconds of feeling like an ancient warrior. Namaste.',
      ],
      chill: [
        'Warrior I hold, {amount} seconds. Sink into it.',
        '{amount}-second Warrior I. Breathe deep.',
        'Try Warrior I for {amount} seconds. Find your balance.',
        '{amount} seconds Warrior I. Steady and calm.',
      ],
    ),
    WorkoutType.warriorIIHold: ToneTemplates(
      commander: [
        'Warrior II. {amount} seconds. Arms wide! Gaze forward!',
        '{amount}-second Warrior II! Hold that line!',
        'Hold Warrior II for {amount} seconds! Strong legs!',
        '{amount} seconds Warrior II. Don\'t drop those arms!',
      ],
      funny: [
        'Warrior II for {amount} seconds. Pretend you\'re surfing.',
        '{amount}-second Warrior II. Arms out like you\'re directing traffic.',
        'Hold Warrior II for {amount} seconds. T-pose with purpose.',
        '{amount} seconds of Warrior II. Your arms will have opinions.',
      ],
      chill: [
        'Warrior II, {amount} seconds. Open up wide.',
        '{amount}-second Warrior II. Steady gaze, steady breath.',
        'Try Warrior II for {amount} seconds. Find your flow.',
        '{amount} seconds Warrior II. Relax into it.',
      ],
    ),
    WorkoutType.chairPoseHold: ToneTemplates(
      commander: [
        'Chair pose. {amount} seconds. Sit back! Hold!',
        '{amount}-second chair pose! Thighs burning is success!',
        'Hold chair pose for {amount} seconds! No standing up!',
        '{amount} seconds chair pose. Dig in! Don\'t quit!',
      ],
      funny: [
        'Chair pose for {amount} seconds. Sitting without a chair. Revolutionary.',
        '{amount}-second chair pose. The invisible chair workout.',
        'Hold chair pose for {amount} seconds. Your thighs will file a complaint.',
        '{amount} seconds of sitting on nothing. Welcome to yoga.',
      ],
      chill: [
        'Chair pose, {amount} seconds. Sit back and breathe.',
        '{amount}-second chair pose. Keep your weight in your heels.',
        'Try chair pose for {amount} seconds. You got this.',
        '{amount} seconds chair pose. Steady and calm.',
      ],
    ),
    WorkoutType.treePoseHold: ToneTemplates(
      commander: [
        'Tree pose. {amount} seconds. Each leg! Don\'t fall!',
        '{amount}-second tree pose! Root down! Stand tall!',
        'Hold tree pose for {amount} seconds! Perfect balance!',
        '{amount} seconds tree pose. Still as a redwood!',
      ],
      funny: [
        'Tree pose for {amount} seconds. Be the tree.',
        '{amount}-second tree pose. Photosynthesis not required.',
        'Hold tree pose for {amount} seconds. Try not to timber.',
        '{amount} seconds as a tree. Birds may land on you.',
      ],
      chill: [
        'Tree pose, {amount} seconds. Find a focal point.',
        '{amount}-second tree pose. Breathe and balance.',
        'Try tree pose for {amount} seconds. Sway is natural.',
        '{amount} seconds tree pose. Gentle and grounded.',
      ],
    ),
    WorkoutType.downwardDogHold: ToneTemplates(
      commander: [
        'Downward dog. {amount} seconds. Hips high! Push back!',
        '{amount}-second downward dog! Heels toward the floor!',
        'Hold downward dog for {amount} seconds! Straight arms!',
        '{amount} seconds downward dog. Press through your hands!',
      ],
      funny: [
        'Downward dog for {amount} seconds. Your dog does this for free.',
        '{amount}-second downward dog. The most famous yoga pose. Own it.',
        'Hold downward dog for {amount} seconds. Look at the world upside down.',
        '{amount} seconds of downward dog. Your hamstrings say hello.',
      ],
      chill: [
        'Downward dog, {amount} seconds. Pedal out your feet.',
        '{amount}-second downward dog. Breathe into it.',
        'Try downward dog for {amount} seconds. Relax your neck.',
        '{amount} seconds downward dog. Easy stretch.',
      ],
    ),
    WorkoutType.cobraPoseHold: ToneTemplates(
      commander: [
        'Cobra pose. {amount} seconds. Chest up! Shoulders back!',
        '{amount}-second cobra! Open that chest!',
        'Hold cobra for {amount} seconds! Don\'t shrug!',
        '{amount} seconds cobra pose. Strong back! Hold it!',
      ],
      funny: [
        'Cobra pose for {amount} seconds. Hiss optional.',
        '{amount}-second cobra. Slither your way to a better back.',
        'Hold cobra for {amount} seconds. Snake charmer not included.',
        '{amount} seconds of cobra. You\'re dangerously flexible now.',
      ],
      chill: [
        'Cobra pose, {amount} seconds. Gentle backbend.',
        '{amount}-second cobra. Keep your elbows soft.',
        'Try cobra pose for {amount} seconds. Open your chest.',
        '{amount} seconds cobra. Breathe easy.',
      ],
    ),
    WorkoutType.childsPoseHold: ToneTemplates(
      commander: [
        'Child\'s pose. {amount} seconds. Recover and reset!',
        '{amount}-second child\'s pose. Active recovery! Stay focused!',
        'Hold child\'s pose for {amount} seconds. Earn this rest!',
        '{amount} seconds child\'s pose. Breathe deep. Prepare for more.',
      ],
      funny: [
        'Child\'s pose for {amount} seconds. Nap time, but productive.',
        '{amount}-second child\'s pose. The yoga pose where you pretend to nap.',
        'Hold child\'s pose for {amount} seconds. You\'ve earned this hug from the floor.',
        '{amount} seconds of child\'s pose. Adulting pause activated.',
      ],
      chill: [
        'Child\'s pose, {amount} seconds. Let everything go.',
        '{amount}-second child\'s pose. Deep breaths.',
        'Try child\'s pose for {amount} seconds. Pure relaxation.',
        '{amount} seconds child\'s pose. Melt into the mat.',
      ],
    ),
    WorkoutType.warriorIIIHold: ToneTemplates(
      commander: [
        'Warrior III. {amount} seconds. Each leg! Fly!',
        '{amount}-second Warrior III! Body parallel to the floor!',
        'Hold Warrior III for {amount} seconds! Don\'t drop!',
        '{amount} seconds Warrior III. Like a fighter jet!',
      ],
      funny: [
        'Warrior III for {amount} seconds. Airplane mode: activated.',
        '{amount}-second Warrior III. Balance level: expert.',
        'Hold Warrior III for {amount} seconds. Superman meets yoga.',
        '{amount} seconds of Warrior III. Try not to face-plant.',
      ],
      chill: [
        'Warrior III, {amount} seconds. Find your balance point.',
        '{amount}-second Warrior III. Steady and focused.',
        'Try Warrior III for {amount} seconds. Use a wall if needed.',
        '{amount} seconds Warrior III. Breathe through it.',
      ],
    ),
    WorkoutType.crowPoseHold: ToneTemplates(
      commander: [
        'Crow pose. {amount} seconds. Lean forward! Lift!',
        '{amount}-second crow pose! Trust your arms!',
        'Hold crow for {amount} seconds! Core engaged!',
        '{amount} seconds crow pose. Fly, soldier!',
      ],
      funny: [
        'Crow pose for {amount} seconds. Become a bird. A wobbly bird.',
        '{amount}-second crow pose. Falling on your face builds character.',
        'Hold crow for {amount} seconds. Gravity is just a suggestion.',
        '{amount} seconds of crow. Caw caw. That\'s the spirit.',
      ],
      chill: [
        'Crow pose, {amount} seconds. Lean slowly, lift gently.',
        '{amount}-second crow pose. Place a pillow in front. Just in case.',
        'Try crow pose for {amount} seconds. Baby steps.',
        '{amount} seconds crow pose. You\'re braver than you think.',
      ],
    ),
    WorkoutType.pigeonPoseHold: ToneTemplates(
      commander: [
        'Pigeon pose. {amount} seconds. Each side! Deep stretch!',
        '{amount}-second pigeon pose! Open those hips!',
        'Hold pigeon for {amount} seconds! Sink into it!',
        '{amount} seconds pigeon pose. No shortcuts!',
      ],
      funny: [
        'Pigeon pose for {amount} seconds. Coo coo. Hip opener incoming.',
        '{amount}-second pigeon pose. Your hips are holding secrets. Release them.',
        'Hold pigeon for {amount} seconds. Named after a bird that can barely fly. Relatable.',
        '{amount} seconds of pigeon. Your hip flexors didn\'t see this coming.',
      ],
      chill: [
        'Pigeon pose, {amount} seconds. Let your hips relax.',
        '{amount}-second pigeon pose. Breathe into the stretch.',
        'Try pigeon pose for {amount} seconds. Ease into it.',
        '{amount} seconds pigeon pose. Deep breaths.',
      ],
    ),
    WorkoutType.bridgePoseHold: ToneTemplates(
      commander: [
        'Bridge pose. {amount} seconds. Lift and squeeze!',
        '{amount}-second bridge pose! Hips toward the ceiling!',
        'Hold bridge pose for {amount} seconds! Glutes engaged!',
        '{amount} seconds bridge pose. Drive those hips up!',
      ],
      funny: [
        'Bridge pose for {amount} seconds. Yoga bridge. Toll-free.',
        '{amount}-second bridge pose. Your spine says thank you.',
        'Hold bridge pose for {amount} seconds. Connect body and floor. Architecturally.',
        '{amount} seconds of bridge pose. Structural integrity required.',
      ],
      chill: [
        'Bridge pose, {amount} seconds. Lift gently.',
        '{amount}-second bridge pose. Breathe and hold.',
        'Try bridge pose for {amount} seconds. Relax your neck.',
        '{amount} seconds bridge pose. Nice and easy.',
      ],
    ),
    WorkoutType.catCowCycles: ToneTemplates(
      commander: [
        '{amount} cat-cow cycles. Arch and round! Flow!',
        'Cat-cow! {amount} cycles! Full spine movement!',
        '{amount} cat-cow cycles. Breathe in: cow. Breathe out: cat. Go!',
        'Flow! {amount} cat-cow cycles! Warm up that spine!',
      ],
      funny: [
        '{amount} cat-cow cycles. Meow meets moo.',
        'Do {amount} cat-cow cycles. Be two animals at once.',
        '{amount} cat-cow cycles. Your spine\'s favorite bedtime story.',
        'Cat-cow {amount} times. The barnyard yoga experience.',
      ],
      chill: [
        '{amount} cat-cow cycles. Flow with your breath.',
        'Let\'s do {amount} cat-cow cycles. Slow and rhythmic.',
        'Try {amount} cat-cow cycles. Feel each vertebra.',
        '{amount} cat-cow cycles. Easy spinal warmup.',
      ],
    ),
    WorkoutType.lowLungeHold: ToneTemplates(
      commander: [
        'Low lunge. {amount} seconds. Each side! Sink deep!',
        '{amount}-second low lunge! Stretch those hip flexors!',
        'Hold low lunge for {amount} seconds! Arms overhead!',
        '{amount} seconds low lunge. Deep and strong!',
      ],
      funny: [
        'Low lunge for {amount} seconds. Dramatic proposal stance.',
        '{amount}-second low lunge. Your hip flexors need this talk.',
        'Hold low lunge for {amount} seconds. One knee down, all the stretch.',
        '{amount} seconds of low lunge. Knighting yourself. Rise, Sir Flex.',
      ],
      chill: [
        'Low lunge, {amount} seconds. Ease into the stretch.',
        '{amount}-second low lunge. Let gravity do the work.',
        'Try low lunge for {amount} seconds. Breathe deeply.',
        '{amount} seconds low lunge. Gentle hip opener.',
      ],
    ),
    WorkoutType.highPlankHold: ToneTemplates(
      commander: [
        'High plank. {amount} seconds. Locked arms! Solid core!',
        '{amount}-second high plank! Straight line! Don\'t sag!',
        'Hold high plank for {amount} seconds! Like steel!',
        '{amount} seconds high plank. No breaks! Hold it!',
      ],
      funny: [
        'High plank for {amount} seconds. Plank but with straight arms. Upgrade.',
        '{amount}-second high plank. The top of a pushup. Just... stay there.',
        'Hold high plank for {amount} seconds. Time moves slower here.',
        '{amount} seconds of high plank. Your arms will question your decisions.',
      ],
      chill: [
        'High plank, {amount} seconds. Straight and steady.',
        '{amount}-second high plank. Breathe through it.',
        'Try high plank for {amount} seconds. You got this.',
        '{amount} seconds high plank. Calm and strong.',
      ],
    ),
    WorkoutType.goddessPoseHold: ToneTemplates(
      commander: [
        'Goddess pose. {amount} seconds. Wide stance! Bend those knees!',
        '{amount}-second goddess pose! Own it! Power stance!',
        'Hold goddess pose for {amount} seconds! Regal and strong!',
        '{amount} seconds goddess pose. Inner thighs on fire!',
      ],
      funny: [
        'Goddess pose for {amount} seconds. Channel your divine energy.',
        '{amount}-second goddess pose. Fancy squat? Nah, it\'s a goddess thing.',
        'Hold goddess pose for {amount} seconds. Feel like a Greek statue.',
        '{amount} seconds of goddess pose. Mount Olympus training.',
      ],
      chill: [
        'Goddess pose, {amount} seconds. Wide and grounded.',
        '{amount}-second goddess pose. Relax your shoulders.',
        'Try goddess pose for {amount} seconds. Strong and calm.',
        '{amount} seconds goddess pose. Breathe into your power.',
      ],
    ),
  };
}
