import 'package:cookie_manager_kit/src/cookie_manager_kit_platform_interface.dart';

class CookieManager {
  const CookieManager._();

  static CookieManagerKitPlatform get instance =>
      CookieManagerKitPlatform.instance;
}
