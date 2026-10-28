import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:drift/drift.dart' as drift;
import '../../core/theme.dart';
import '../../data/database.dart';

class CreateHabitSheet extends StatefulWidget {
  final AppDatabase database;

  const CreateHabitSheet({super.key, required this.database});

  @override
  State<CreateHabitSheet> createState() => _CreateHabitSheetState();
}

class _CreateHabitSheetState extends State<CreateHabitSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _descController = TextEditingController();

  String _frequency = 'daily';
  int _selectedColor = HadoPalettes.habitTerracotta.value;

  static const List<int> _palette = [
    0xFFB98258, // Terracotta
    0xFF8FB9B2, // Sage
    0xFFE7DFD0, // Cream
    0xFF5C715E, // Forest Sage
    0xFFD69E2E, // Warm Ochre
    0xFF8C5A3C, // Deep Clay
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    await widget.database.insertHabit(
      HabitsCompanion.insert(
        title: _titleController.text.trim(),
        description: _descController.text.trim().isEmpty
            ? const drift.Value.absent()
            : drift.Value(_descController.text.trim()),
        frequency: drift.Value(_frequency),
        colorValue: drift.Value(_selectedColor),
      ),
    );

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFF7F4EF).withOpacity(0.92),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withOpacity(0.8),
          width: 1.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
          child: Padding(
            padding: EdgeInsets.fromLTRB(24, 16, 24, 24 + bottomInset),
            child: SingleChildScrollView(
              child: Form(
                key: _formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Center(
                      child: Container(
                        width: 44,
                        height: 5,
                        decoration: BoxDecoration(
                          color: Colors.black26,
                          borderRadius: BorderRadius.circular(3),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'New Habit',
                      style: TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF2C241E),
                        letterSpacing: -0.4,
                      ),
                    ),
                    const SizedBox(height: 18),
                    TextFormField(
                      controller: _titleController,
                      autofocus: true,
                      style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w600),
                      decoration: InputDecoration(
                        labelText: 'Habit Name',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        hintText: 'e.g. Read 20 pages, Morning stretch',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.1)),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: HadoPalettes.habitTerracotta, width: 2),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a habit title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _descController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'e.g. Right after morning coffee',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Frequency',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3C342E)),
                    ),
                    const SizedBox(height: 10),
                    SegmentedButton<String>(
                      style: SegmentedButton.styleFrom(
                        selectedBackgroundColor: HadoPalettes.habitTerracotta,
                        selectedForegroundColor: Colors.white,
                        backgroundColor: Colors.white.withOpacity(0.5),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      segments: const [
                        ButtonSegment(value: 'daily', label: Text('Daily', style: TextStyle(fontWeight: FontWeight.bold))),
                        ButtonSegment(value: 'weekdays', label: Text('Weekdays')),
                        ButtonSegment(value: 'weekends', label: Text('Weekends')),
                      ],
                      selected: {_frequency},
                      onSelectionChanged: (val) {
                        setState(() {
                          _frequency = val.first;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Color Palette Tag',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3C342E)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: _palette.map((colorVal) {
                        final isSelected = _selectedColor == colorVal;
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = colorVal;
                            });
                          },
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 46,
                            height: 46,
                            decoration: BoxDecoration(
                              color: Color(colorVal),
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: isSelected ? Colors.black87 : Colors.white.withOpacity(0.7),
                                width: isSelected ? 3 : 1.5,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Color(colorVal).withOpacity(0.4),
                                  blurRadius: 8,
                                  offset: const Offset(0, 3),
                                ),
                              ],
                            ),
                            child: isSelected
                                ? const Icon(Icons.check_rounded, color: Colors.white, size: 24)
                                : null,
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: HadoPalettes.habitTerracotta,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Save Habit',
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
