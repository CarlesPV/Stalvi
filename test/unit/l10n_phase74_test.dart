import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';

void main() {
  group('Phase 74 Localization Keys Tests', () {
    test('verifies contextual action translations in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(l10nEn.a11yRestoreItem('Transaction'), 'Restore Transaction');
      expect(l10nEs.a11yRestoreItem('Transacción'), 'Restaurar Transacción');
      expect(l10nCa.a11yRestoreItem('Transacció'), 'Restaurar Transacció');

      expect(
        l10nEn.a11yDeletePermanently('Transaction'),
        'Delete Transaction permanently',
      );
      expect(
        l10nEs.a11yDeletePermanently('Transacción'),
        'Eliminar Transacción permanentemente',
      );
      expect(
        l10nCa.a11yDeletePermanently('Transacció'),
        'Eliminar Transacció permanentment',
      );

      expect(l10nEn.a11yAcceptTerms, 'Accept terms and privacy policy');
      expect(
        l10nEs.a11yAcceptTerms,
        'Aceptar términos y política de privacidad',
      );
      expect(
        l10nCa.a11yAcceptTerms,
        'Acceptar termes i política de privacitat',
      );

      expect(
        l10nEn.a11yChartSummary('80% Expenses'),
        'Statistics chart. 80% Expenses',
      );
      expect(
        l10nEs.a11yChartSummary('80% Gastos'),
        'Gráfico de estadísticas. 80% Gastos',
      );
      expect(
        l10nCa.a11yChartSummary('80% Despeses'),
        'Gràfic d\'estadístiques. 80% Despeses',
      );
    });

    test('verifies color picker translations in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(l10nEn.a11yColorBlue, 'Blue');
      expect(l10nEs.a11yColorBlue, 'Azul');
      expect(l10nCa.a11yColorBlue, 'Blau');

      expect(l10nEn.a11yColorGreen, 'Green');
      expect(l10nEs.a11yColorGreen, 'Verde');
      expect(l10nCa.a11yColorGreen, 'Verd');

      expect(l10nEn.a11yColorAmber, 'Amber');
      expect(l10nEs.a11yColorAmber, 'Ámbar');
      expect(l10nCa.a11yColorAmber, 'Àmbre');
    });

    test('verifies icon translations in EN, ES, CA', () async {
      final l10nEn = await AppLocalizations.delegate.load(const Locale('en'));
      final l10nEs = await AppLocalizations.delegate.load(const Locale('es'));
      final l10nCa = await AppLocalizations.delegate.load(const Locale('ca'));

      expect(l10nEn.a11yIconAccountBalance, 'Bank');
      expect(l10nEs.a11yIconAccountBalance, 'Banco');
      expect(l10nCa.a11yIconAccountBalance, 'Banc');

      expect(l10nEn.a11yIconRestaurant, 'Restaurant');
      expect(l10nEs.a11yIconRestaurant, 'Restaurante');
      expect(l10nCa.a11yIconRestaurant, 'Restaurant');
    });
  });
}
