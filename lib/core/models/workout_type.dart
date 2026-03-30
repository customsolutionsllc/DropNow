enum WorkoutType {
  pushups,
  squats,
  jumpingJacks,
  plank,
  lunges,
  wallSit,
  sitUps,
  burpees,
  highKnees,
  mountainClimbers,
  calfRaises,
  tricepDips,
  flutterKicks,
  bicycleCrunches,
  gluteBridges,
  supermanHold,
  legRaises,
  starJumps,
  lateralLunges,
  inchworms,
  jumpSquats,
  diamondPushups,
  widePushups,
  pikePushups,
  shoulderTaps,
  russianTwists,
  vUps,
  reverseCrunches,
  donkeyKicks,
  fireHydrants,
  birdDogs,
  deadBugs,
  scissorKicks,
  tuckJumps,
  skaters,
  frogJumps,
  curtsyLunges,
  squatPulses,
  plankJacks,
  bearCrawlSteps,
  toeTouches,
  hipThrusts,
  reverseLunges,
  sidePlankDips,
  crunches,
  sidePlank,
  hollowBodyHold,
  bearHold,
  boatHold,
  bridgeHold,
  warriorIHold,
  warriorIIHold,
  chairPoseHold,
  treePoseHold,
  downwardDogHold,
  cobraPoseHold,
  childsPoseHold,
  warriorIIIHold,
  crowPoseHold,
  pigeonPoseHold,
  bridgePoseHold,
  catCowCycles,
  lowLungeHold,
  highPlankHold,
  goddessPoseHold,
}

