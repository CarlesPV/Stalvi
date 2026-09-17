import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

void main() {
  group('Phase 75 Localization Keys Tests', () {
    test('verifies contextual action tooltips in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      // Edit item
      expect(l10nEn.a11yEditItem('Groceries'), 'Edit Groceries');
      expect(l10nEs.a11yEditItem('Alimentación'), 'Editar Alimentación');
      expect(l10nCa.a11yEditItem('Aliments'), 'Editar Aliments');

      // Delete item
      expect(l10nEn.a11yDeleteItem('Groceries'), 'Delete Groceries');
      expect(l10nEs.a11yDeleteItem('Alimentación'), 'Eliminar Alimentación');
      expect(l10nCa.a11yDeleteItem('Aliments'), 'Eliminar Aliments');
    });

    test('verifies dropdown screen reader labels in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      // Select Year
      expect(l10nEn.a11ySelectYear, 'Select Year');
      expect(l10nEs.a11ySelectYear, 'Seleccionar año');
      expect(l10nCa.a11ySelectYear, 'Seleccionar any');

      // Select Month
      expect(l10nEn.a11ySelectMonth, 'Select Month');
      expect(l10nEs.a11ySelectMonth, 'Seleccionar mes');
      expect(l10nCa.a11ySelectMonth, 'Seleccionar mes');
    });

    test('verifies progress bar semantic descriptions in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      // Progress bar percentage
      expect(l10nEn.a11yProgressBar('75'), 'Progress: 75 percent');
      expect(l10nEs.a11yProgressBar('75'), 'Progreso: 75 por ciento');
      expect(l10nCa.a11yProgressBar('75'), 'Progrés: 75 per cent');

      expect(l10nEn.a11yProgress('75'), 'Progress: 75 percent');
      expect(l10nEs.a11yProgress('75'), 'Progreso: 75 por ciento');
      expect(l10nCa.a11yProgress('75'), 'Progrés: 75 per cent');
    });
  });
}
