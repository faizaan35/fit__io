import 'package:fit_io/Models/exercise.dart';
import 'package:fit_io/Models/workout.dart';
import 'package:fit_io/data/workout_data.dart';
import 'package:fit_io/datetime/date_time.dart';
import 'package:hive/hive.dart';

class HiveDatabase {
  //refrence our hivebox
  final _mybox = Hive.box("My_box");
  //check if there is already data stored if not record the start date
  bool previousDataExists() {
    if (_mybox.isEmpty) {
      print("data doesnt exist ");
      _mybox.put("START_DATE", todaysDateFormatted());
      _mybox.put("LAST_DATE", todaysDateFormatted());
      return false;
    } else {
      print("does exist ");
      // Reset completion status if a new day has started
      String lastDate = _mybox.get("LAST_DATE") ?? getStartDate();
      if (lastDate != todaysDateFormatted()) {
        resetCompletionStatus();
        _mybox.put("LAST_DATE", todaysDateFormatted());
      }
      return true;
    }
  }

  //return the start date in yyyymmdd
  String getStartDate() {
    return _mybox.get("START_DATE");
  }

  //write data
  void saveDataToDatabase(List<Workout> workouts) {
    //converting objects into strings to save in hive
    final WorkoutList = convertObjectToWorkoutList(workouts);
    final ExerciseList = convertObjectToExerciseList(workouts);

    //check if exercises have been done
    //put one for completed ones and 0 for uncompleted ones

    if (exerciseCompleted(workouts)) {
      _mybox.put("COMPLETION_STATUS_${todaysDateFormatted()}", 1);
    } else {
      _mybox.put("COMPLETION_STATUS_${todaysDateFormatted()}", 0);
    }

    // save into hive
    _mybox.put("WORKOUTS", WorkoutList);
    _mybox.put("EXERCISES", ExerciseList);

    // Call calculateAndSaveCompletionPercentage from WorkoutData class
    final workoutData = WorkoutData();
    workoutData.calculateAndSaveCompletionPercentage(workouts);
  }

  //read data and return the list of workouts
  List<Workout> readFromDatabase() {
    List<Workout> mySavedWorkouts = [];
    List<String> workoutNames = (_mybox.get("WORKOUTS") as List).cast<String>();
    final exerciseDetails = _mybox.get("EXERCISES");

    //create the workout objects
    for (int i = 0; i < workoutNames.length; i++) {
      List<Exercise> exercisesInEachWorkout = [];
      for (int j = 0; j < exerciseDetails[i].length; j++) {
        exercisesInEachWorkout.add(
          Exercise(
              name: exerciseDetails[i][j][0],
              weight: exerciseDetails[i][j][1],
              reps: exerciseDetails[i][j][2],
              sets: exerciseDetails[i][j][3],
              isCompleted: exerciseDetails[i][j][4] == "true" ? true : false),
        );
      }

      //create individual workouts
      Workout workout =
          Workout(name: workoutNames[i], exercises: exercisesInEachWorkout);
      //now add this workout to the overall list
      mySavedWorkouts.add(workout);
    }
    return mySavedWorkouts;
  }

  //checck if the exercises have been done or not
  bool exerciseCompleted(List<Workout> workouts) {
    //go through each workout
    for (var workout in workouts) {
      //go through each exercise in each workout
      for (var exercise in workout.exercises) {
        if (exercise.isCompleted) {
          return true;
        }
      }
    }
    return false;
  }

  //return completion status of any given date yyyymmdd
  int getCompletionStatus(String yyyymmdd) {
    //return 0 or 1 , if null then return 0
    int completionStatus = _mybox.get("COMPLETION_STATUS_$yyyymmdd") ?? 0;
    return completionStatus;
  }

  //convert workout objects into list

  List<String> convertObjectToWorkoutList(List<Workout> workouts) {
    List<String> workoutList = [
      //eg upper body , lower body
    ];

    for (int i = 0; i < workouts.length; i++) {
      workoutList.add(
        workouts[i].name,
      );
    }
    return workoutList;
  }

//convert the exercises in the workout into another list of strings
//for eg [
//     upperbody
//      [[curls , 10kg , 5 reps , 3 sets ],[name , weights , reps , sets ],[]],
//      lowerbody
//      [[squats , wieghts , reps , sets ],[],[]]
//]

  List<List<List<String>>> convertObjectToExerciseList(List<Workout> workouts) {
    List<List<List<String>>> ExerciseList = [];

// gp through each workout
    for (int i = 0; i < workouts.length; i++) {
      // get the exercises from each workout
      List<Exercise> ExercisesInWorkout = workouts[i].exercises;

      List<List<String>> individualWorkout = [
        //upperbody
        //[[],[],[]]
      ];

      //go through each exercise in the workout list (ExercisesInWorkout)
      for (int j = 0; j < ExercisesInWorkout.length; j++) {
        List<String> individualExercise = [
          //[name , wiegth , reps ,sets ]
        ];
        individualExercise.addAll([
          ExercisesInWorkout[j].name,
          ExercisesInWorkout[j].weight,
          ExercisesInWorkout[j].reps,
          ExercisesInWorkout[j].sets,
          ExercisesInWorkout[j].isCompleted.toString(),
        ]);
        individualWorkout.add(individualExercise);
      }
      ExerciseList.add(individualWorkout);
    }
    return ExerciseList;
  }

  // Reset the completion status of all exercises
  void resetCompletionStatus() {
    List<Workout> workouts = readFromDatabase();
    for (var workout in workouts) {
      for (var exercise in workout.exercises) {
        exercise.isCompleted = false;
      }
    }
    saveDataToDatabase(workouts);
  }
}
