// ignore_for_file: non_const_argument_for_const_parameter
import 'package:flutter/material.dart';
import 'package:stalvi/core/l10n/app_localizations.dart';
import 'package:stalvi/core/utils/icon_helper.dart';

/// A grid picker that displays 180 unique Material Icons relevant to finances,
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
  // Icon catalogue — 180 unique, non-repeating entries
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
    MapEntry('show_chart', Icons.show_chart),
    MapEntry('replay', Icons.replay),

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

    // ── Travel, Aviation & Navigation ─────────────────────────────────────────
    MapEntry('flight_takeoff', Icons.flight_takeoff),
    MapEntry('flight_land', Icons.flight_land),
    MapEntry('commute', Icons.commute),
    MapEntry('subway', Icons.subway),
    MapEntry('electric_car', Icons.electric_car),
    MapEntry('motorcycle', Icons.motorcycle),
    MapEntry('map', Icons.map),
    MapEntry('explore', Icons.explore),
    MapEntry('navigation', Icons.navigation),

    // ── Commerce, Retail & Deals ─────────────────────────────────────────────
    MapEntry('card_membership', Icons.card_membership),
    MapEntry('store', Icons.store),
    MapEntry('local_offer', Icons.local_offer),

    // ── Technology, Power & Utilities ────────────────────────────────────────
    MapEntry('power', Icons.power),
    MapEntry('electric_bolt', Icons.electric_bolt),
    MapEntry('router', Icons.router),
    MapEntry('devices', Icons.devices),
    MapEntry('cloud', Icons.cloud),
    MapEntry('solar_power', Icons.solar_power),

    // ── Dining, Beverages & Gastronomy ───────────────────────────────────────
    MapEntry('local_bar', Icons.local_bar),
    MapEntry('liquor', Icons.liquor),
    MapEntry('ramen_dining', Icons.ramen_dining),
    MapEntry('takeout_dining', Icons.takeout_dining),
    MapEntry('wine_bar', Icons.wine_bar),
    MapEntry('coffee', Icons.coffee),
    MapEntry('soup_kitchen', Icons.soup_kitchen),

    // ── Entertainment, Arts & Sports ─────────────────────────────────────────
    MapEntry('camera_alt', Icons.camera_alt),
    MapEntry('palette', Icons.palette),
    MapEntry('stadium', Icons.stadium),
    MapEntry('music_video', Icons.music_video),
    MapEntry('sports_motorsports', Icons.sports_motorsports),
    MapEntry('sports_golf', Icons.sports_golf),
    MapEntry('sports_baseball', Icons.sports_baseball),
    MapEntry('sports_football', Icons.sports_football),
    MapEntry('pool', Icons.pool),

    // ── Services, Security & Maintenance ─────────────────────────────────────
    MapEntry('family_restroom', Icons.family_restroom),
    MapEntry('content_cut', Icons.content_cut),
    MapEntry('dry_cleaning', Icons.dry_cleaning),
    MapEntry('security', Icons.security),
    MapEntry('shield', Icons.shield),
    MapEntry('workspace_premium', Icons.workspace_premium),
    MapEntry('pest_control', Icons.pest_control),
    MapEntry('roofing', Icons.roofing),
    MapEntry('deck', Icons.deck),

    // ── Education, Time & General Life ───────────────────────────────────────
    MapEntry('school_outlined', Icons.school_outlined),
    MapEntry('event', Icons.event),
    MapEntry('alarm', Icons.alarm),
    MapEntry('watch', Icons.watch),
    MapEntry('interests', Icons.interests),
    MapEntry('newspaper', Icons.newspaper),
    MapEntry('print', Icons.print),
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

          final localizedName = localizedIconName(context, entry.key);

          return Semantics(
            button: true,
            selected: isSelected,
            label: localizedName,
            child: Tooltip(
              message: localizedName,
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
            ),
          );
        },
      ),
    );
  }

  /// Returns the localized meaning of the category icon key for screen readers.
  static String localizedIconName(BuildContext context, String iconKey) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return iconKey.replaceAll('_', ' ');

    switch (iconKey) {
      // ── Finance & Banking
      case 'account_balance':
        return l10n.a11yIconAccountBalance;
      case 'account_balance_wallet':
        return l10n.a11yIconAccountBalanceWallet;
      case 'attach_money':
        return l10n.a11yIconAttachMoney;
      case 'money_off':
        return l10n.a11yIconMoneyOff;
      case 'credit_card':
        return l10n.a11yIconCreditCard;
      case 'savings':
        return l10n.a11yIconSavings;
      case 'receipt_long':
        return l10n.a11yIconReceiptLong;
      case 'receipt':
        return l10n.a11yIconReceipt;
      case 'request_quote':
        return l10n.a11yIconRequestQuote;
      case 'paid':
        return l10n.a11yIconPaid;
      case 'price_check':
        return l10n.a11yIconPriceCheck;
      case 'price_change':
        return l10n.a11yIconPriceChange;
      case 'currency_exchange':
        return l10n.a11yIconCurrencyExchange;
      case 'monetization_on':
        return l10n.a11yIconMonetizationOn;
      case 'trending_up':
        return l10n.a11yIconTrendingUp;
      case 'trending_down':
        return l10n.a11yIconTrendingDown;
      case 'show_chart':
        return l10n.a11yIconShowChart;
      case 'replay':
        return l10n.a11yIconReplay;

      // ── Shopping & Retail
      case 'shopping_cart':
        return l10n.a11yIconShoppingCart;
      case 'shopping_bag':
        return l10n.a11yIconShoppingBag;
      case 'local_mall':
        return l10n.a11yIconLocalMall;
      case 'storefront':
        return l10n.a11yIconStorefront;
      case 'redeem':
        return l10n.a11yIconRedeem;
      case 'loyalty':
        return l10n.a11yIconLoyalty;
      case 'sell':
        return l10n.a11yIconSell;
      case 'discount':
        return l10n.a11yIconDiscount;

      // ── Food & Dining
      case 'restaurant':
        return l10n.a11yIconRestaurant;
      case 'lunch_dining':
        return l10n.a11yIconLunchDining;
      case 'dinner_dining':
        return l10n.a11yIconDinnerDining;
      case 'local_cafe':
        return l10n.a11yIconLocalCafe;
      case 'fastfood':
        return l10n.a11yIconFastfood;
      case 'bakery_dining':
        return l10n.a11yIconBakeryDining;
      case 'icecream':
        return l10n.a11yIconIcecream;
      case 'local_grocery_store':
        return l10n.a11yIconLocalGroceryStore;

      // ── Housing & Home
      case 'home':
        return l10n.a11yIconHome;
      case 'house':
        return l10n.a11yIconHouse;
      case 'apartment':
        return l10n.a11yIconApartment;
      case 'cottage':
        return l10n.a11yIconCottage;
      case 'bed':
        return l10n.a11yIconBed;
      case 'bathroom':
        return l10n.a11yIconBathroom;
      case 'kitchen':
        return l10n.a11yIconKitchen;
      case 'chair':
        return l10n.a11yIconChair;
      case 'yard':
        return l10n.a11yIconYard;
      case 'garage':
        return l10n.a11yIconGarage;
      case 'electrical_services':
        return l10n.a11yIconElectricalServices;
      case 'plumbing':
        return l10n.a11yIconPlumbing;

      // ── Transport & Travel
      case 'directions_car':
        return l10n.a11yIconDirectionsCar;
      case 'local_gas_station':
        return l10n.a11yIconLocalGasStation;
      case 'car_repair':
        return l10n.a11yIconCarRepair;
      case 'directions_bus':
        return l10n.a11yIconDirectionsBus;
      case 'directions_subway':
        return l10n.a11yIconDirectionsSubway;
      case 'directions_bike':
        return l10n.a11yIconDirectionsBike;
      case 'two_wheeler':
        return l10n.a11yIconTwoWheeler;
      case 'flight':
        return l10n.a11yIconFlight;
      case 'hotel':
        return l10n.a11yIconHotel;
      case 'local_taxi':
        return l10n.a11yIconLocalTaxi;
      case 'train':
        return l10n.a11yIconTrain;
      case 'directions_boat':
        return l10n.a11yIconDirectionsBoat;
      case 'ev_station':
        return l10n.a11yIconEvStation;
      case 'local_parking':
        return l10n.a11yIconLocalParking;
      case 'toll':
        return l10n.a11yIconToll;
      case 'luggage':
        return l10n.a11yIconLuggage;

      // ── Health & Wellness
      case 'local_hospital':
        return l10n.a11yIconLocalHospital;
      case 'medical_services':
        return l10n.a11yIconMedicalServices;
      case 'medication':
        return l10n.a11yIconMedication;
      case 'healing':
        return l10n.a11yIconHealing;
      case 'fitness_center':
        return l10n.a11yIconFitnessCenter;
      case 'spa':
        return l10n.a11yIconSpa;
      case 'self_improvement':
        return l10n.a11yIconSelfImprovement;
      case 'psychology':
        return l10n.a11yIconPsychology;
      case 'local_pharmacy':
        return l10n.a11yIconLocalPharmacy;
      case 'vaccines':
        return l10n.a11yIconVaccines;
      case 'health_and_safety':
        return l10n.a11yIconHealthAndSafety;
      case 'accessibility_new':
        return l10n.a11yIconAccessibilityNew;

      // ── Education & Work
      case 'school':
        return l10n.a11yIconSchool;
      case 'menu_book':
        return l10n.a11yIconMenuBook;
      case 'auto_stories':
        return l10n.a11yIconAutoStories;
      case 'science':
        return l10n.a11yIconScience;
      case 'calculate':
        return l10n.a11yIconCalculate;
      case 'laptop':
        return l10n.a11yIconLaptop;
      case 'work':
        return l10n.a11yIconWork;
      case 'business_center':
        return l10n.a11yIconBusinessCenter;
      case 'corporate_fare':
        return l10n.a11yIconCorporateFare;
      case 'badge':
        return l10n.a11yIconBadge;
      case 'engineering':
        return l10n.a11yIconEngineering;
      case 'computer':
        return l10n.a11yIconComputer;

      // ── Entertainment & Leisure
      case 'movie':
        return l10n.a11yIconMovie;
      case 'tv':
        return l10n.a11yIconTv;
      case 'music_note':
        return l10n.a11yIconMusicNote;
      case 'headphones':
        return l10n.a11yIconHeadphones;
      case 'sports_esports':
        return l10n.a11yIconSportsEsports;
      case 'sports_soccer':
        return l10n.a11yIconSportsSoccer;
      case 'sports_basketball':
        return l10n.a11yIconSportsBasketball;
      case 'sports_tennis':
        return l10n.a11yIconSportsTennis;
      case 'hiking':
        return l10n.a11yIconHiking;
      case 'terrain':
        return l10n.a11yIconTerrain;
      case 'beach_access':
        return l10n.a11yIconBeachAccess;
      case 'park':
        return l10n.a11yIconPark;
      case 'theater_comedy':
        return l10n.a11yIconTheaterComedy;
      case 'casino':
        return l10n.a11yIconCasino;
      case 'sports_bar':
        return l10n.a11yIconSportsBar;
      case 'attractions':
        return l10n.a11yIconAttractions;

      // ── Utilities & Bills
      case 'bolt':
        return l10n.a11yIconBolt;
      case 'water_drop':
        return l10n.a11yIconWaterDrop;
      case 'wifi':
        return l10n.a11yIconWifi;
      case 'phone':
        return l10n.a11yIconPhone;
      case 'smartphone':
        return l10n.a11yIconSmartphone;
      case 'tv_outlined':
        return l10n.a11yIconTvOutlined;
      case 'recycling':
        return l10n.a11yIconRecycling;
      case 'local_laundry_service':
        return l10n.a11yIconLocalLaundryService;
      case 'cleaning_services':
        return l10n.a11yIconCleaningServices;
      case 'handyman':
        return l10n.a11yIconHandyman;
      case 'build':
        return l10n.a11yIconBuild;
      case 'construction':
        return l10n.a11yIconConstruction;

      // ── Personal & Misc
      case 'child_care':
        return l10n.a11yIconChildCare;
      case 'pets':
        return l10n.a11yIconPets;
      case 'style':
        return l10n.a11yIconStyle;
      case 'face':
        return l10n.a11yIconFace;
      case 'volunteer_activism':
        return l10n.a11yIconVolunteerActivism;
      case 'church':
        return l10n.a11yIconChurch;
      case 'celebration':
        return l10n.a11yIconCelebration;
      case 'cake':
        return l10n.a11yIconCake;
      case 'card_giftcard':
        return l10n.a11yIconCardGiftcard;
      case 'category':
        return l10n.a11yIconCategory;
      case 'more_horiz':
        return l10n.a11yIconMoreHoriz;
      case 'star':
        return l10n.a11yIconStar;
      case 'flag':
        return l10n.a11yIconFlag;
      case 'bookmark':
        return l10n.a11yIconBookmark;
      case 'label':
        return l10n.a11yIconLabel;
      case 'tag':
        return l10n.a11yIconTag;

      // ── Travel, Aviation & Navigation
      case 'flight_takeoff':
        return l10n.a11yIconFlightTakeoff;
      case 'flight_land':
        return l10n.a11yIconFlightLand;
      case 'commute':
        return l10n.a11yIconCommute;
      case 'subway':
        return l10n.a11yIconSubway;
      case 'electric_car':
        return l10n.a11yIconElectricCar;
      case 'motorcycle':
        return l10n.a11yIconMotorcycle;
      case 'map':
        return l10n.a11yIconMap;
      case 'explore':
        return l10n.a11yIconExplore;
      case 'navigation':
        return l10n.a11yIconNavigation;

      // ── Commerce, Retail & Deals
      case 'card_membership':
        return l10n.a11yIconCardMembership;
      case 'store':
        return l10n.a11yIconStore;
      case 'local_offer':
        return l10n.a11yIconLocalOffer;

      // ── Technology, Power & Utilities
      case 'power':
        return l10n.a11yIconPower;
      case 'electric_bolt':
        return l10n.a11yIconElectricBolt;
      case 'router':
        return l10n.a11yIconRouter;
      case 'devices':
        return l10n.a11yIconDevices;
      case 'cloud':
        return l10n.a11yIconCloud;
      case 'solar_power':
        return l10n.a11yIconSolarPower;

      // ── Dining, Beverages & Gastronomy
      case 'local_bar':
        return l10n.a11yIconLocalBar;
      case 'liquor':
        return l10n.a11yIconLiquor;
      case 'ramen_dining':
        return l10n.a11yIconRamenDining;
      case 'takeout_dining':
        return l10n.a11yIconTakeoutDining;
      case 'wine_bar':
        return l10n.a11yIconWineBar;
      case 'coffee':
        return l10n.a11yIconCoffee;
      case 'soup_kitchen':
        return l10n.a11yIconSoupKitchen;

      // ── Entertainment, Arts & Sports
      case 'camera_alt':
        return l10n.a11yIconCameraAlt;
      case 'palette':
        return l10n.a11yIconPalette;
      case 'stadium':
        return l10n.a11yIconStadium;
      case 'music_video':
        return l10n.a11yIconMusicVideo;
      case 'sports_motorsports':
        return l10n.a11yIconSportsMotorsports;
      case 'sports_golf':
        return l10n.a11yIconSportsGolf;
      case 'sports_baseball':
        return l10n.a11yIconSportsBaseball;
      case 'sports_football':
        return l10n.a11yIconSportsFootball;
      case 'pool':
        return l10n.a11yIconPool;

      // ── Services, Security & Maintenance
      case 'family_restroom':
        return l10n.a11yIconFamilyRestroom;
      case 'content_cut':
        return l10n.a11yIconContentCut;
      case 'dry_cleaning':
        return l10n.a11yIconDryCleaning;
      case 'security':
        return l10n.a11yIconSecurity;
      case 'shield':
        return l10n.a11yIconShield;
      case 'workspace_premium':
        return l10n.a11yIconWorkspacePremium;
      case 'pest_control':
        return l10n.a11yIconPestControl;
      case 'roofing':
        return l10n.a11yIconRoofing;
      case 'deck':
        return l10n.a11yIconDeck;

      // ── Education, Time & General Life
      case 'school_outlined':
        return l10n.a11yIconSchoolOutlined;
      case 'event':
        return l10n.a11yIconEvent;
      case 'alarm':
        return l10n.a11yIconAlarm;
      case 'watch':
        return l10n.a11yIconWatch;
      case 'interests':
        return l10n.a11yIconInterests;
      case 'newspaper':
        return l10n.a11yIconNewspaper;
      case 'print':
        return l10n.a11yIconPrint;

      default:
        return iconKey.replaceAll('_', ' ');
    }
  }

  /// Returns the [IconData] for a stored string key, falling back to
  /// [Icons.category_rounded] via [getIconData] if the key is not in [icons].
  static IconData iconDataForKey(String key) {
    for (final entry in icons) {
      if (entry.key == key) return entry.value;
    }

    return getIconData(key);
  }

  /// Returns the localized name of a color for screen readers.
  static String localizedColorName(BuildContext context, String colorHexOrKey) {
    final l10n = AppLocalizations.of(context);
    if (l10n == null) return colorHexOrKey;

    final key = colorHexOrKey.trim().toUpperCase().replaceAll('#', '');

    switch (key) {
      case '2196F3':
      case 'BLUE':
        return l10n.a11yColorBlue;
      case '03A9F4':
      case 'LIGHTBLUE':
      case 'LIGHT_BLUE':
        return l10n.a11yColorLightBlue;
      case '4CAF50':
      case 'GREEN':
        return l10n.a11yColorGreen;
      case '8BC34A':
      case 'LIGHTGREEN':
      case 'LIGHT_GREEN':
        return l10n.a11yColorLightGreen;
      case 'CDDC39':
      case 'LIME':
        return l10n.a11yColorLime;
      case 'D4E157':
      case 'LIGHTLIME':
      case 'LIGHT_LIME':
        return l10n.a11yColorLightLime;
      case 'FFEB3B':
      case 'YELLOW':
        return l10n.a11yColorYellow;
      case 'FFC107':
      case 'AMBER':
        return l10n.a11yColorAmber;
      case 'FF9800':
      case 'ORANGE':
        return l10n.a11yColorOrange;
      case 'FF5722':
      case 'DEEPORANGE':
      case 'DEEP_ORANGE':
        return l10n.a11yColorDeepOrange;
      case 'FF7043':
      case 'CORAL':
        return l10n.a11yColorCoral;
      case 'F44336':
      case 'RED':
        return l10n.a11yColorRed;
      case 'E91E63':
      case 'PINK':
        return l10n.a11yColorPink;
      case 'EC407A':
      case 'LIGHTPINK':
      case 'LIGHT_PINK':
        return l10n.a11yColorLightPink;
      case '9C27B0':
      case 'PURPLE':
        return l10n.a11yColorPurple;
      case '673AB7':
      case 'DEEPPURPLE':
      case 'DEEP_PURPLE':
        return l10n.a11yColorDeepPurple;
      case '3F51B5':
      case 'INDIGO':
        return l10n.a11yColorIndigo;
      case '00BCD4':
      case 'CYAN':
        return l10n.a11yColorCyan;
      case '009688':
      case 'TEAL':
        return l10n.a11yColorTeal;
      case '26A69A':
      case 'MINT':
        return l10n.a11yColorMint;
      case '795548':
      case 'BROWN':
        return l10n.a11yColorBrown;
      case '8D6E63':
      case 'LIGHTBROWN':
      case 'LIGHT_BROWN':
        return l10n.a11yColorLightBrown;
      case '9E9E9E':
      case 'GREY':
      case 'GRAY':
        return l10n.a11yColorGrey;
      case '607D8B':
      case 'BLUEGREY':
      case 'BLUE_GREY':
        return l10n.a11yColorBlueGrey;
      case '000000':
      case 'BLACK':
        return l10n.a11yColorBlack;
      case 'FFFFFF':
      case 'WHITE':
        return l10n.a11yColorWhite;
      default:
        return colorHexOrKey;
    }
  }
}
