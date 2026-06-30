import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:stalvi/core/utils/icon_helper.dart';

void main() {
  group('getIconData Tests', () {
    test('resolves preset string keys to rounded Material Icons', () {
      expect(getIconData('wallet'), Icons.account_balance_wallet_rounded);
      expect(getIconData('restaurant'), Icons.restaurant_rounded);
      expect(getIconData('shopping_cart'), Icons.shopping_cart_rounded);
    });

    test('parses hex code points to dynamic IconData', () {
      final icon = getIconData('0xe3af');
      expect(icon.codePoint, 0xe3af);
      expect(icon.fontFamily, 'MaterialIcons');

      final iconNo0x = getIconData('E3AF');
      expect(iconNo0x.codePoint, 0xe3af);
      expect(iconNo0x.fontFamily, 'MaterialIcons');
    });

    test('parses decimal code points to dynamic IconData', () {
      final icon = getIconData('58287');
      expect(icon.codePoint, 58287);
      expect(icon.fontFamily, 'MaterialIcons');
    });

    test('falls back to Icons.category_rounded for unknown names', () {
      expect(getIconData('__unknown__'), Icons.category_rounded);
    });
  });
}
