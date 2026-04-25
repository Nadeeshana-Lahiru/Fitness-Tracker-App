import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/workout_model.dart';
import '../models/activity_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ActiveWorkoutScreen extends StatefulWidget {
  final WorkoutModel workout;
  const ActiveWorkoutScreen({super.key, required this.workout});
  @override
  State<ActiveWorkoutScreen> createState() => _ActiveWorkoutScreenState();
}

class _ActiveWorkoutScreenState extends State<ActiveWorkoutScreen> {
  late List<WorkoutExerciseModel> _exercises;
  int _currentIndex = 0;
  late Stopwatch _stopwatch;
  Timer? _timer;
  Timer? _restTimer;
  int _restRemaining = 0;
  bool _isResting = false;

  @override
  void initState() {
    super.initState();
    _exercises = List.from(widget.workout.exercises);
    _stopwatch = Stopwatch()..start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() {});
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _restTimer?.cancel();
    _stopwatch.stop();
    super.dispose();
  }

  void _markSetDone() {
    final ex = _exercises[_currentIndex];
    if (_isResting) return;
    // Start rest timer
    setState(() {
      _isResting = true;
      _restRemaining = ex.restSeconds;
    });
    _restTimer = Timer.periodic(const Duration(seconds: 1), (t) {
      setState(() => _restRemaining--);
      if (_restRemaining <= 0) {
        t.cancel();
        setState(() => _isResting = false);
      }
    });
  }

  void _nextExercise() {
    _restTimer?.cancel();
    if (_currentIndex < _exercises.length - 1) {
      setState(() { _currentIndex++; _isResting = false; });
    } else {
      _finishWorkout();
    }
  }

  void _finishWorkout() {
    _stopwatch.stop();
    final mins = _stopwatch.elapsed.inMinutes.clamp(1, 999);
    final estCals = (mins * 8).clamp(50, 9999);
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
        title: const Text('🏆 Workout Complete!'),
        content: Column(mainAxisSize: MainAxisSize.min, children: [
          Text('Duration: $mins minutes', style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 6),
          Text('Est. Calories: ~$estCals kcal', style: const TextStyle(fontSize: 16)),
        ]),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('Discard')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
            onPressed: () async {
              final p = Provider.of<AppProvider>(ctx, listen: false);
              if (p.currentUser != null) {
                await p.addActivity(ActivityModel(
                  userId: p.currentUser!.id,
                  type: widget.workout.category == 'Yoga' ? 'Yoga' : 'Weightlifting',
                  durationMinutes: mins,
                  caloriesBurned: estCals,
                  date: DateTime.now(),
                  notes: 'Workout: ${widget.workout.name}',
                ));
              }
              if (mounted) {
                Navigator.of(ctx).pop();
                Navigator.of(context).pop();
              }
            },
            child: const Text('Save Workout'),
          ),
        ],
      ),
    );
  }

  String _formatTime(Duration d) {
    final m = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$m:$s';
  }

  @override
  Widget build(BuildContext context) {
    final ex = _exercises[_currentIndex];
    final progress = (_currentIndex + 1) / _exercises.length;

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            // Header
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              GestureDetector(
                onTap: () => showDialog(
                  context: context,
                  builder: (ctx) => AlertDialog(
                    title: const Text('Quit Workout?'),
                    content: const Text('Your progress will be lost.'),
                    actions: [
                      TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
                        onPressed: () { Navigator.pop(ctx); Navigator.pop(context); },
                        child: const Text('Quit'),
                      ),
                    ],
                  ),
                ),
                child: Container(padding: const EdgeInsets.all(10), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: AppTheme.softShadow),
                    child: const Icon(LucideIcons.x, size: 20)),
              ),
              Text(widget.workout.name, style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
              Container(padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
                  child: Row(children: [
                    const Icon(LucideIcons.timer, size: 16, color: AppTheme.primaryColor),
                    const SizedBox(width: 6),
                    Text(_formatTime(_stopwatch.elapsed),
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                  ])),
            ]),
            const SizedBox(height: 24),

            // Progress
            Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
              Text('Exercise ${_currentIndex + 1} of ${_exercises.length}',
                  style: Theme.of(context).textTheme.bodyMedium),
              Text('${(progress * 100).toInt()}%', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor)),
            ]),
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: LinearProgressIndicator(
                value: progress, minHeight: 8,
                backgroundColor: AppTheme.primaryColor.withAlpha(30),
                valueColor: const AlwaysStoppedAnimation(AppTheme.primaryColor),
              ),
            ),
            const SizedBox(height: 32),

            // Exercise Card
            Expanded(
              child: Column(children: [
                // Rest overlay or exercise info
                if (_isResting)
                  Expanded(child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(colors: [Color(0xFF7FE0C7), Color(0xFF4FC3F7)]),
                      borderRadius: BorderRadius.circular(32),
                    ),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      const Icon(LucideIcons.timer, color: Colors.white, size: 48),
                      const SizedBox(height: 16),
                      Text('$_restRemaining', style: const TextStyle(color: Colors.white, fontSize: 72, fontWeight: FontWeight.bold)),
                      const Text('seconds rest', style: TextStyle(color: Colors.white70, fontSize: 18)),
                      const SizedBox(height: 24),
                      ElevatedButton(
                        onPressed: () { _restTimer?.cancel(); setState(() => _isResting = false); },
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.white, foregroundColor: AppTheme.primaryColor,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
                        child: const Text('Skip Rest'),
                      ),
                    ]),
                  ))
                else
                  Expanded(child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(28),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(32), boxShadow: AppTheme.softShadow),
                    child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(color: const Color(0xFFD3E0FA), shape: BoxShape.circle),
                        child: const Icon(LucideIcons.dumbbell, color: AppTheme.primaryColor, size: 52),
                      ),
                      const SizedBox(height: 24),
                      Text(ex.exerciseName, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 26, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
                      const SizedBox(height: 16),
                      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
                        _setStatChip('${ex.sets}', 'Sets'),
                        const SizedBox(width: 20),
                        _setStatChip('${ex.reps}', 'Reps'),
                        const SizedBox(width: 20),
                        _setStatChip('${ex.restSeconds}s', 'Rest'),
                      ]),
                      if (ex.notes != null) ...[
                        const SizedBox(height: 16),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(12)),
                          child: Text(ex.notes!, style: Theme.of(context).textTheme.bodySmall?.copyWith(height: 1.5)),
                        ),
                      ],
                    ]),
                  )),

                const SizedBox(height: 20),

                // Action Buttons
                Row(children: [
                  if (_currentIndex > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => setState(() { _currentIndex--; _isResting = false; }),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                          side: BorderSide(color: Colors.grey.withAlpha(80)),
                        ),
                        child: const Text('Previous'),
                      ),
                    ),
                  if (_currentIndex > 0) const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _isResting ? null : (_currentIndex == _exercises.length - 1 ? _finishWorkout : () { _markSetDone(); _nextExercise(); }),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        foregroundColor: Colors.white,
                        disabledBackgroundColor: Colors.grey.withAlpha(80),
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        elevation: 0,
                      ),
                      child: Text(
                        _isResting ? 'Resting...' : (_currentIndex == _exercises.length - 1 ? '🏁 Finish' : 'Next Exercise →'),
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                  ),
                ]),
              ]),
            ),
            const SizedBox(height: 16),
          ]),
        ),
      ),
    );
  }

  Widget _setStatChip(String value, String label) {
    return Column(children: [
      Text(value, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
      Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
    ]);
  }
}
