import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';
import '../models/workout_model.dart';
import '../services/database_helper.dart';

class CreateWorkoutScreen extends StatefulWidget {
  const CreateWorkoutScreen({super.key});
  @override
  State<CreateWorkoutScreen> createState() => _CreateWorkoutScreenState();
}

class _CreateWorkoutScreenState extends State<CreateWorkoutScreen> {
  final _nameCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  String _selectedCategory = 'Strength';
  int _estimatedMinutes = 30;
  bool _saving = false;

  final List<_ExerciseEntry> _exercises = [];

  final List<String> _categories = [
    'Strength', 'HIIT', 'Cardio', 'Yoga', 'Push', 'Pull', 'Legs', 'Core', 'Flexibility', 'Other'
  ];

  // Exercise library suggestions
  static const Map<String, List<String>> _exerciseLibrary = {
    'Strength': ['Bench Press', 'Deadlift', 'Squat', 'Overhead Press', 'Barbell Row', 'Pull-up', 'Dip', 'Bicep Curl', 'Tricep Extension'],
    'HIIT': ['Burpees', 'Jumping Jacks', 'Mountain Climbers', 'High Knees', 'Box Jumps', 'Jump Rope', 'Sprint Intervals'],
    'Cardio': ['Running', 'Cycling', 'Rowing', 'Elliptical', 'Jump Rope', 'Stair Climbing'],
    'Yoga': ['Sun Salutation A', 'Warrior I', 'Warrior II', 'Downward Dog', 'Child\'s Pose', 'Tree Pose', 'Pigeon Pose'],
    'Core': ['Plank', 'Crunches', 'Leg Raises', 'Russian Twists', 'Dead Bug', 'Bird Dog', 'Side Plank'],
    'Push': ['Push-ups', 'Dips', 'Pike Push-ups', 'Diamond Push-ups', 'Wall Push-ups'],
    'Pull': ['Pull-ups', 'Chin-ups', 'Inverted Row', 'Band Pull-apart'],
    'Legs': ['Squats', 'Lunges', 'Glute Bridges', 'Calf Raises', 'Step-ups', 'Wall Sit'],
    'Flexibility': ['Hip Flexor Stretch', 'Hamstring Stretch', 'Chest Opener', 'Shoulder Stretch'],
    'Other': ['Jumping Jacks', 'Burpees', 'Push-ups', 'Squats'],
  };

  Color get _categoryColor {
    switch (_selectedCategory) {
      case 'HIIT': return const Color(0xFFFF8A65);
      case 'Push': case 'Pull': case 'Strength': return const Color(0xFF9575CD);
      case 'Legs': return const Color(0xFF4FC3F7);
      case 'Yoga': case 'Flexibility': return const Color(0xFF7FE0C7);
      case 'Cardio': return const Color(0xFF81C784);
      case 'Core': return const Color(0xFFFFD54F);
      default: return AppTheme.primaryColor;
    }
  }

