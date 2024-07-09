import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class ExerciseTile extends StatelessWidget {
  final String exerciseName;
  final String weight;
  final String reps;
  final String sets;
  final bool isCompleted;
  final void Function(bool?)? onCheckboxChanged;

  ExerciseTile({
    Key? key,
    required this.exerciseName,
    required this.weight,
    required this.reps,
    required this.sets,
    required this.isCompleted,
    required this.onCheckboxChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 120,
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(12.0),
      ),
      padding: EdgeInsets.all(12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  exerciseName,
                  style: GoogleFonts.cabin(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                SizedBox(height: 16),
                Row(
                  children: [
                    ExerciseDetailChip("${weight} kg", Colors.black),
                    SizedBox(width: 8),
                    ExerciseDetailChip("${reps} reps", Colors.black),
                    SizedBox(width: 8),
                    ExerciseDetailChip("${sets} sets", Colors.black),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(
              width:
                  16), // Adjust spacing between exercise name/details and checkbox
          Container(
            padding: EdgeInsets.all(30),
            child: Checkbox(
              value: isCompleted,
              onChanged: onCheckboxChanged,
              activeColor: Colors.black,
            ),
          ),
        ],
      ),
    );
  }
}

class ExerciseDetailChip extends StatelessWidget {
  final String label;
  final Color color;

  const ExerciseDetailChip(this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(12.0),
      ),
      child: Text(
        label,
        style:
            const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
