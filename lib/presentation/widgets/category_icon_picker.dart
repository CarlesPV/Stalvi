// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

/// A grid picker that displays 128 unique Material Icons relevant to finances,
/// lifestyle, housing, transport, health, and more.
///
/// The [selectedIcon] is the string key of the currently selected icon.
/// [onIconSelected] is called with the string key when the user taps an icon.
class CategoryIconPicker extends StatelessWidget {
  final String? selectedIcon;
  final ValueChanged<String> onIconSelected;

  const CategoryIconPicker({
    super.key,
    required this.onIconSelected,
    this.selectedIcon,
  });

  // ---------------------------------------------------------------------------
  // Icon catalogue — 128 unique, non-repeating entries
  // ---------------------------------------------------------------------------
  static const List<MapEntry<String, IconData>> icons = [
    // ── Finance & Banking ────────────────────────────────────────────────────
    MapEntry('account_balance', Icons.account_balance),
    MapEntry('account_balance_wallet', Icons.account_balance_wallet),
    MapEntry('attach_money', Icons.attach_money),
    MapEntry('money_off', Icons.money_off),
    MapEntry('credit_card', Icons.credit_card),
    MapEntry('savings', Icons.savings),
    MapEntry('receipt_long', Icons.receipt_long),
    MapEntry('receipt', Icons.receipt),
    MapEntry('request_quote', Icons.request_quote),
    MapEntry('paid', Icons.paid),
    MapEntry('price_check', Icons.price_check),
    MapEntry('price_change', Icons.price_change),
    MapEntry('currency_exchange', Icons.currency_exchange),
    MapEntry('monetization_on', Icons.monetization_on),
    MapEntry('trending_up', Icons.trending_up),
    MapEntry('trending_down', Icons.trending_down),

    // ── Shopping & Retail ────────────────────────────────────────────────────
    MapEntry('shopping_cart', Icons.shopping_cart),
    MapEntry('shopping_bag', Icons.shopping_bag),
    MapEntry('local_mall', Icons.local_mall),
    MapEntry('storefront', Icons.storefront),
    MapEntry('redeem', Icons.redeem),
    MapEntry('loyalty', Icons.loyalty),
    MapEntry('sell', Icons.sell),
    MapEntry('discount', Icons.discount),

    // ── Food & Dining ────────────────────────────────────────────────────────
    MapEntry('restaurant', Icons.restaurant),
    MapEntry('lunch_dining', Icons.lunch_dining),
    MapEntry('dinner_dining', Icons.dinner_dining),
    MapEntry('local_cafe', Icons.local_cafe),
    MapEntry('fastfood', Icons.fastfood),
    MapEntry('bakery_dining', Icons.bakery_dining),
    MapEntry('icecream', Icons.icecream),
    MapEntry('local_grocery_store', Icons.local_grocery_store),

    // ── Housing & Home ───────────────────────────────────────────────────────
    MapEntry('home', Icons.home),
    MapEntry('house', Icons.house),
    MapEntry('apartment', Icons.apartment),
    MapEntry('cottage', Icons.cottage),
    MapEntry('bed', Icons.bed),
    MapEntry('bathroom', Icons.bathroom),
    MapEntry('kitchen', Icons.kitchen),
    MapEntry('chair', Icons.chair),
    MapEntry('yard', Icons.yard),
    MapEntry('garage', Icons.garage),
    MapEntry('electrical_services', Icons.electrical_services),
    MapEntry('plumbing', Icons.plumbing),

    // ── Transport & Travel ───────────────────────────────────────────────────
    MapEntry('directions_car', Icons.directions_car),
    MapEntry('local_gas_station', Icons.local_gas_station),
    MapEntry('car_repair', Icons.car_repair),
    MapEntry('directions_bus', Icons.directions_bus),
    MapEntry('directions_subway', Icons.directions_subway),
    MapEntry('directions_bike', Icons.directions_bike),
    MapEntry('two_wheeler', Icons.two_wheeler),
    MapEntry('flight', Icons.flight),
    MapEntry('hotel', Icons.hotel),
    MapEntry('local_taxi', Icons.local_taxi),
    MapEntry('train', Icons.train),
    MapEntry('directions_boat', Icons.directions_boat),
    MapEntry('ev_station', Icons.ev_station),
    MapEntry('local_parking', Icons.local_parking),
    MapEntry('toll', Icons.toll),
    MapEntry('luggage', Icons.luggage),

    // ── Health & Wellness ────────────────────────────────────────────────────
    MapEntry('local_hospital', Icons.local_hospital),
    MapEntry('medical_services', Icons.medical_services),
    MapEntry('medication', Icons.medication),
    MapEntry('healing', Icons.healing),
    MapEntry('fitness_center', Icons.fitness_center),
    MapEntry('spa', Icons.spa),
    MapEntry('self_improvement', Icons.self_improvement),
    MapEntry('psychology', Icons.psychology),
    MapEntry('local_pharmacy', Icons.local_pharmacy),
    MapEntry('vaccines', Icons.vaccines),
    MapEntry('health_and_safety', Icons.health_and_safety),
    MapEntry('accessibility_new', Icons.accessibility_new),

    // ── Education & Work ─────────────────────────────────────────────────────
    MapEntry('school', Icons.school),
    MapEntry('menu_book', Icons.menu_book),
    MapEntry('auto_stories', Icons.auto_stories),
    MapEntry('science', Icons.science),
    MapEntry('calculate', Icons.calculate),
    MapEntry('laptop', Icons.laptop),
    MapEntry('work', Icons.work),
    MapEntry('business_center', Icons.business_center),
    MapEntry('corporate_fare', Icons.corporate_fare),
    MapEntry('badge', Icons.badge),
    MapEntry('engineering', Icons.engineering),
    MapEntry('computer', Icons.computer),

    // ── Entertainment & Leisure ──────────────────────────────────────────────
    MapEntry('movie', Icons.movie),
    MapEntry('tv', Icons.tv),
    MapEntry('music_note', Icons.music_note),
    MapEntry('headphones', Icons.headphones),
    MapEntry('sports_esports', Icons.sports_esports),
    MapEntry('sports_soccer', Icons.sports_soccer),
    MapEntry('sports_basketball', Icons.sports_basketball),
    MapEntry('sports_tennis', Icons.sports_tennis),
    MapEntry('hiking', Icons.hiking),
    MapEntry('terrain', Icons.terrain),
    MapEntry('beach_access', Icons.beach_access),
    MapEntry('park', Icons.park),
    MapEntry('theater_comedy', Icons.theater_comedy),
    MapEntry('casino', Icons.casino),
    MapEntry('sports_bar', Icons.sports_bar),
    MapEntry('attractions', Icons.attractions),

    // ── Utilities & Bills ────────────────────────────────────────────────────
    MapEntry('bolt', Icons.bolt),
    MapEntry('water_drop', Icons.water_drop),
    MapEntry('wifi', Icons.wifi),
    MapEntry('phone', Icons.phone),
    MapEntry('smartphone', Icons.smartphone),
    MapEntry('tv_outlined', Icons.tv_off),
    MapEntry('recycling', Icons.recycling),
    MapEntry('local_laundry_service', Icons.local_laundry_service),
    MapEntry('cleaning_services', Icons.cleaning_services),
    MapEntry('handyman', Icons.handyman),
    MapEntry('build', Icons.build),
    MapEntry('construction', Icons.construction),

    // ── Personal & Misc ──────────────────────────────────────────────────────
    MapEntry('child_care', Icons.child_care),
    MapEntry('pets', Icons.pets),
    MapEntry('style', Icons.style),
    MapEntry('face', Icons.face),
    MapEntry('volunteer_activism', Icons.volunteer_activism),
    MapEntry('church', Icons.church),
    MapEntry('celebration', Icons.celebration),
    MapEntry('cake', Icons.cake),
    MapEntry('card_giftcard', Icons.card_giftcard),
    MapEntry('category', Icons.category),
    MapEntry('more_horiz', Icons.more_horiz),
    MapEntry('star', Icons.star),
    MapEntry('flag', Icons.flag),
    MapEntry('bookmark', Icons.bookmark),
    MapEntry('label', Icons.label),
    MapEntry('tag', Icons.tag),
  ];

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return SizedBox(
      height: 280,
      child: GridView.builder(
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 6,
          mainAxisSpacing: 4,
          crossAxisSpacing: 4,
        ),
        itemCount: icons.length,
        itemBuilder: (context, index) {
          final entry = icons[index];
          final isSelected = entry.key == selectedIcon;

          return Tooltip(
            message: entry.key.replaceAll('_', ' '),
            child: InkWell(
              key: ValueKey('iconPicker_${entry.key}'),
              onTap: () => onIconSelected(entry.key),
              borderRadius: BorderRadius.circular(8),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 150),
                decoration: BoxDecoration(
                  color: isSelected
                      ? colorScheme.primary.withValues(alpha: 0.18)
                      : Colors.transparent,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color:
                        isSelected ? colorScheme.primary : Colors.transparent,
                    width: 1.5,
                  ),
                ),
                child: Icon(
                  entry.value,
                  size: 22,
                  color: isSelected
                      ? colorScheme.primary
                      : colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Returns the [IconData] for a stored string key, falling back to
  /// [Icons.category] if the key is not found.
  static IconData iconDataForKey(String key) {
    for (final entry in icons) {
      if (entry.key == key) return entry.value;
    }

    // Decimal representation: e.g. "58287" (pure digits)
    final decRegex = RegExp(r'^\d+$');
    if (decRegex.hasMatch(key)) {
      final codePoint = int.tryParse(key);
      if (codePoint != null) {
        return IconData(codePoint, fontFamily: 'MaterialIcons');
      }
    }

    // Hexadecimal representation: e.g. "0xe3af" or "E3AF" or "0XE3AF"
    final hexRegex = RegExp(r'^(?:0[xX])?([a-fA-F0-9]{4,6})$');
    final hexMatch = hexRegex.firstMatch(key);
    if (hexMatch != null) {
      final hexString = hexMatch.group(1);
      if (hexString != null) {
        final codePoint = int.tryParse(hexString, radix: 16);
        if (codePoint != null) {
          return IconData(codePoint, fontFamily: 'MaterialIcons');
        }
      }
    }

    return Icons.category;
  }
}
