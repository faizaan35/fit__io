import 'package:fit_io/Models/exercise.dart';
import 'package:fit_io/Models/workout.dart';
import 'package:fit_io/data/hive_data.dart';
import 'package:fit_io/datetime/date_time.dart';
import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

class WorkoutData extends ChangeNotifier {
  //refrence our hivebox
  final _mybox = Hive.box("My_box");
  final db = HiveDatabase();
  // workout structure will be like this
  // an overall list that will contain all the workout boxes
  // each workout will have a name and list of excersices

  List<Workout> WorkoutList = [
    Workout(
        name: 'upperBody',
        exercises: [Exercise(name: "hsfh", weight: "10", reps: "3", sets: "3")])
  ];

  //if there is already workout in the database then return that otherwise use default workouts
  void initializeWorkout() {
    if (db.previousDataExists()) {
      WorkoutList = db.readFromDatabase();
    } else {
      //use default values
      db.saveDataToDatabase(WorkoutList);
    }
    //load heatmap
    loadheatmap();
  }

  //get the length of the workout
  int numberOfExercisesInAWorkout(String workoutName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    return relevantWorkout.exercises.length;
  }

  //get the list of the workouts
  List<Workout> getWorkOutList() {
    return WorkoutList;
  }

  //add a workout
  void addWorkout(String name) {
    WorkoutList.add(Workout(name: name, exercises: []));

    notifyListeners();

    //save the changes to the database
    db.saveDataToDatabase(WorkoutList);
  }

  // Delete a workout
  void deleteWorkout(int index) {
    WorkoutList.removeAt(index);

    notifyListeners();

    // Save the changes to the database
    db.saveDataToDatabase(WorkoutList);
  }

  //add exercise to the workout
  void addExercise(String workoutName, String exerciseName, String weight,
      String reps, String sets) {
    // find the relevant workout
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    relevantWorkout.exercises.add(
        Exercise(name: exerciseName, weight: weight, reps: reps, sets: sets));

    notifyListeners();

    //save the changes to the database
    db.saveDataToDatabase(WorkoutList);
  }

  //delete exercise
  void deleteExercise(String workoutName, int index) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);
    relevantWorkout.exercises.removeAt(index);
    notifyListeners();
    db.saveDataToDatabase(WorkoutList);
  }

  //update exercise details
  void updateExercise(
    String workoutName,
    String oldExerciseName,
    String newExerciseName,
    String weight,
    String reps,
    String sets,
  ) {
    Exercise exerciseToUpdate =
        getRelevantExercise(workoutName, oldExerciseName);
    exerciseToUpdate.name = newExerciseName;
    exerciseToUpdate.weight = weight;
    exerciseToUpdate.reps = reps;
    exerciseToUpdate.sets = sets;
    notifyListeners();
    db.saveDataToDatabase(WorkoutList);
  }

  //check off exercise

  void checkOffExercise(String workoutName, String exerciseName) {
    Exercise relevantExercise = getRelevantExercise(workoutName, exerciseName);

    relevantExercise.isCompleted = !relevantExercise.isCompleted;

    notifyListeners();
    //save the changes to the database
    db.saveDataToDatabase(WorkoutList);
    //load heatmap
    loadheatmap();
  }

  //returns the workout when given a name
  Workout getRelevantWorkout(String workoutName) {
    Workout relevantWorkout =
        WorkoutList.firstWhere((workout) => workout.name == workoutName);

    return relevantWorkout;
  }

//returns the exercise when given a name
  Exercise getRelevantExercise(String workoutName, String exerciseName) {
    Workout relevantWorkout = getRelevantWorkout(workoutName);

    Exercise relevantExercise = relevantWorkout.exercises
        .firstWhere((exercise) => exercise.name == exerciseName);
    return relevantExercise;
  }

  //get the start date
  String getStartDate() {
    return db.getStartDate();
  }

  // Calculate and save the completion percentage for the current day
  void calculateAndSaveCompletionPercentage(List<Workout> workouts) {
    int completedCount = 0;
    int totalCount = 0;

    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          completedCount++;
        }
        totalCount++;
      }
    }

    double completionPercentage =
        (totalCount == 0) ? 0.0 : (completedCount / totalCount);
    _mybox.put("PERCENTAGE_SUMMARY_${todaysDateFormatted()}",
        completionPercentage.toStringAsFixed(1));
  }

  //Heat Map
  Map<DateTime, int> heatmapDataset = {};
  void loadheatmap() {
    DateTime startDate = createDateTimeObject(getStartDate());

    // count the number of days to load

    int daysInBetween = DateTime.now().difference(startDate).inDays;

    // go from start date to todays and add the completion status for each day
    //"COMPLETION_STATUS_yyyymmdd" will be the key in the database

    for (int i = 0; i < daysInBetween + 1; i++) {
      String yyyymmdd =
          createDateTimeToString(startDate.add(Duration(days: i)));

      double strengthAsPercent = double.parse(
        _mybox.get("PERCENTAGE_SUMMARY_$yyyymmdd") ?? "0.0",
      );

      //year
      int year = startDate.add(Duration(days: i)).year;

      //month
      int month = startDate.add(Duration(days: i)).month;

      //day
      int day = startDate.add(Duration(days: i)).day;

      //percentage for each day

      final percentageForEachDay = <DateTime, int>{
        DateTime(year, month, day): (10 * strengthAsPercent).toInt(),
      };

      //add to the heatmap datasets
      heatmapDataset.addEntries(percentageForEachDay.entries);
    }
  }
}