  void _addExercise() {
    final suggestions = _exerciseLibrary[_selectedCategory] ?? _exerciseLibrary['Other']!;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _AddExerciseSheet(
        suggestions: suggestions,
        onAdd: (entry) => setState(() => _exercises.add(entry)),
      ),
    );
  }

  Future<void> _saveWorkout() async {
    if (_nameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a workout name')));
      return;
    }
    if (_exercises.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Add at least one exercise')));
      return;
    }
    final p = Provider.of<AppProvider>(context, listen: false);
    if (p.currentUser == null) return;

    setState(() => _saving = true);
    try {
      final workout = WorkoutModel(
        userId: p.currentUser!.id,
        name: _nameCtrl.text.trim(),
        description: _descCtrl.text.trim().isEmpty ? null : _descCtrl.text.trim(),
        category: _selectedCategory,
        estimatedMinutes: _estimatedMinutes,
        exercises: _exercises.asMap().entries.map((e) => WorkoutExerciseModel(
          workoutId: 0,
          exerciseName: e.value.name,
          sets: e.value.sets,
          reps: e.value.reps,
          restSeconds: e.value.restSeconds,
          notes: e.value.notes.isEmpty ? null : e.value.notes,
          orderIndex: e.key,
        )).toList(),
      );
      await DatabaseHelper.instance.insertWorkout(workout);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('✅ Workout saved!'), backgroundColor: Colors.green));
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e'), backgroundColor: Colors.red));
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _descCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(LucideIcons.arrowLeft, color: AppTheme.textPrimary),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text('Create Workout',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 20)),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: TextButton(
              onPressed: _saving ? null : _saveWorkout,
              style: TextButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
              ),
              child: _saving
                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Text('Save', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Name
          _buildLabel('Workout Name'),
          const SizedBox(height: 8),
          _buildTextField(_nameCtrl, 'e.g. Morning Power Session', LucideIcons.dumbbell),
          const SizedBox(height: 20),

          // Description
          _buildLabel('Description (optional)'),
          const SizedBox(height: 8),
          _buildTextField(_descCtrl, 'Describe your workout goal...', LucideIcons.fileText, maxLines: 2),
          const SizedBox(height: 20),

          // Category
          _buildLabel('Category'),
          const SizedBox(height: 10),
          SizedBox(
            height: 40,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: _categories.map((cat) {
                final sel = cat == _selectedCategory;
                return GestureDetector(
                  onTap: () => setState(() => _selectedCategory = cat),
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    margin: const EdgeInsets.only(right: 8),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: sel ? _categoryColor : Colors.white,
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(color: sel ? _categoryColor : Colors.grey.withAlpha(60)),
                      boxShadow: sel ? AppTheme.softShadow : [],
                    ),
                    child: Text(cat, style: TextStyle(
                      color: sel ? Colors.white : AppTheme.textSecondary,
                      fontWeight: sel ? FontWeight.w700 : FontWeight.normal,
                      fontSize: 13,
                    )),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 20),

          // Duration
          _buildLabel('Estimated Duration'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
            child: Row(children: [
              const Icon(LucideIcons.clock, color: AppTheme.primaryColor, size: 20),
              const SizedBox(width: 12),
              Text('$_estimatedMinutes minutes', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 15)),
              const Spacer(),
              Row(children: [
                _circleBtn(LucideIcons.minus, () => setState(() { if (_estimatedMinutes > 5) _estimatedMinutes -= 5; })),
                const SizedBox(width: 8),
                _circleBtn(LucideIcons.plus, () => setState(() { if (_estimatedMinutes < 180) _estimatedMinutes += 5; })),
              ]),
            ]),
          ),
          const SizedBox(height: 28),

          // Exercises
          Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
            _buildLabel('Exercises (${_exercises.length})'),
            GestureDetector(
              onTap: _addExercise,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(20)),
                child: const Row(mainAxisSize: MainAxisSize.min, children: [
                  Icon(LucideIcons.plus, color: Colors.white, size: 14),
                  SizedBox(width: 6),
                  Text('Add Exercise', style: TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600)),
                ]),
              ),
            ),
          ]),
          const SizedBox(height: 14),

          if (_exercises.isEmpty)
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
              child: Center(child: Column(children: [
                Icon(LucideIcons.dumbbell, size: 40, color: Colors.grey.withAlpha(120)),
                const SizedBox(height: 12),
                const Text('No exercises added yet', style: TextStyle(color: AppTheme.textSecondary)),
                const SizedBox(height: 6),
                const Text('Tap "Add Exercise" to get started', style: TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
              ])),
            )
          else
            ReorderableListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _exercises.length,
              onReorder: (oldIndex, newIndex) {
                setState(() {
                  if (newIndex > oldIndex) newIndex--;
                  final item = _exercises.removeAt(oldIndex);
                  _exercises.insert(newIndex, item);
                });
              },
              itemBuilder: (ctx, i) {
                final ex = _exercises[i];
                return Container(
                  key: ValueKey('ex_$i'),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(18), boxShadow: AppTheme.softShadow),
                  child: Row(children: [
                    Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(color: _categoryColor.withAlpha(30), shape: BoxShape.circle),
                      child: Icon(LucideIcons.dumbbell, color: _categoryColor, size: 18),
                    ),
                    const SizedBox(width: 12),
                    Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text(ex.name, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                      const SizedBox(height: 4),
                      Text('${ex.sets} sets × ${ex.reps} reps • ${ex.restSeconds}s rest',
                          style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                    ])),
                    IconButton(
                      icon: const Icon(LucideIcons.trash2, size: 16, color: Colors.red),
                      onPressed: () => setState(() => _exercises.removeAt(i)),
                    ),
                    const Icon(LucideIcons.gripVertical, size: 18, color: AppTheme.textSecondary),
                  ]),
                );
              },
            ),
          const SizedBox(height: 100),
        ]),
      ),
    );
  }

  Widget _buildLabel(String text) => Text(text,
      style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700, fontSize: 15));

  Widget _buildTextField(TextEditingController ctrl, String hint, IconData icon, {int maxLines = 1}) {
    return TextField(
      controller: ctrl,
      maxLines: maxLines,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _circleBtn(IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle,
            border: Border.all(color: Colors.grey.withAlpha(60))),
        child: Icon(icon, size: 14, color: AppTheme.textPrimary),
      ),
    );
  }
}

