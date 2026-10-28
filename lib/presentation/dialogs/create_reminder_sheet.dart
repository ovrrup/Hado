import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:drift/drift.dart' as drift;
import 'package:intl/intl.dart';
import '../../core/theme.dart';
import '../../data/database.dart';
import '../../services/notification_service.dart';

class CreateReminderSheet extends StatefulWidget {
  final AppDatabase database;
  final NotificationService notificationService;

  const CreateReminderSheet({
    super.key,
    required this.database,
    required this.notificationService,
  });

  @override
  State<CreateReminderSheet> createState() => _CreateReminderSheetState();
}

class _CreateReminderSheetState extends State<CreateReminderSheet> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _notesController = TextEditingController();

  late DateTime _selectedDate;
  late TimeOfDay _selectedTime;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedDate = now;
    // default to next hour rounded
    final nextHour = now.add(const Duration(hours: 1));
    _selectedTime = TimeOfDay(hour: nextHour.hour, minute: 0);
  }

  @override
  void dispose() {
    _titleController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    HapticFeedback.selectionClick();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HadoPalettes.reminderCoral,
              onPrimary: Colors.white,
              surface: Color(0xFFFBF8F5),
              onSurface: Color(0xFF2C241E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _pickTime() async {
    HapticFeedback.selectionClick();
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: HadoPalettes.reminderCoral,
              onPrimary: Colors.white,
              surface: Color(0xFFFBF8F5),
              onSurface: Color(0xFF2C241E),
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  DateTime get _combinedDateTime {
    return DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;

    final dueDateTime = _combinedDateTime;

    final id = await widget.database.insertReminder(
      RemindersCompanion.insert(
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? const drift.Value.absent()
            : drift.Value(_notesController.text.trim()),
        dueDateTime: dueDateTime,
      ),
    );

    // Schedule notification if due date is in the future
    if (dueDateTime.isAfter(DateTime.now())) {
      await widget.notificationService.scheduleReminder(
        id: id,
        title: _titleController.text.trim(),
        notes: _notesController.text.trim().isEmpty
            ? 'Reminder due now'
            : _notesController.text.trim(),
        scheduledDate: dueDateTime,
      );
    }

    if (mounted) {
      Navigator.of(context).pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFFFAF6F2).withOpacity(0.93),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(32)),
        border: Border.all(
          color: Colors.white.withOpacity(0.85),
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
                      'New Reminder',
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
                        labelText: 'Reminder Title',
                        labelStyle: const TextStyle(fontWeight: FontWeight.w600),
                        hintText: 'e.g. Doctor appointment, Pay bill',
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
                          borderSide: const BorderSide(color: HadoPalettes.reminderCoral, width: 2),
                        ),
                      ),
                      validator: (val) {
                        if (val == null || val.trim().isEmpty) {
                          return 'Please enter a reminder title';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 14),
                    TextFormField(
                      controller: _notesController,
                      style: const TextStyle(fontSize: 16),
                      decoration: InputDecoration(
                        labelText: 'Notes (optional)',
                        hintText: 'e.g. Account number #1234, room 302',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.65),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: BorderSide(color: Colors.black.withOpacity(0.08)),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(16),
                          borderSide: const BorderSide(color: HadoPalettes.reminderCoral, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Schedule Date & Time',
                      style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Color(0xFF3C342E)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        // Date picker button
                        Expanded(
                          child: InkWell(
                            onTap: _pickDate,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: HadoPalettes.reminderApricot.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.calendar_today_rounded,
                                    size: 18,
                                    color: HadoPalettes.reminderCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      DateFormat('EEE, MMM d').format(_selectedDate),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C241E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        // Time picker button
                        Expanded(
                          child: InkWell(
                            onTap: _pickTime,
                            borderRadius: BorderRadius.circular(16),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                              decoration: BoxDecoration(
                                color: Colors.white.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(16),
                                border: Border.all(
                                  color: HadoPalettes.reminderApricot.withOpacity(0.4),
                                  width: 1.5,
                                ),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  const Icon(
                                    Icons.access_time_rounded,
                                    size: 18,
                                    color: HadoPalettes.reminderCoral,
                                  ),
                                  const SizedBox(width: 8),
                                  Flexible(
                                    child: Text(
                                      _selectedTime.format(context),
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: Color(0xFF2C241E),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 28),
                    SizedBox(
                      width: double.infinity,
                      height: 56,
                      child: FilledButton(
                        onPressed: _submit,
                        style: FilledButton.styleFrom(
                          backgroundColor: HadoPalettes.reminderCoral,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(18),
                          ),
                        ),
                        child: const Text(
                          'Save Reminder',
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
