import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../providers/app_provider.dart';
import '../models/health_models.dart';
import '../theme/app_theme.dart';

class LogMealScreen extends StatefulWidget {
  const LogMealScreen({super.key});
  @override
  State<LogMealScreen> createState() => _LogMealScreenState();
}

class _LogMealScreenState extends State<LogMealScreen> {
  final _foodCtrl = TextEditingController();
  final _calCtrl = TextEditingController();
  final _proteinCtrl = TextEditingController();
  final _carbsCtrl = TextEditingController();
  final _fatCtrl = TextEditingController();
  final _servingCtrl = TextEditingController(text: '100');

  String _selectedMeal = 'breakfast';
  bool _isSearching = false;
  bool _scannerOpen = false;
  List<Map<String, dynamic>> _searchResults = [];

  final List<String> _mealTypes = ['breakfast', 'lunch', 'dinner', 'snack'];

  Future<void> _searchFood(String query) async {
    if (query.length < 2) return;
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse(
          'https://world.openfoodfacts.org/cgi/search.pl?search_terms=${Uri.encodeComponent(query)}&json=1&page_size=5');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        final products = data['products'] as List? ?? [];
        setState(() {
          _searchResults = products.map((p) {
            final n = p['nutriments'] ?? {};
            return {
              'name': p['product_name'] ?? 'Unknown',
              'calories': (n['energy-kcal_100g'] as num?)?.toDouble() ?? 0.0,
              'protein': (n['proteins_100g'] as num?)?.toDouble() ?? 0.0,
              'carbs': (n['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
              'fat': (n['fat_100g'] as num?)?.toDouble() ?? 0.0,
            };
          }).toList();
        });
      }
    } catch (_) {
      // Network error — user can still enter manually
    } finally {
      setState(() => _isSearching = false);
    }
  }

  void _selectFood(Map<String, dynamic> food) {
    setState(() {
      _foodCtrl.text = food['name'];
      _calCtrl.text = (food['calories'] as double).toStringAsFixed(1);
      _proteinCtrl.text = (food['protein'] as double).toStringAsFixed(1);
      _carbsCtrl.text = (food['carbs'] as double).toStringAsFixed(1);
      _fatCtrl.text = (food['fat'] as double).toStringAsFixed(1);
      _searchResults = [];
    });
  }

