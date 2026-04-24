import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';
import '../providers/app_provider.dart';
import '../theme/app_theme.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(AppProvider p) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image == null) return;
      CroppedFile? cropped = await ImageCropper().cropImage(
        sourcePath: image.path,
        uiSettings: [
          AndroidUiSettings(toolbarTitle: 'Crop Picture', toolbarColor: AppTheme.primaryColor, toolbarWidgetColor: Colors.white, initAspectRatio: CropAspectRatioPreset.square, lockAspectRatio: true),
          IOSUiSettings(title: 'Crop Picture'),
          WebUiSettings(context: context, presentStyle: WebPresentStyle.dialog),
        ],
      );
      if (cropped != null) {
        await p.updateProfileImage(cropped.path);
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Profile image updated!')));
      }
    } catch (_) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to pick image.')));
    }
  }

  void _editProfile(AppProvider p) {
    final nc = TextEditingController(text: p.currentUser?.name);
    final ac = TextEditingController(text: p.currentUser?.age);
    final mc = TextEditingController(text: p.currentUser?.mobileNumber);
    final hc = TextEditingController(text: p.currentUser?.height);
    final wc = TextEditingController(text: p.currentUser?.weight);
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        decoration: const BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.vertical(top: Radius.circular(32))),
        padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom + 24, left: 24, right: 24, top: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey.withAlpha(80), borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 16),
              Text('Edit Profile', style: Theme.of(ctx).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              _bsField(ctx, nc, 'Full Name', LucideIcons.user),
              const SizedBox(height: 12),
              _bsField(ctx, ac, 'Age', LucideIcons.calendar, ktype: TextInputType.number),
              const SizedBox(height: 12),
              _bsField(ctx, mc, 'Mobile Number', LucideIcons.phone, ktype: TextInputType.phone),
              const SizedBox(height: 12),
              _bsField(ctx, hc, 'Height (cm)', LucideIcons.arrowUpDown, ktype: TextInputType.number),
              const SizedBox(height: 12),
              _bsField(ctx, wc, 'Weight (kg)', LucideIcons.scale, ktype: TextInputType.number),
              const SizedBox(height: 20),
              Row(children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(ctx), style: OutlinedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14))), child: const Text('Cancel'))),
                const SizedBox(width: 12),
                Expanded(child: ElevatedButton(onPressed: () async { await p.updateUserProfile(name: nc.text, age: ac.text, mobileNumber: mc.text, height: hc.text, weight: wc.text); if (ctx.mounted) Navigator.pop(ctx); }, style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)), elevation: 0), child: const Text('Save'))),
              ]),
            ],
          ),
        ),
      ),
    );
  }

  Widget _bsField(BuildContext ctx, TextEditingController ctrl, String label, IconData icon, {TextInputType? ktype}) {
    return TextField(
      controller: ctrl,
      keyboardType: ktype,
      style: const TextStyle(color: AppTheme.textPrimary),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 18),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  void _confirmLogout(AppProvider p) async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(false), child: const Text('Cancel')),
          ElevatedButton(style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white), onPressed: () => Navigator.of(ctx).pop(true), child: const Text('Logout')),
        ],
      ),
    );
    if (yes == true) {
      await p.logout();
      if (mounted) context.go('/login');
    }
  }

  IconData _getIcon(String type) {
    switch (type) {
      case 'Running': return LucideIcons.footprints;
      case 'Walking': return LucideIcons.personStanding;
      case 'Cycling': return LucideIcons.bike;
      case 'Weightlifting': return LucideIcons.dumbbell;
      case 'Yoga': return LucideIcons.heart;
      default: return LucideIcons.activity;
    }
  }

  @override
  Widget build(BuildContext context) {
    final p = Provider.of<AppProvider>(context);
    final user = p.currentUser;
    final acts = p.activities;
    final totalCals = acts.fold(0, (s, a) => s + a.caloriesBurned);
    final totalMins = acts.fold(0, (s, a) => s + a.durationMinutes);

    ImageProvider? avatar;
    final photoUrl = user?.photoUrl;
    if (photoUrl != null) {
      avatar = (kIsWeb || photoUrl.startsWith('http') || photoUrl.startsWith('blob'))
          ? NetworkImage(photoUrl) as ImageProvider : FileImage(File(photoUrl));
    }

    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 270,
            pinned: true,
            backgroundColor: AppTheme.primaryColor,
            leading: IconButton(icon: const Icon(LucideIcons.arrowLeft, color: Colors.white), onPressed: () => context.pop()),
            actions: [IconButton(icon: const Icon(LucideIcons.logOut, color: Colors.white), onPressed: () => _confirmLogout(p))],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(gradient: LinearGradient(colors: [AppTheme.primaryColor, AppTheme.primaryLight], begin: Alignment.topLeft, end: Alignment.bottomRight)),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const SizedBox(height: 60),
                    GestureDetector(
                      onTap: () => _pickImage(p),
                      child: Stack(children: [
                        CircleAvatar(radius: 50, backgroundColor: Colors.white.withAlpha(50), backgroundImage: avatar, child: avatar == null ? const Icon(Icons.person, size: 50, color: Colors.white) : null),
                        Positioned(bottom: 0, right: 0, child: Container(padding: const EdgeInsets.all(6), decoration: BoxDecoration(color: Colors.white, shape: BoxShape.circle, border: Border.all(color: AppTheme.primaryColor, width: 1.5)), child: const Icon(LucideIcons.camera, color: AppTheme.primaryColor, size: 14))),
                      ]),
                    ),
                    const SizedBox(height: 10),
                    Text(user?.name ?? 'Unknown User', style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                    Text(user?.email ?? '', style: TextStyle(color: Colors.white.withAlpha(200), fontSize: 12)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: () => _editProfile(p),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
                        decoration: BoxDecoration(color: Colors.white.withAlpha(40), borderRadius: BorderRadius.circular(20), border: Border.all(color: Colors.white.withAlpha(100))),
                        child: const Row(mainAxisSize: MainAxisSize.min, children: [Icon(LucideIcons.pencil, color: Colors.white, size: 13), SizedBox(width: 6), Text('Edit Profile', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w500))]),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Expanded(child: _StatCard(title: 'Workouts', value: '${acts.length}', icon: LucideIcons.dumbbell, color: const Color(0xFFD3E0FA))),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Total Cals', value: '$totalCals', icon: LucideIcons.flame, color: const Color(0xFFFFE0B2))),
                  const SizedBox(width: 12),
                  Expanded(child: _StatCard(title: 'Total Mins', value: '$totalMins', icon: LucideIcons.clock, color: const Color(0xFFFFF9C4))),
                ]),
                if (user?.age != null || user?.height != null || user?.weight != null || user?.mobileNumber != null) ...[
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24), boxShadow: AppTheme.softShadow),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      Text('Personal Info', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const SizedBox(height: 14),
                      if (user?.age?.isNotEmpty == true) _InfoRow(icon: LucideIcons.calendar, title: 'Age', value: '${user!.age} yrs'),
                      if (user?.mobileNumber?.isNotEmpty == true) _InfoRow(icon: LucideIcons.phone, title: 'Mobile', value: user!.mobileNumber!),
                      if (user?.height?.isNotEmpty == true) _InfoRow(icon: LucideIcons.arrowUpDown, title: 'Height', value: '${user!.height} cm'),
                      if (user?.weight?.isNotEmpty == true) _InfoRow(icon: LucideIcons.scale, title: 'Weight', value: '${user!.weight} kg'),
                    ]),
                  ),
                ],
                const SizedBox(height: 20),
                Text('Recent Activities', style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold)),
                const SizedBox(height: 14),
                if (acts.isEmpty)
                  Padding(padding: const EdgeInsets.symmetric(vertical: 40), child: Center(child: Text('No activities logged yet', style: Theme.of(context).textTheme.bodyMedium)))
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: acts.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (ctx, i) {
                      final a = acts[i];
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(20), boxShadow: AppTheme.softShadow),
                        child: Row(children: [
                          Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: AppTheme.primaryColor.withAlpha(25), shape: BoxShape.circle), child: Icon(_getIcon(a.type), color: AppTheme.primaryColor, size: 20)),
                          const SizedBox(width: 14),
                          Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(a.type, style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 14)),
                            const SizedBox(height: 3),
                            Text(DateFormat('MMM dd, yyyy').format(a.date), style: Theme.of(ctx).textTheme.bodySmall),
                          ])),
                          Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                            Text('${a.caloriesBurned} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.primaryColor, fontSize: 13)),
                            const SizedBox(height: 3),
                            Text('${a.durationMinutes} mins', style: Theme.of(ctx).textTheme.bodySmall),
                          ]),
                        ]),
                      );
                    },
                  ),
                const SizedBox(height: 100),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title, value;
  final IconData icon;
  final Color color;
  const _StatCard({required this.title, required this.value, required this.icon, required this.color});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 10),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(20)),
      child: Column(children: [
        Icon(icon, color: AppTheme.primaryColor, size: 22),
        const SizedBox(height: 8),
        Text(value, style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 4),
        Text(title, style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 10), textAlign: TextAlign.center),
      ]),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String title, value;
  const _InfoRow({required this.icon, required this.title, required this.value});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(children: [
        Icon(icon, color: AppTheme.primaryColor, size: 17),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 13)),
        const Spacer(),
        Text(value, style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary, fontSize: 13)),
      ]),
    );
  }
}
