// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';

IconData getIconData(String name) {
  switch (name) {
    // Account specific keys (which might not be in the category picker)
    case 'wallet':
      return Icons.account_balance_wallet_rounded;
    case 'business':
      return Icons.business_center_rounded;
    case 'savings':
      return Icons.savings_rounded;
    case 'credit_card':
      return Icons.credit_card_rounded;
    case 'subscriptions':
      return Icons.subscriptions_rounded;
    case 'lightbulb':
      return Icons.lightbulb_rounded;

    // ── Category Icon Picker String Keys (Mapped to Rounded equivalents) ──────
    // ── Finance & Banking
    case 'account_balance':
      return Icons.account_balance_rounded;
    case 'account_balance_wallet':
      return Icons.account_balance_wallet_rounded;
    case 'attach_money':
      return Icons.attach_money_rounded;
    case 'money_off':
      return Icons.money_off_rounded;
    case 'receipt_long':
      return Icons.receipt_long_rounded;
    case 'receipt':
      return Icons.receipt_rounded;
    case 'request_quote':
      return Icons.request_quote_rounded;
    case 'paid':
      return Icons.paid_rounded;
    case 'price_check':
      return Icons.price_check_rounded;
    case 'price_change':
      return Icons.price_change_rounded;
    case 'currency_exchange':
      return Icons.currency_exchange_rounded;
    case 'monetization_on':
      return Icons.monetization_on_rounded;
    case 'trending_up':
      return Icons.trending_up_rounded;
    case 'trending_down':
      return Icons.trending_down_rounded;
    case 'show_chart':
      return Icons.show_chart_rounded;
    case 'replay':
      return Icons.replay_rounded;

    // ── Shopping & Retail
    case 'shopping_cart':
      return Icons.shopping_cart_rounded;
    case 'shopping_bag':
      return Icons.shopping_bag_rounded;
    case 'local_mall':
      return Icons.local_mall_rounded;
    case 'storefront':
      return Icons.storefront_rounded;
    case 'redeem':
      return Icons.redeem_rounded;
    case 'loyalty':
      return Icons.loyalty_rounded;
    case 'sell':
      return Icons.sell_rounded;
    case 'discount':
      return Icons.discount_rounded;

    // ── Food & Dining
    case 'restaurant':
      return Icons.restaurant_rounded;
    case 'lunch_dining':
      return Icons.lunch_dining_rounded;
    case 'dinner_dining':
      return Icons.dinner_dining_rounded;
    case 'local_cafe':
      return Icons.local_cafe_rounded;
    case 'fastfood':
      return Icons.fastfood_rounded;
    case 'bakery_dining':
      return Icons.bakery_dining_rounded;
    case 'icecream':
      return Icons.icecream_rounded;
    case 'local_grocery_store':
      return Icons.local_grocery_store_rounded;

    // ── Housing & Home
    case 'home':
      return Icons.home_rounded;
    case 'house':
      return Icons.house_rounded;
    case 'apartment':
      return Icons.apartment_rounded;
    case 'cottage':
      return Icons.cottage_rounded;
    case 'bed':
      return Icons.bed_rounded;
    case 'bathroom':
      return Icons.bathroom_rounded;
    case 'kitchen':
      return Icons.kitchen_rounded;
    case 'chair':
      return Icons.chair_rounded;
    case 'yard':
      return Icons.yard_rounded;
    case 'garage':
      return Icons.garage_rounded;
    case 'electrical_services':
      return Icons.electrical_services_rounded;
    case 'plumbing':
      return Icons.plumbing_rounded;

    // ── Transport & Travel
    case 'directions_car':
      return Icons.directions_car_rounded;
    case 'local_gas_station':
      return Icons.local_gas_station_rounded;
    case 'car_repair':
      return Icons.car_repair_rounded;
    case 'directions_bus':
      return Icons.directions_bus_rounded;
    case 'directions_subway':
      return Icons.directions_subway_rounded;
    case 'directions_bike':
      return Icons.directions_bike_rounded;
    case 'two_wheeler':
      return Icons.two_wheeler_rounded;
    case 'flight':
      return Icons.flight_rounded;
    case 'hotel':
      return Icons.hotel_rounded;
    case 'local_taxi':
      return Icons.local_taxi_rounded;
    case 'train':
      return Icons.train_rounded;
    case 'directions_boat':
      return Icons.directions_boat_rounded;
    case 'ev_station':
      return Icons.ev_station_rounded;
    case 'local_parking':
      return Icons.local_parking_rounded;
    case 'toll':
      return Icons.toll_rounded;
    case 'luggage':
      return Icons.luggage_rounded;

    // ── Health & Wellness
    case 'local_hospital':
      return Icons.local_hospital_rounded;
    case 'medical_services':
      return Icons.medical_services_rounded;
    case 'medication':
      return Icons.medication_rounded;
    case 'healing':
      return Icons.healing_rounded;
    case 'fitness_center':
      return Icons.fitness_center_rounded;
    case 'spa':
      return Icons.spa_rounded;
    case 'self_improvement':
      return Icons.self_improvement_rounded;
    case 'psychology':
      return Icons.psychology_rounded;
    case 'local_pharmacy':
      return Icons.local_pharmacy_rounded;
    case 'vaccines':
      return Icons.vaccines_rounded;
    case 'health_and_safety':
      return Icons.health_and_safety_rounded;
    case 'accessibility_new':
      return Icons.accessibility_new_rounded;

    // ── Education & Work
    case 'school':
      return Icons.school_rounded;
    case 'menu_book':
      return Icons.menu_book_rounded;
    case 'auto_stories':
      return Icons.auto_stories_rounded;
    case 'science':
      return Icons.science_rounded;
    case 'calculate':
      return Icons.calculate_rounded;
    case 'laptop':
      return Icons.laptop_rounded;
    case 'work':
      return Icons.work_rounded;
    case 'business_center':
      return Icons.business_center_rounded;
    case 'corporate_fare':
      return Icons.corporate_fare_rounded;
    case 'badge':
      return Icons.badge_rounded;
    case 'engineering':
      return Icons.engineering_rounded;
    case 'computer':
      return Icons.computer_rounded;

    // ── Entertainment & Leisure
    case 'movie':
      return Icons.movie_rounded;
    case 'tv':
      return Icons.tv_rounded;
    case 'music_note':
      return Icons.music_note_rounded;
    case 'headphones':
      return Icons.headphones_rounded;
    case 'sports_esports':
      return Icons.sports_esports_rounded;
    case 'sports_soccer':
      return Icons.sports_soccer_rounded;
    case 'sports_basketball':
      return Icons.sports_basketball_rounded;
    case 'sports_tennis':
      return Icons.sports_tennis_rounded;
    case 'hiking':
      return Icons.hiking_rounded;
    case 'terrain':
      return Icons.terrain_rounded;
    case 'beach_access':
      return Icons.beach_access_rounded;
    case 'park':
      return Icons.park_rounded;
    case 'theater_comedy':
      return Icons.theater_comedy_rounded;
    case 'casino':
      return Icons.casino_rounded;
    case 'sports_bar':
      return Icons.sports_bar_rounded;
    case 'attractions':
      return Icons.attractions_rounded;

    // ── Utilities & Bills
    case 'bolt':
      return Icons.bolt_rounded;
    case 'water_drop':
      return Icons.water_drop_rounded;
    case 'wifi':
      return Icons.wifi_rounded;
    case 'phone':
      return Icons.phone_rounded;
    case 'smartphone':
      return Icons.smartphone_rounded;
    case 'tv_outlined':
      return Icons.tv_off_rounded;
    case 'recycling':
      return Icons.recycling_rounded;
    case 'local_laundry_service':
      return Icons.local_laundry_service_rounded;
    case 'cleaning_services':
      return Icons.cleaning_services_rounded;
    case 'handyman':
      return Icons.handyman_rounded;
    case 'build':
      return Icons.build_rounded;
    case 'construction':
      return Icons.construction_rounded;

    // ── Personal & Misc
    case 'child_care':
      return Icons.child_care_rounded;
    case 'pets':
      return Icons.pets_rounded;
    case 'style':
      return Icons.style_rounded;
    case 'face':
      return Icons.face_rounded;
    case 'volunteer_activism':
      return Icons.volunteer_activism_rounded;
    case 'church':
      return Icons.church_rounded;
    case 'celebration':
      return Icons.celebration_rounded;
    case 'cake':
      return Icons.cake_rounded;
    case 'card_giftcard':
      return Icons.card_giftcard_rounded;
    case 'category':
      return Icons.category_rounded;
    case 'more_horiz':
      return Icons.more_horiz_rounded;
    case 'star':
      return Icons.star_rounded;
    case 'flag':
      return Icons.flag_rounded;
    case 'bookmark':
      return Icons.bookmark_rounded;
    case 'label':
      return Icons.label_rounded;
    case 'tag':
      return Icons.tag_rounded;

    // ── Travel, Aviation & Navigation
    case 'flight_takeoff':
      return Icons.flight_takeoff_rounded;
    case 'flight_land':
      return Icons.flight_land_rounded;
    case 'commute':
      return Icons.commute_rounded;
    case 'subway':
      return Icons.subway_rounded;
    case 'electric_car':
      return Icons.electric_car_rounded;
    case 'motorcycle':
      return Icons.motorcycle_rounded;
    case 'map':
      return Icons.map_rounded;
    case 'explore':
      return Icons.explore_rounded;
    case 'navigation':
      return Icons.navigation_rounded;

    // ── Commerce, Retail & Deals
    case 'card_membership':
      return Icons.card_membership_rounded;
    case 'store':
      return Icons.store_rounded;
    case 'local_offer':
      return Icons.local_offer_rounded;

    // ── Technology, Power & Utilities
    case 'power':
      return Icons.power_rounded;
    case 'electric_bolt':
      return Icons.electric_bolt_rounded;
    case 'router':
      return Icons.router_rounded;
    case 'devices':
      return Icons.devices_rounded;
    case 'cloud':
      return Icons.cloud_rounded;
    case 'solar_power':
      return Icons.solar_power_rounded;

    // ── Dining, Beverages & Gastronomy
    case 'local_bar':
      return Icons.local_bar_rounded;
    case 'liquor':
      return Icons.liquor_rounded;
    case 'ramen_dining':
      return Icons.ramen_dining_rounded;
    case 'takeout_dining':
      return Icons.takeout_dining_rounded;
    case 'wine_bar':
      return Icons.wine_bar_rounded;
    case 'coffee':
      return Icons.coffee_rounded;
    case 'soup_kitchen':
      return Icons.soup_kitchen_rounded;

    // ── Entertainment, Arts & Sports
    case 'camera_alt':
      return Icons.camera_alt_rounded;
    case 'palette':
      return Icons.palette_rounded;
    case 'stadium':
      return Icons.stadium_rounded;
    case 'music_video':
      return Icons.music_video_rounded;
    case 'sports_motorsports':
      return Icons.sports_motorsports_rounded;
    case 'sports_golf':
      return Icons.sports_golf_rounded;
    case 'sports_baseball':
      return Icons.sports_baseball_rounded;
    case 'sports_football':
      return Icons.sports_football_rounded;
    case 'pool':
      return Icons.pool_rounded;

    // ── Services, Security & Maintenance
    case 'family_restroom':
      return Icons.family_restroom_rounded;
    case 'content_cut':
      return Icons.content_cut_rounded;
    case 'dry_cleaning':
      return Icons.dry_cleaning_rounded;
    case 'security':
      return Icons.security_rounded;
    case 'shield':
      return Icons.shield_rounded;
    case 'workspace_premium':
      return Icons.workspace_premium_rounded;
    case 'pest_control':
      return Icons.pest_control_rounded;
    case 'roofing':
      return Icons.roofing_rounded;
    case 'deck':
      return Icons.deck_rounded;

    // ── Education, Time & General Life
    case 'school_outlined':
      return Icons.school_rounded;
    case 'event':
      return Icons.event_rounded;
    case 'alarm':
      return Icons.alarm_rounded;
    case 'watch':
      return Icons.watch_rounded;
    case 'interests':
      return Icons.interests_rounded;
    case 'newspaper':
      return Icons.newspaper_rounded;
    case 'print':
      return Icons.print_rounded;
  }

  // Fallback
  return Icons.category_rounded;
}
