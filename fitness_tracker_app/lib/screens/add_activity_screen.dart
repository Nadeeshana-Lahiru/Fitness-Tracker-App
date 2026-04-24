import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../models/activity_model.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class AddActivityScreen extends StatefulWidget {
  const AddActivityScreen({super.key});

  @override
  State<AddActivityScreen> createState() => _AddActivityScreenState();
}

class _AddActivityScreenState extends State<AddActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  String _selectedType = 'Running';
  final _durationController = TextEditingController();
  final _caloriesController = TextEditingController();

  final List<Map<String, dynamic>> _activityTypes = [
    {'label': 'Running', 'icon': LucideIcons.footprints},
    {'label': 'Walking', 'icon': LucideIcons.personStanding},
    {'label': 'Cycling', 'icon': LucideIcons.bike},
    {'label': 'Weightlifting', 'icon': LucideIcons.dumbbell},
    {'label': 'Yoga', 'icon': LucideIcons.heart},
  ];

  @override
  void dispose() {
    _durationController.dispose();
    _caloriesController.dispose();
    super.dispose();
  }

  void _saveActivity() async {
    if (_formKey.currentState!.validate()) {
      final shouldSave = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
          title: const Text('Confirm Save'),
          content: Text('Log "$_selectedType" for ${_durationController.text} mins and ${_caloriesController.text} kcal?'),
          actions: [
            TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () => Navigator.of(ctx).pop(true),
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
              child: const Text('Yes, Save'),
            ),
          ],
        ),
      );
      if (shouldSave != true) return;
      if (!mounted) return;
      final provider = Provider.of<AppProvider>(context, listen: false);
      if (provider.currentUser == null) return;
      final activity = ActivityModel(
        userId: provider.currentUser!.id,
        type: _selectedType,
        durationMinutes: int.parse(_durationController.text),
        caloriesBurned: int.parse(_caloriesController.text),
        date: DateTime.now(),
      );
      await provider.addActivity(activity);
      if (mounted) {
        context.pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Activity logged successfully!'),
            behavior: SnackBarBehavior.floating,
            backgroundColor: AppTheme.primaryColor,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
      }
    }
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
          onPressed: () => context.pop(),
        ),
        title: Text('Log Activity', style: Theme.of(context).textTheme.titleLarge),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 8),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Type Selector
              Text('Choose Activity', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 14),
              SizedBox(
                height: 100,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: _activityTypes.length,
                  itemBuilder: (ctx, i) {
                    final type = _activityTypes[i]['label'] as String;
                    final icon = _activityTypes[i]['icon'] as IconData;
                    final isSelected = _selectedType == type;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedType = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 250),
                        margin: const EdgeInsets.only(right: 14),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: isSelected ? [] : AppTheme.softShadow,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(icon, color: isSelected ? Colors.white : AppTheme.primaryColor, size: 26),
                            const SizedBox(height: 8),
                            Text(
                              type,
                              style: TextStyle(
                                color: isSelected ? Colors.white : AppTheme.textPrimary,
                                fontWeight: FontWeight.w500,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 28),

              // Duration Field
              Text('Duration (minutes)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildFormField(
                controller: _durationController,
                hint: 'e.g., 30',
                icon: LucideIcons.timer,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter duration';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 20),

              // Calories Field
              Text('Calories Burned', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
              const SizedBox(height: 12),
              _buildFormField(
                controller: _caloriesController,
                hint: 'e.g., 250',
                icon: LucideIcons.flame,
                keyboardType: TextInputType.number,
                validator: (v) {
                  if (v == null || v.isEmpty) return 'Please enter calories';
                  if (int.tryParse(v) == null) return 'Enter a valid number';
                  return null;
                },
              ),

              const SizedBox(height: 40),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _saveActivity,
                  icon: const Icon(LucideIcons.checkCircle),
                  label: const Text('Log Activity', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    TextInputType? keyboardType,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      validator: validator,
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 20),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        errorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red)),
        focusedErrorBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: Colors.red, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      ),
    );
  }
}
