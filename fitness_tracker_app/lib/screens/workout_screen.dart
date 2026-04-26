import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/workout_model.dart';
import '../services/database_helper.dart';
import 'active_workout_screen.dart';
import 'create_workout_screen.dart';

class WorkoutScreen extends StatefulWidget {
  const WorkoutScreen({super.key});
  @override
  State<WorkoutScreen> createState() => _WorkoutScreenState();
}

class _WorkoutScreenState extends State<WorkoutScreen> {
  List<WorkoutModel> _workouts = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _loadWorkouts();
  }

  Future<void> _loadWorkouts() async {
    final p = Provider.of<AppProvider>(context, listen: false);
    if (p.currentUser == null) return;
    // Seed preset workouts if none exist
    final all = await DatabaseHelper.instance.getWorkouts(p.currentUser!.id);
    if (all.isEmpty) await _seedPresets(p.currentUser!.id);
    final workouts = await DatabaseHelper.instance.getWorkouts(p.currentUser!.id);
    if (mounted) setState(() { _workouts = workouts; _loading = false; });
  }

  Future<void> _seedPresets(String userId) async {
    final presets = [
      WorkoutModel(
        userId: userId, name: 'Full Body HIIT', category: 'HIIT',
        description: 'High intensity full body circuit', estimatedMinutes: 30, isPreset: true,
        exercises: [
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Jumping Jacks', sets: 3, reps: 20, restSeconds: 30, orderIndex: 0),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Burpees', sets: 3, reps: 10, restSeconds: 45, orderIndex: 1),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Mountain Climbers', sets: 3, reps: 20, restSeconds: 30, orderIndex: 2),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'High Knees', sets: 3, reps: 30, restSeconds: 30, orderIndex: 3),
        ],
      ),
      WorkoutModel(
        userId: userId, name: 'Push Day', category: 'Push',
        description: 'Chest, shoulders, triceps', estimatedMinutes: 45, isPreset: true,
        exercises: [
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Push-ups', sets: 4, reps: 15, restSeconds: 60, orderIndex: 0),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Dips', sets: 3, reps: 12, restSeconds: 60, orderIndex: 1),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Pike Push-ups', sets: 3, reps: 10, restSeconds: 60, orderIndex: 2),
        ],
      ),
      WorkoutModel(
        userId: userId, name: 'Morning Yoga', category: 'Yoga',
        description: 'Energizing yoga flow', estimatedMinutes: 20, isPreset: true,
        exercises: [
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Sun Salutation A', sets: 3, reps: 5, restSeconds: 30, orderIndex: 0),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Warrior I & II', sets: 2, reps: 5, restSeconds: 20, orderIndex: 1),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Child\'s Pose', sets: 1, reps: 1, restSeconds: 60, orderIndex: 2),
        ],
      ),
      WorkoutModel(
        userId: userId, name: 'Leg Day', category: 'Legs',
        description: 'Quads, hamstrings, glutes', estimatedMinutes: 40, isPreset: true,
        exercises: [
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Squats', sets: 4, reps: 15, restSeconds: 90, orderIndex: 0),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Lunges', sets: 3, reps: 12, restSeconds: 60, orderIndex: 1),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Glute Bridges', sets: 3, reps: 15, restSeconds: 60, orderIndex: 2),
          WorkoutExerciseModel(workoutId: 0, exerciseName: 'Calf Raises', sets: 3, reps: 20, restSeconds: 45, orderIndex: 3),
        ],
      ),
    ];
    for (final w in presets) {
      await DatabaseHelper.instance.insertWorkout(w);
    }
  }

  Color _categoryColor(String cat) {
    switch (cat) {
      case 'HIIT': return const Color(0xFFFF8A65);
      case 'Push': case 'Pull': return const Color(0xFF9575CD);
      case 'Legs': return const Color(0xFF4FC3F7);
      case 'Yoga': return const Color(0xFF7FE0C7);
      default: return AppTheme.primaryColor;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Workouts', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
              GestureDetector(
                onTap: () async {
                  final created = await Navigator.of(context).push<bool>(
                    MaterialPageRoute(builder: (_) => const CreateWorkoutScreen()),
                  );
                  if (created == true) _loadWorkouts();
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                  decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                  child: const Row(mainAxisSize: MainAxisSize.min, children: [
                    Icon(LucideIcons.plus, color: Colors.white, size: 16),
                    SizedBox(width: 6),
                    Text('Custom', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                  ]),
                ),
              ),
            ]),
          ),

          if (_loading)
            const Expanded(child: Center(child: CircularProgressIndicator()))
          else
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                itemCount: _workouts.length,
                itemBuilder: (ctx, i) {
                  final w = _workouts[i];
                  final color = _categoryColor(w.category);
                  return Container(
                    margin: const EdgeInsets.only(bottom: 16),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.softShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      // Header
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: color.withAlpha(40),
                          borderRadius: const BorderRadius.only(topLeft: Radius.circular(24), topRight: Radius.circular(24)),
                        ),
                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                          Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
                              child: Text(w.category, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
                            ),
                            const SizedBox(height: 8),
                            Text(w.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                            if (w.description != null)
                              Text(w.description!, style: Theme.of(context).textTheme.bodySmall),
                          ]),
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
                            child: const Icon(LucideIcons.dumbbell, color: Colors.white, size: 22),
                          ),
                        ]),
                      ),
                      // Stats + Button
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(children: [
                          _InfoChip(LucideIcons.clock, '${w.estimatedMinutes} min'),
                          const SizedBox(width: 10),
                          _InfoChip(LucideIcons.layers, '${w.exercises.length} exercises'),
                          const Spacer(),
                          ElevatedButton(
                            onPressed: () => Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => ActiveWorkoutScreen(workout: w))),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.primaryColor,
                              foregroundColor: Colors.white,
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                              elevation: 0,
                            ),
                            child: const Text('Start', style: TextStyle(fontWeight: FontWeight.w600)),
                          ),
                        ]),
                      ),
                    ]),
                  );
                },
              ),
            ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }
}

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _InfoChip(this.icon, this.label);
  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 14, color: AppTheme.textSecondary),
      const SizedBox(width: 4),
      Text(label, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12)),
    ]);
  }
}