extension WorkoutTypeExtension on WorkoutType {
  String get label {
    switch (this) {
      case WorkoutType.pushups:
        return 'Pushups';
      case WorkoutType.squats:
        return 'Squats';
      case WorkoutType.jumpingJacks:
        return 'Jumping Jacks';
      case WorkoutType.plank:
        return 'Plank';
      case WorkoutType.lunges:
        return 'Lunges';
      case WorkoutType.wallSit:
        return 'Wall Sit';
      case WorkoutType.sitUps:
        return 'Sit-Ups';
      case WorkoutType.burpees:
        return 'Burpees';
      case WorkoutType.highKnees:
        return 'High Knees';
      case WorkoutType.mountainClimbers:
        return 'Mountain Climbers';
      case WorkoutType.calfRaises:
        return 'Calf Raises';
      case WorkoutType.tricepDips:
        return 'Tricep Dips';
      case WorkoutType.flutterKicks:
        return 'Flutter Kicks';
      case WorkoutType.bicycleCrunches:
        return 'Bicycle Crunches';
      case WorkoutType.gluteBridges:
        return 'Glute Bridges';
      case WorkoutType.supermanHold:
        return 'Superman Hold';
      case WorkoutType.legRaises:
        return 'Leg Raises';
      case WorkoutType.starJumps:
        return 'Star Jumps';
      case WorkoutType.lateralLunges:
        return 'Lateral Lunges';
      case WorkoutType.inchworms:
        return 'Inchworms';
      case WorkoutType.jumpSquats:
        return 'Jump Squats';
      case WorkoutType.diamondPushups:
        return 'Diamond Pushups';
      case WorkoutType.widePushups:
        return 'Wide Pushups';
      case WorkoutType.pikePushups:
        return 'Pike Pushups';
      case WorkoutType.shoulderTaps:
        return 'Shoulder Taps';
      case WorkoutType.russianTwists:
        return 'Russian Twists';
      case WorkoutType.vUps:
        return 'V-Ups';
      case WorkoutType.reverseCrunches:
        return 'Reverse Crunches';
      case WorkoutType.donkeyKicks:
        return 'Donkey Kicks';
      case WorkoutType.fireHydrants:
        return 'Fire Hydrants';
      case WorkoutType.birdDogs:
        return 'Bird Dogs';
      case WorkoutType.deadBugs:
        return 'Dead Bugs';
      case WorkoutType.scissorKicks:
        return 'Scissor Kicks';
      case WorkoutType.tuckJumps:
        return 'Tuck Jumps';
      case WorkoutType.skaters:
        return 'Skaters';
      case WorkoutType.frogJumps:
        return 'Frog Jumps';
      case WorkoutType.curtsyLunges:
        return 'Curtsy Lunges';
      case WorkoutType.squatPulses:
        return 'Squat Pulses';
      case WorkoutType.plankJacks:
        return 'Plank Jacks';
      case WorkoutType.bearCrawlSteps:
        return 'Bear Crawl Steps';
      case WorkoutType.toeTouches:
        return 'Toe Touches';
      case WorkoutType.hipThrusts:
        return 'Hip Thrusts';
      case WorkoutType.reverseLunges:
        return 'Reverse Lunges';
      case WorkoutType.sidePlankDips:
        return 'Side Plank Dips';
      case WorkoutType.crunches:
        return 'Crunches';
      case WorkoutType.sidePlank:
        return 'Side Plank';
      case WorkoutType.hollowBodyHold:
        return 'Hollow Body Hold';
      case WorkoutType.bearHold:
        return 'Bear Hold';
      case WorkoutType.boatHold:
        return 'Boat Hold';
      case WorkoutType.bridgeHold:
        return 'Bridge Hold';
      case WorkoutType.warriorIHold:
        return 'Warrior I Hold';
      case WorkoutType.warriorIIHold:
        return 'Warrior II Hold';
      case WorkoutType.chairPoseHold:
        return 'Chair Pose Hold';
      case WorkoutType.treePoseHold:
        return 'Tree Pose Hold';
      case WorkoutType.downwardDogHold:
        return 'Downward Dog Hold';
      case WorkoutType.cobraPoseHold:
        return 'Cobra Pose Hold';
      case WorkoutType.childsPoseHold:
        return 'Child\'s Pose Hold';
      case WorkoutType.warriorIIIHold:
        return 'Warrior III Hold';
      case WorkoutType.crowPoseHold:
        return 'Crow Pose Hold';
      case WorkoutType.pigeonPoseHold:
        return 'Pigeon Pose Hold';
      case WorkoutType.bridgePoseHold:
        return 'Bridge Pose Hold';
      case WorkoutType.catCowCycles:
        return 'Cat-Cow Cycles';
      case WorkoutType.lowLungeHold:
        return 'Low Lunge Hold';
      case WorkoutType.highPlankHold:
        return 'High Plank Hold';
      case WorkoutType.goddessPoseHold:
        return 'Goddess Pose Hold';
    }
  }

  /// Whether this exercise is measured in time (seconds) vs reps
  bool get isTimeBased {
    switch (this) {
      case WorkoutType.plank:
      case WorkoutType.wallSit:
      case WorkoutType.supermanHold:
      case WorkoutType.sidePlank:
      case WorkoutType.hollowBodyHold:
      case WorkoutType.bearHold:
      case WorkoutType.boatHold:
      case WorkoutType.bridgeHold:
      case WorkoutType.warriorIHold:
      case WorkoutType.warriorIIHold:
      case WorkoutType.chairPoseHold:
      case WorkoutType.treePoseHold:
      case WorkoutType.downwardDogHold:
      case WorkoutType.cobraPoseHold:
      case WorkoutType.childsPoseHold:
      case WorkoutType.warriorIIIHold:
      case WorkoutType.crowPoseHold:
      case WorkoutType.pigeonPoseHold:
      case WorkoutType.bridgePoseHold:
      case WorkoutType.lowLungeHold:
      case WorkoutType.highPlankHold:
      case WorkoutType.goddessPoseHold:
        return true;
      default:
        return false;
    }
  }

  String get unit => isTimeBased ? 'sec' : 'reps';

