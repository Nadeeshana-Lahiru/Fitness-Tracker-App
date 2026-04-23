import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../providers/app_provider.dart';

import 'package:image_picker/image_picker.dart';
import 'package:image_cropper/image_cropper.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final ImagePicker _picker = ImagePicker();

  Future<void> _pickImage(AppProvider appProvider) async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        CroppedFile? croppedFile = await ImageCropper().cropImage(
          sourcePath: image.path,
          uiSettings: [
            AndroidUiSettings(
                toolbarTitle: 'Crop Profile Picture',
                toolbarColor: Theme.of(context).primaryColor,
                toolbarWidgetColor: Colors.white,
                initAspectRatio: CropAspectRatioPreset.square,
                lockAspectRatio: true),
            IOSUiSettings(
              title: 'Crop Profile Picture',
            ),
            WebUiSettings(
              context: context,
              presentStyle: WebPresentStyle.dialog,
            ),
          ],
        );

        if (croppedFile != null) {
          await appProvider.updateProfileImage(croppedFile.path);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Profile image updated!')),
            );
          }
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to pick/crop image.')),
        );
      }
    }
  }

  void _editProfile(AppProvider appProvider) {
    final nameCtrl = TextEditingController(text: appProvider.currentUser?.name);
    final ageCtrl = TextEditingController(text: appProvider.currentUser?.age);
    final mobileCtrl = TextEditingController(text: appProvider.currentUser?.mobileNumber);
    final heightCtrl = TextEditingController(text: appProvider.currentUser?.height);
    final weightCtrl = TextEditingController(text: appProvider.currentUser?.weight);

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
            left: 16, right: 16, top: 16,
          ),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Edit Profile', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                TextField(controller: nameCtrl, decoration: const InputDecoration(labelText: 'Name', border: OutlineInputBorder())),
                const SizedBox(height: 10),
                TextField(controller: ageCtrl, decoration: const InputDecoration(labelText: 'Age', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: mobileCtrl, decoration: const InputDecoration(labelText: 'Mobile Number', border: OutlineInputBorder()), keyboardType: TextInputType.phone),
                const SizedBox(height: 10),
                TextField(controller: heightCtrl, decoration: const InputDecoration(labelText: 'Height (cm)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 10),
                TextField(controller: weightCtrl, decoration: const InputDecoration(labelText: 'Weight (kg)', border: OutlineInputBorder()), keyboardType: TextInputType.number),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancel')),
                    ElevatedButton(
                      onPressed: () async {
                        await appProvider.updateUserProfile(
                          name: nameCtrl.text,
                          age: ageCtrl.text,
                          mobileNumber: mobileCtrl.text,
                          height: heightCtrl.text,
                          weight: weightCtrl.text,
                        );
                        if (context.mounted) Navigator.pop(context);
                      },
                      child: const Text('Save'),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
              ],
            ),
          ),
        );
      },
    );
  }

  void _confirmLogout(AppProvider appProvider) async {
    final shouldLogout = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red, foregroundColor: Colors.white),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Yes, Logout'),
            ),
          ],
        );
      },
    );

    if (shouldLogout == true) {
      await appProvider.logout();
      if (mounted) {
        context.go('/login');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final appProvider = Provider.of<AppProvider>(context);
    final user = appProvider.currentUser;
    final activities = appProvider.activities;

    int totalWorkouts = activities.length;
    int allTimeCalories = activities.fold(0, (sum, item) => sum + item.caloriesBurned);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => _confirmLogout(appProvider),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            // User Info
            Center(
              child: Column(
                children: [
                  GestureDetector(
                    onTap: () => _pickImage(appProvider),
                    child: Stack(
                      children: [
                        CircleAvatar(
                          radius: 50,
                          backgroundImage: (user != null && user.photoUrl != null)
                              ? (kIsWeb || user.photoUrl!.startsWith('http') || user.photoUrl!.startsWith('blob')
                                  ? NetworkImage(user.photoUrl!)
                                  : FileImage(File(user.photoUrl!)) as ImageProvider)
                              : null,
                          child: user?.photoUrl == null ? const Icon(Icons.person, size: 50) : null,
                        ),
                        Positioned(
                          bottom: 0,
                          right: 0,
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              shape: BoxShape.circle,
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(4.0),
                              child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    user?.name ?? 'Unknown User',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    user?.email ?? '',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
                  ),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: () => _editProfile(appProvider),
                    icon: const Icon(Icons.edit, size: 18),
                    label: const Text('Edit Profile'),
                    style: OutlinedButton.styleFrom(
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            
            // Personal Info Card
            if (user?.age != null || user?.mobileNumber != null || user?.height != null || user?.weight != null)
              Card(
                margin: const EdgeInsets.only(bottom: 24),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Personal Info', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold)),
                      const Divider(),
                      if (user?.age != null && user!.age!.isNotEmpty) _InfoRow(title: 'Age', value: '${user.age} yrs'),
                      if (user?.mobileNumber != null && user!.mobileNumber!.isNotEmpty) _InfoRow(title: 'Mobile', value: user.mobileNumber!),
                      if (user?.height != null && user!.height!.isNotEmpty) _InfoRow(title: 'Height', value: '${user.height} cm'),
                      if (user?.weight != null && user!.weight!.isNotEmpty) _InfoRow(title: 'Weight', value: '${user.weight} kg'),
                    ],
                  ),
                ),
              ),

            // Stats Row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _StatColumn(title: 'Workouts', value: '$totalWorkouts'),
                _StatColumn(title: 'Total Calories', value: '$allTimeCalories'),
              ],
            ),
            
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            
            // Recent Activities
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Recent Activities',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),
            
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: activities.length,
              itemBuilder: (context, index) {
                final activity = activities[index];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Theme.of(context).primaryColor.withOpacity(0.2),
                      child: Icon(
                        _getIconForType(activity.type),
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    title: Text(activity.type, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(DateFormat('MMM dd, yyyy').format(activity.date)),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text('${activity.caloriesBurned} kcal', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.orange)),
                        Text('${activity.durationMinutes} mins', style: const TextStyle(color: Colors.grey, fontSize: 12)),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType(String type) {
    switch (type) {
      case 'Running':
        return Icons.directions_run;
      case 'Walking':
        return Icons.directions_walk;
      case 'Cycling':
        return Icons.directions_bike;
      case 'Weightlifting':
        return Icons.fitness_center;
      case 'Yoga':
        return Icons.self_improvement;
      default:
        return Icons.sports;
    }
  }
}

class _StatColumn extends StatelessWidget {
  final String title;
  final String value;

  const _StatColumn({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Theme.of(context).primaryColor,
              ),
        ),
        const SizedBox(height: 4),
        Text(
          title,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: Colors.grey),
        ),
      ],
    );
  }
}

class _InfoRow extends StatelessWidget {
  final String title;
  final String value;

  const _InfoRow({required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: const TextStyle(color: Colors.grey)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }
}
