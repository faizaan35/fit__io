import 'package:fit_io/pages/ChatScreen_page.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_nav_bar/google_nav_bar.dart';
import 'package:fit_io/data/workout_data.dart';
import 'package:fit_io/pages/workout_page.dart';
import 'package:fit_io/components/heat_map.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int _selectedIndex = 0; // Track the selected index for navigation

  @override
  void initState() {
    super.initState();
    Provider.of<WorkoutData>(context, listen: false).initializeWorkout();
  }

  // Controller for the alert box
  final newWorkoutNameController = TextEditingController();

  // Function to create a new workout
  void createNewWorkout() {
    showDialog(
      context: context,
      builder: ((context) => AlertDialog(
            title: Text("Create New Workout"),
            content: TextField(
              controller: newWorkoutNameController,
            ),
            actions: [
              // Save button
              MaterialButton(
                child: Text("Save"),
                onPressed: onSave,
              ),
              // Cancel button
              MaterialButton(
                child: Text("Cancel"),
                onPressed: onCancel,
              ),
            ],
          )),
    );
  }

  void goToWorkoutPage(String workoutName) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => WorkoutPage(workoutName: workoutName),
      ),
    );
  }

  void goToHomepage() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => const HomePage(), // Navigate to your ChatScreen
      ),
    );
  }

  void onSave() {
    String newWorkoutName = newWorkoutNameController.text;
    Provider.of<WorkoutData>(context, listen: false).addWorkout(newWorkoutName);
    Navigator.pop(context);
    newWorkoutNameController.clear();
  }

  void onCancel() {
    Navigator.pop(context);
    newWorkoutNameController.clear();
  }

  void onDelete(int index) {
    Provider.of<WorkoutData>(context, listen: false).deleteWorkout(index);
  }

  // Function to handle navigation based on index
  void onTabSelected(int index) {
    setState(() {
      _selectedIndex = index;
    });

    // Perform navigation based on index
    switch (index) {
      case 0:
        // Navigate to Home Page if not already there
        if (!(Navigator.of(context).canPop())) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => HomePage()),
          );
        }
        break;
      case 1:
        // Navigate to Chat Screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => ChatScreen()),
        );
        break;
      case 2:
        // Handle other tab actions as needed
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<WorkoutData>(
      builder: ((context, value, child) => Scaffold(
            backgroundColor: Colors.grey[300],
            bottomNavigationBar: Container(
              color: Colors.black,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 15),
                child: GNav(
                  backgroundColor: Colors.black,
                  color: Colors.white,
                  activeColor: Colors.white,
                  tabBackgroundColor: Color.fromRGBO(66, 66, 66, 1),
                  padding: EdgeInsets.all(16),
                  gap: 8,
                  selectedIndex: _selectedIndex,
                  onTabChange: onTabSelected, // Handle tab changes
                  tabs: const [
                    GButton(
                      icon: Icons.assignment_rounded,
                      text: 'Workouts',
                    ),
                    GButton(
                      text: 'AI',
                      icon: Icons.circle,
                      leading: ImageIcon(
                        color: Colors.white,
                        AssetImage('lib/images/ai-assistant.png'),
                      ),
                    ),
                    GButton(
                      icon: Icons.bar_chart_rounded,
                      text: 'Stats',
                    ),
                  ],
                ),
              ),
            ),
            floatingActionButton: FloatingActionButton(
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(30)),
              backgroundColor: Colors.black,
              onPressed: createNewWorkout,
              child: const Icon(
                Icons.add,
                color: Colors.white,
              ),
            ),
            body: ListView(
              children: [
                // Heatmap
                MyHeatMap(
                  datasets: value.heatmapDataset,
                  startdateYYYYMMDD: value.getStartDate(),
                ),

                // Workout list
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: value.getWorkOutList().length,
                  itemBuilder: ((context, index) => Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Slidable(
                          endActionPane:
                              ActionPane(motion: StretchMotion(), children: [
                            // Delete button
                            SlidableAction(
                              onPressed: (context) => onDelete(index),
                              backgroundColor: Colors.red.shade400,
                              icon: Icons.delete,
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ]),
                          child: Container(
                            height: 80,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              color: Colors.black,
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12.0),
                              child: ListTile(
                                title: Text(
                                  value.getWorkOutList()[index].name,
                                  style: GoogleFonts.cabin(
                                    color: Colors.grey[100],
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                trailing: IconButton(
                                  icon: const Icon(
                                    color: Colors.white,
                                    Icons.arrow_forward,
                                  ),
                                  onPressed: () => goToWorkoutPage(
                                      value.getWorkOutList()[index].name),
                                ),
                              ),
                            ),
                          ),
                        ),
                      )),
                ),
              ],
            ),
          )),
    );
  }
}