  /// Approximate calories per rep (rough estimate for future use)
  double get caloriesPerUnit {
    switch (this) {
      case WorkoutType.pushups:
        return 0.5;
      case WorkoutType.squats:
        return 0.4;
      case WorkoutType.jumpingJacks:
        return 0.3;
      case WorkoutType.plank:
        return 0.1; // per second
      case WorkoutType.lunges:
        return 0.5;
      case WorkoutType.wallSit:
        return 0.08; // per second
      case WorkoutType.sitUps:
        return 0.4;
      case WorkoutType.burpees:
        return 1.0;
      case WorkoutType.highKnees:
        return 0.35;
      case WorkoutType.mountainClimbers:
        return 0.45;
      case WorkoutType.calfRaises:
        return 0.2;
      case WorkoutType.tricepDips:
        return 0.45;
      case WorkoutType.flutterKicks:
        return 0.35;
      case WorkoutType.bicycleCrunches:
        return 0.4;
      case WorkoutType.gluteBridges:
        return 0.25;
      case WorkoutType.supermanHold:
        return 0.08;
      case WorkoutType.legRaises:
        return 0.4;
      case WorkoutType.starJumps:
        return 0.5;
      case WorkoutType.lateralLunges:
        return 0.45;
      case WorkoutType.inchworms:
        return 0.6;
      case WorkoutType.jumpSquats:
        return 0.7;
      case WorkoutType.diamondPushups:
        return 0.55;
      case WorkoutType.widePushups:
        return 0.45;
      case WorkoutType.pikePushups:
        return 0.5;
      case WorkoutType.shoulderTaps:
        return 0.3;
      case WorkoutType.russianTwists:
        return 0.35;
      case WorkoutType.vUps:
        return 0.5;
      case WorkoutType.reverseCrunches:
        return 0.35;
      case WorkoutType.donkeyKicks:
        return 0.25;
      case WorkoutType.fireHydrants:
        return 0.25;
      case WorkoutType.birdDogs:
        return 0.2;
      case WorkoutType.deadBugs:
        return 0.25;
      case WorkoutType.scissorKicks:
        return 0.35;
      case WorkoutType.tuckJumps:
        return 0.8;
      case WorkoutType.skaters:
        return 0.5;
      case WorkoutType.frogJumps:
        return 0.7;
      case WorkoutType.curtsyLunges:
        return 0.45;
      case WorkoutType.squatPulses:
        return 0.35;
      case WorkoutType.plankJacks:
        return 0.4;
      case WorkoutType.bearCrawlSteps:
        return 0.5;
      case WorkoutType.toeTouches:
        return 0.3;
      case WorkoutType.hipThrusts:
        return 0.3;
      case WorkoutType.reverseLunges:
        return 0.45;
      case WorkoutType.sidePlankDips:
        return 0.35;
      case WorkoutType.crunches:
        return 0.3;
      case WorkoutType.sidePlank:
        return 0.08;
      case WorkoutType.hollowBodyHold:
        return 0.1;
      case WorkoutType.bearHold:
        return 0.12;
      case WorkoutType.boatHold:
        return 0.1;
      case WorkoutType.bridgeHold:
        return 0.08;
      case WorkoutType.warriorIHold:
        return 0.09;
      case WorkoutType.warriorIIHold:
        return 0.09;
      case WorkoutType.chairPoseHold:
        return 0.1;
      case WorkoutType.treePoseHold:
        return 0.06;
      case WorkoutType.downwardDogHold:
        return 0.07;
      case WorkoutType.cobraPoseHold:
        return 0.06;
      case WorkoutType.childsPoseHold:
        return 0.03;
      case WorkoutType.warriorIIIHold:
        return 0.1;
      case WorkoutType.crowPoseHold:
        return 0.12;
      case WorkoutType.pigeonPoseHold:
        return 0.04;
      case WorkoutType.bridgePoseHold:
        return 0.07;
      case WorkoutType.catCowCycles:
        return 0.15;
      case WorkoutType.lowLungeHold:
        return 0.07;
      case WorkoutType.highPlankHold:
        return 0.1;
      case WorkoutType.goddessPoseHold:
        return 0.09;
    }
  }
}
