import 'package:fit_io/Models/exercise.dart';
import 'package:fit_io/components/exercise_tile.dart';
import 'package:fit_io/data/workout_data.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

class WorkoutPage extends StatefulWidget {
  final workoutName;
  const WorkoutPage({super.key, required this.workoutName});

  @override
  State<WorkoutPage> createState() => _WorkoutPageState();
}

class _WorkoutPageState extends State<WorkoutPage> {
  void onSave() {
    String exerciseName = newExerciseNameController.text;
    String weight = newExerciseWeightController.text;
    String reps = newExerciseRepsController.text;
    String sets = newExerciseSetsController.text;

    Provider.of<WorkoutData>(context, listen: false)
        .addExercise(widget.workoutName, exerciseName, weight, reps, sets);
    Navigator.pop(context);
    newExerciseNameController.clear();
    newExerciseWeightController.clear();
    newExerciseRepsController.clear();
    newExerciseSetsController.clear();
  }

  void onCancel() {
    Navigator.pop(context);
    newExerciseNameController.clear();
    newExerciseWeightController.clear();
    newExerciseRepsController.clear();
    newExerciseSetsController.clear();
  }

  void onCheckboxChanged(String workoutName, String exerciseName) {
    Provider.of<WorkoutData>(context, listen: false)
        .checkOffExercise(workoutName, exerciseName);
  }

  final newExerciseNameController = TextEditingController();
  final newExerciseWeightController = TextEditingController();
  final newExerciseRepsController = TextEditingController();
  final newExerciseSetsController = TextEditingController();

  void createNewExercise() {
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: Text("Add a new exercise"),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    decoration: InputDecoration(hintText: "Exercise Name"),
                    controller: newExerciseNameController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Weight"),
                    controller: newExerciseWeightController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Number of Reps "),
                    controller: newExerciseRepsController,
                  ),
                  TextField(
                    decoration: InputDecoration(hintText: "Number of Sets"),
                    controller: newExerciseSetsController,
                  ),
                ],
              ),
              actions: [
                //save button
                MaterialButton(child: Text("Save"), onPressed: onSave),

                //cancel button
                MaterialButton(child: Text("Cancel"), onPressed: onCancel),
              ],
            ));
  }

  void deleteExercise(int index) {
    Provider.of<WorkoutData>(context, listen: false)
        .deleteExercise(widget.workoutName, index);
  }

  void showExerciseSettings(int index) {
    showDialog(
      context: context,
      builder: (context) {
        // Retrieve current exercise details
        Exercise currentExercise =
            Provider.of<WorkoutData>(context, listen: false)
                .getRelevantWorkout(widget.workoutName)
                .exercises[index];

        // Controllers for editing
        TextEditingController exerciseNameController =
            TextEditingController(text: currentExercise.name);
        TextEditingController weightController =
            TextEditingController(text: currentExercise.weight);
        TextEditingController repsController =
            TextEditingController(text: currentExercise.reps);
        TextEditingController setsController =
            TextEditingController(text: currentExercise.sets);

        return AlertDialog(
          title: Text("Edit Exercise"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                decoration: InputDecoration(hintText: "Exercise Name"),
                controller: exerciseNameController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Weight"),
                controller: weightController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Number of Reps"),
                controller: repsController,
              ),
              TextField(
                decoration: InputDecoration(hintText: "Number of Sets"),
                controller: setsController,
              ),
            ],
          ),
          actions: [
            MaterialButton(
              child: Text("Save"),
              onPressed: () {
                Provider.of<WorkoutData>(context, listen: false).updateExercise(
                  widget.workoutName,
                  currentExercise.name,
                  exerciseNameController.text,
                  weightController.text,
                  repsController.text,
                  setsController.text,
                );
                Navigator.pop(context);
              },
            ),
            MaterialButton(
              child: Text("Cancel"),
              onPressed: () {
                Navigator.pop(context);
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: (context, value, child) => Scaffold(
        backgroundColor: Colors.grey[300],
        appBar: AppBar(
          iconTheme: IconThemeData(color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(bottom: Radius.circular(12))),
          backgroundColor: Colors.black,
          title: Text(
            widget.workoutName,
            style: GoogleFonts.cabin(
                color: Colors.white, fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        floatingActionButton: FloatingActionButton(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
          backgroundColor: Colors.black,
          onPressed: createNewExercise,
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        body: ListView.builder(
            itemCount: value.numberOfExercisesInAWorkout(widget.workoutName),
            itemBuilder: (context, index) => Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Slidable(
                    endActionPane: ActionPane(
                      motion: const StretchMotion(),
                      children: [
                        //setting button
                        SlidableAction(
                          onPressed: (context) => showExerciseSettings(index),
                          backgroundColor: Colors.grey.shade800,
                          icon: Icons.settings,
                          borderRadius: BorderRadius.circular(12),
                        ),

                        //delete buttton
                        SlidableAction(
                          onPressed: (context) => deleteExercise(index),
                          backgroundColor: Colors.red.shade400,
                          icon: Icons.delete,
                          borderRadius: BorderRadius.circular(12),
                        )
                      ],
                    ),
                    child: ExerciseTile(
                      exerciseName: value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .name,
                      weight: value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .weight,
                      reps: value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .reps,
                      sets: value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .sets,
                      isCompleted: value
                          .getRelevantWorkout(widget.workoutName)
                          .exercises[index]
                          .isCompleted,
                      onCheckboxChanged: (val) => onCheckboxChanged(
                          widget.workoutName,
                          value
                              .getRelevantWorkout(widget.workoutName)
                              .exercises[index]
                              .name),
                    ),
                  ),
                )),
      ),
    );
  }
}