  Future<void> _lookupBarcode(String barcode) async {
    setState(() => _isSearching = true);
    try {
      final url = Uri.parse('https://world.openfoodfacts.org/api/v0/product/$barcode.json');
      final res = await http.get(url).timeout(const Duration(seconds: 8));
      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        if (data['status'] == 1) {
          final p = data['product'];
          final n = p['nutriments'] ?? {};
          _selectFood({
            'name': p['product_name'] ?? 'Unknown',
            'calories': (n['energy-kcal_100g'] as num?)?.toDouble() ?? 0.0,
            'protein': (n['proteins_100g'] as num?)?.toDouble() ?? 0.0,
            'carbs': (n['carbohydrates_100g'] as num?)?.toDouble() ?? 0.0,
            'fat': (n['fat_100g'] as num?)?.toDouble() ?? 0.0,
          });
        }
      }
    } catch (_) {} finally {
      setState(() {_isSearching = false; _scannerOpen = false;});
    }
  }

  Future<void> _save() async {
    if (_foodCtrl.text.isEmpty || _calCtrl.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter food name and calories')));
      return;
    }
    final p = Provider.of<AppProvider>(context, listen: false);
    if (p.currentUser == null) return;
    final meal = MealLogModel(
      userId: p.currentUser!.id,
      mealType: _selectedMeal,
      foodName: _foodCtrl.text,
      calories: double.tryParse(_calCtrl.text) ?? 0,
      protein: double.tryParse(_proteinCtrl.text) ?? 0,
      carbs: double.tryParse(_carbsCtrl.text) ?? 0,
      fat: double.tryParse(_fatCtrl.text) ?? 0,
      servingGrams: double.tryParse(_servingCtrl.text) ?? 100,
      loggedAt: DateTime.now(),
    );
    await p.addMeal(meal);
    if (mounted) {
      context.pop();
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: const Text('Meal logged!'),
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppTheme.primaryColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        leading: IconButton(icon: const Icon(LucideIcons.arrowLeft), onPressed: () => context.pop()),
        title: Text('Log Meal', style: Theme.of(context).textTheme.titleLarge),
        actions: [
          TextButton(
            onPressed: _save,
            child: const Text('Save', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
      body: _scannerOpen
          ? _buildScanner()
          : SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                // Meal type selector
                Text('Meal Type', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: _mealTypes.map((type) {
                  final isSelected = _selectedMeal == type;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedMeal = type),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 8),
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isSelected ? AppTheme.primaryColor : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: AppTheme.softShadow,
                        ),
                        child: Column(children: [
                          Text(_mealEmoji(type), style: const TextStyle(fontSize: 18)),
                          const SizedBox(height: 4),
                          Text(type[0].toUpperCase() + type.substring(1),
                              style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: isSelected ? Colors.white : AppTheme.textPrimary)),
                        ]),
                      ),
                    ),
                  );
                }).toList()),

                const SizedBox(height: 24),

                // Search + Barcode
                Text('Find Food', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(
                    child: TextField(
                      controller: _foodCtrl,
                      style: const TextStyle(color: AppTheme.textPrimary),
                      onChanged: (v) => _searchFood(v),
                      decoration: InputDecoration(
                        hintText: 'Search food (e.g., chicken breast)...',
                        hintStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 13),
                        prefixIcon: const Icon(LucideIcons.search, color: AppTheme.primaryColor, size: 18),
                        suffixIcon: _isSearching ? const SizedBox(width: 18, height: 18, child: Center(child: CircularProgressIndicator(strokeWidth: 2))) : null,
                        filled: true, fillColor: Colors.white,
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide.none),
                        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(16), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
                        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  GestureDetector(
                    onTap: () => setState(() => _scannerOpen = true),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(color: AppTheme.primaryColor, borderRadius: BorderRadius.circular(16)),
                      child: const Icon(LucideIcons.scan, color: Colors.white, size: 22),
                    ),
                  ),
                ]),

                // Search Results
                if (_searchResults.isNotEmpty) ...[
                  const SizedBox(height: 8),
                  Container(
                    decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), boxShadow: AppTheme.softShadow),
                    child: ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: _searchResults.length,
                      separatorBuilder: (_, __) => const Divider(height: 1),
                      itemBuilder: (ctx, i) {
                        final food = _searchResults[i];
                        return ListTile(
                          title: Text(food['name'], style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                          subtitle: Text('${(food['calories'] as double).toInt()} kcal/100g', style: const TextStyle(fontSize: 12)),
                          trailing: const Icon(LucideIcons.plus, color: AppTheme.primaryColor, size: 18),
                          onTap: () => _selectFood(food),
                        );
                      },
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // Nutrition Fields
                Text('Nutrition Details', style: Theme.of(context).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w600)),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_calCtrl, 'Calories (kcal)', LucideIcons.flame)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_servingCtrl, 'Serving (g)', LucideIcons.scale)),
                ]),
                const SizedBox(height: 12),
                Row(children: [
                  Expanded(child: _numField(_proteinCtrl, 'Protein (g)', LucideIcons.beef)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_carbsCtrl, 'Carbs (g)', LucideIcons.wheat)),
                  const SizedBox(width: 12),
                  Expanded(child: _numField(_fatCtrl, 'Fat (g)', LucideIcons.droplets)),
                ]),

                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _save,
                    icon: const Icon(LucideIcons.checkCircle),
                    label: const Text('Log Meal', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                      elevation: 0,
                    ),
                  ),
                ),
              ]),
            ),
    );
  }

  Widget _buildScanner() {
    return Stack(children: [
      MobileScanner(
        onDetect: (capture) {
          final barcodes = capture.barcodes;
          if (barcodes.isNotEmpty && barcodes.first.rawValue != null) {
            _lookupBarcode(barcodes.first.rawValue!);
          }
        },
      ),
      Positioned(
        top: 16, left: 16,
        child: GestureDetector(
          onTap: () => setState(() => _scannerOpen = false),
          child: Container(padding: const EdgeInsets.all(10), decoration: const BoxDecoration(color: Colors.black54, shape: BoxShape.circle),
              child: const Icon(LucideIcons.x, color: Colors.white)),
        ),
      ),
      const Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Icon(LucideIcons.scan, color: Colors.white, size: 64),
          SizedBox(height: 16),
          Text('Point camera at barcode', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w600)),
        ]),
      ),
    ]);
  }

  Widget _numField(TextEditingController ctrl, String label, IconData icon) {
    return TextField(
      controller: ctrl,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500),
      decoration: InputDecoration(
        labelText: label, labelStyle: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
        prefixIcon: Icon(icon, color: AppTheme.primaryColor, size: 16),
        filled: true, fillColor: Colors.white,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide.none),
        enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: BorderSide(color: Colors.grey.withAlpha(40))),
        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(14), borderSide: const BorderSide(color: AppTheme.primaryColor, width: 1.5)),
        contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      ),
    );
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'breakfast': return '🌅';
      case 'lunch': return '🍱';
      case 'dinner': return '🍽️';
      default: return '🍎';
    }
  }
}
