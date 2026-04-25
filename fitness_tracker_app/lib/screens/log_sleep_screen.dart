import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import '../providers/app_provider.dart';
import '../models/health_models.dart';
import '../theme/app_theme.dart';

class LogSleepScreen extends StatefulWidget {
  const LogSleepScreen({super.key});
  @override
  State<LogSleepScreen> createState() => _LogSleepScreenState();
}

class _LogSleepScreenState extends State<LogSleepScreen> {
  TimeOfDay _bedTime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  int _quality = 4;
  final _notesCtrl = TextEditingController();

  double get _hoursSlept {
    final bedMins = _bedTime.hour * 60 + _bedTime.minute;
    final wakeMins = _wakeTime.hour * 60 + _wakeTime.minute;
    final diff = wakeMins < bedMins ? (1440 - bedMins) + wakeMins : wakeMins - bedMins;
    return diff / 60.0;
  }

  Future<void> _pickTime(bool isBed) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: isBed ? _bedTime : _wakeTime,
    );
    if (picked != null) {
      setState(() => isBed ? _bedTime = picked : _wakeTime = picked);
    }
  }

  Future<void> _save() async {
    final p = Provider.of<AppProvider>(context, listen: false);
    if (p.currentUser == null) return;
    final now = DateTime.now();
    final bed = DateTime(now.year, now.month, now.day, _bedTime.hour, _bedTime.minute);
    final wake = DateTime(now.year, now.month, now.day + 1, _wakeTime.hour, _wakeTime.minute);
    final log = SleepLogModel(
      userId: p.currentUser!.id,
      bedTime: bed,
      wakeTime: wake,
      qualityRating: _quality,
      notes: _notesCtrl.text.isEmpty ? null : _notesCtrl.text,
    );
    await p.addSleepLog(log);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Sleep logged!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final h = _hoursSlept.floor();
    final m = ((_hoursSlept - h) * 60).round();
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.pop()),
        title: Text('Log Sleep', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          // Duration Display
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 32),
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF3F51B5), AppTheme.primaryColor]),
              borderRadius: BorderRadius.circular(28),
            ),
            child: Column(children: [
              const Icon(LucideIcons.moon, color: Colors.white, size: 32),
              const SizedBox(height: 12),
              Text('${h}h ${m}min', style: const TextStyle(color: Colors.white, fontSize: 36, fontWeight: FontWeight.bold)),
              const Text('Tonight\'s sleep', style: TextStyle(color: Colors.white70, fontSize: 14)),
            ]),
          ),
          const SizedBox(height: 28),

          // Time Pickers
          Text('Sleep Time', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(children: [
            Expanded(child: _timeCard(context, 'Bedtime', LucideIcons.moon, _bedTime, () => _pickTime(true))),
            const SizedBox(width: 16),
            Expanded(child: _timeCard(context, 'Wake Up', LucideIcons.sunrise, _wakeTime, () => _pickTime(false))),
          ]),
          const SizedBox(height: 28),

          // Quality Rating
          Text('Sleep Quality', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) => GestureDetector(
              onTap: () => setState(() => _quality = i + 1),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.symmetric(horizontal: 6),
                child: Icon(
                  LucideIcons.star,
                  size: 40,
                  color: i < _quality ? Colors.amber : Colors.grey.withAlpha(80),
                ),
              ),
            )),
          ),
          const SizedBox(height: 28),

          // Notes
          Text('Notes (optional)', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
          const SizedBox(height: 14),
          TextField(
            controller: _notesCtrl,
            maxLines: 3,
            style: const TextStyle(color: AppTheme.textPrimary),
            decoration: InputDecoration(
              hintText: 'How did you sleep? Any disturbances?',
              hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
              filled: true, fillColor: Colors.white,
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
              enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
              focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
              contentPadding: const EdgeInsets.all(16),
            ),
          ),

          const Spacer(),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _save,
              icon: const Icon(LucideIcons.checkCircle),
              label: const Text('Save Sleep Log', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryColor,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 20),
        ]),
      ),
    );
  }

  Widget _timeCard(BuildContext context, String label, IconData icon, TimeOfDay time, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
        child: Column(children: [
          Icon(icon, color: AppTheme.primaryColor, size: 24),
          const SizedBox(height: 10),
          Text(time.format(context),
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontSize: 22, fontWeight: FontWeight.bold)),
          const SizedBox(height: 4),
          Text(label, style: Theme.of(context).textTheme.bodySmall),
        ]),
      ),
    );
  }
}
