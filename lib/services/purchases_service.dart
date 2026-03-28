import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PurchasesService {
  static const String _premiumKey = 'is_premium';

  Future<void> initialize() async {
    final apiKey = dotenv.env['REVENUECAT_API_KEY'] ?? '';
    if (apiKey.isEmpty) return;
    
    await Purchases.setLogLevel(LogLevel.debug);
    await Purchases.configure(PurchasesConfiguration(apiKey));
  }

  Future<bool> isPremium() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_premiumKey) ?? false;
  }

  Future<void> setPremium(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_premiumKey, value);
  }

  Future<bool> purchasePremium() async {
    try {
      final offerings = await Purchases.getOfferings();
      if (offerings.current == null) return false;

      final package = offerings.current!.monthly;
      if (package == null) return false;

      final purchaserInfo = await Purchases.purchasePackage(package);
      if (purchaserInfo.entitlements.active.containsKey('premium')) {
        await setPremium(true);
        return true;
      }
      return false;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  Future<void> restorePurchases() async {
    try {
      final purchaserInfo = await Purchases.restorePurchases();
      if (purchaserInfo.entitlements.active.containsKey('premium')) {
        await setPremium(true);
      }
    } catch (e) {
      print('Restore error: $e');
    }
  }
}
