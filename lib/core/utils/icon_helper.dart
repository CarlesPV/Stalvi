import 'package:flutter/material.dart';

IconData getIconData(String name) {
  switch (name) {
    // Account Icons
    case 'wallet':
      return Icons.account_balance_wallet_rounded;
    case 'business':
      return Icons.business_center_rounded;
    case 'savings':
      return Icons.savings_rounded;
    case 'credit_card':
      return Icons.credit_card_rounded;

    // Category / Tag / General Icons
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'attach_money':
      return Icons.attach_money_rounded;
    case 'home':
      return Icons.home_rounded;
    case 'lightbulb':
      return Icons.lightbulb_rounded;
    case 'movie':
      return Icons.movie_rounded;
    case 'shopping_bag':
      return Icons.shopping_bag_rounded;
    case 'medical_services':
      return Icons.medical_services_rounded;
    case 'school':
      return Icons.school_rounded;
    case 'subscriptions':
      return Icons.subscriptions_rounded;
    case 'flight':
      return Icons.flight_rounded;
    case 'trending_up':
      return Icons.trending_up_rounded;
    case 'card_giftcard':
      return Icons.card_giftcard_rounded;

    default:
      return Icons.category_rounded;
  }
}
