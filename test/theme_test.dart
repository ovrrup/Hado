import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hado/core/theme.dart';

void main() {
  test('HadoPalettes contains exact hex values requested', () {
    expect(HadoPalettes.habitTerracotta.value, equals(0xFFB98258));
    expect(HadoPalettes.habitSage.value, equals(0xFF8FB9B2));
    expect(HadoPalettes.habitCream.value, equals(0xFFE7DFD0));

    expect(HadoPalettes.reminderApricot.value, equals(0xFFE9B17F));
    expect(HadoPalettes.reminderCoral.value, equals(0xFFDB7870));
    expect(HadoPalettes.reminderCeladon.value, equals(0xFFD7E1D4));
  });

  test('AppTheme generates distinct themes for habits vs reminders', () {
    final habitTheme = AppTheme.getTheme(true);
    final reminderTheme = AppTheme.getTheme(false);

    expect(habitTheme.primaryColor, equals(HadoPalettes.habitTerracotta));
    expect(reminderTheme.primaryColor, equals(HadoPalettes.reminderCoral));
    expect(habitTheme.scaffoldBackgroundColor, equals(Colors.transparent));
  });
}
