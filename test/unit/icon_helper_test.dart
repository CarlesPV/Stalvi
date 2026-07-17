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

    test('falls back to Icons.category_rounded for unknown names', () {
      expect(getIconData('__unknown__'), Icons.category_rounded);
    });
  });
}