class _ExerciseEntry {
  String name;
  int sets;
  int reps;
  int restSeconds;
  String notes;
  _ExerciseEntry({required this.name, this.sets = 3, this.reps = 10, this.restSeconds = 60, this.notes = ''});
}

class _AddExerciseSheet extends StatefulWidget {
  final List<String> suggestions;
  final Function(_ExerciseEntry) onAdd;
  const _AddExerciseSheet({required this.suggestions, required this.onAdd});

  @override
  State<_AddExerciseSheet> createState() => _AddExerciseSheetState();
}

class _AddExerciseSheetState extends State<_AddExerciseSheet> {
  final _nameCtrl = TextEditingController();
  final _notesCtrl = TextEditingController();
  int _sets = 3, _reps = 10, _rest = 60;
  String? _selected;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _notesCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppTheme.backgroundColor,
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
      child: SingleChildScrollView(
        child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
          Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(80), borderRadius: BorderRadius.circular(2)))),
          const SizedBox(height: 16),
          Text('Add Exercise', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 16),

          // Suggestions chips
          Wrap(
            spacing: 8, runSpacing: 8,
            children: widget.suggestions.map((s) {
              final sel = s == _selected;
              return GestureDetector(
                onTap: () => setState(() { _selected = s; _nameCtrl.text = s; }),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primaryColor : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primaryColor : Colors.grey.withAlpha(80)),
                  ),
                  child: Text(s, style: TextStyle(fontSize: 12, color: sel ? Colors.white : AppTheme.textPrimary, fontWeight: sel ? FontWeight.w600 : FontWeight.normal)),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 14),

          TextField(
            controller: _nameCtrl,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              labelText: 'Exercise Name',
              prefixIcon: const Icon(LucideIcons.dumbbell, color: AppTheme.primaryColor, size: 18),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            ),
            onChanged: (_) => setState(() => _selected = null),
          ),
          const SizedBox(height: 16),

          Row(children: [
            Expanded(child: _StepCounter(label: 'Sets', value: _sets, min: 1, max: 10,
                onChanged: (v) => setState(() => _sets = v))),
            const SizedBox(width: 10),
            Expanded(child: _StepCounter(label: 'Reps', value: _reps, min: 1, max: 100,
                onChanged: (v) => setState(() => _reps = v))),
            const SizedBox(width: 10),
            Expanded(child: _StepCounter(label: 'Rest (s)', value: _rest, min: 0, max: 300, step: 15,
                onChanged: (v) => setState(() => _rest = v))),
          ]),
          const SizedBox(height: 14),

          TextField(
            controller: _notesCtrl,
            decoration: InputDecoration(
              labelText: 'Notes (optional)',
              prefixIcon: const Icon(LucideIcons.pencil, color: AppTheme.primaryColor, size: 18),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
            ),
          ),
          const SizedBox(height: 20),

          Row(children: [
            Expanded(child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))),
              child: const Text('Cancel'),
            )),
            const SizedBox(width: 12),
            Expanded(child: ElevatedButton(
              onPressed: () {
                final name = _nameCtrl.text.trim();
                if (name.isEmpty) return;
                widget.onAdd(_ExerciseEntry(name: name, sets: _sets, reps: _reps, restSeconds: _rest, notes: _notesCtrl.text.trim()));
                Navigator.pop(context);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0,
              ),
              child: const Text('Add Exercise', style: TextStyle(fontWeight: FontWeight.w700)),
            )),
          ]),
        ]),
      ),
    );
  }
}

class _StepCounter extends StatelessWidget {
  final String label;
  final int value, min, max, step;
  final ValueChanged<int> onChanged;
  const _StepCounter({required this.label, required this.value, required this.min, required this.max, this.step = 1, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(14), border: Border.all(color: Colors.grey.withAlpha(40))),
      child: Column(children: [
        Text(label, style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary)),
        const SizedBox(height: 6),
        Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          GestureDetector(
            onTap: () { if (value - step >= min) onChanged(value - step); },
            child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle),
                child: const Icon(LucideIcons.minus, size: 12)),
          ),
          const SizedBox(width: 8),
          Text('$value', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
          const SizedBox(width: 8),
          GestureDetector(
            onTap: () { if (value + step <= max) onChanged(value + step); },
            child: Container(padding: const EdgeInsets.all(4), decoration: const BoxDecoration(color: AppTheme.backgroundColor, shape: BoxShape.circle),
                child: const Icon(LucideIcons.plus, size: 12)),
          ),
        ]),
      ]),
    );
  }
}
